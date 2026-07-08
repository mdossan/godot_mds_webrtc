class_name MdsWebRTC extends Node

#region signals
signal socket_ready
signal game_started(peer_ids: Array[int])
signal new_player_joined(new_player_id: int)
signal lobby_created()
signal received_lobbies(lobbies: Array[Dictionary])
signal players_in_lobby(players_names: Array[String])
signal player_is_ready(player_id: int)
#endregion

#region variables
@export var mds_available_state: MdsAvailableLobbiesState = preload("res://addons/mds_webrtc/mds_available_lobbies_state.tres")
@export var mds_lobby_state: MdsLobbyState = preload("res://addons/mds_webrtc/mds_lobby_state.tres")
@export var mds_player_state: MdsPlayerState = preload("res://addons/mds_webrtc/mds_player_state.tres")
@export var websocket_url = "ws://localhost:4242"
var _number_of_players: int = 1
var socket_init_in_progress = true
var socket = WebSocketPeer.new()
var webrtc = WebRTCMultiplayerPeer.new()
#endregion

#region Godot's Lifecyles
func _ready() -> void:
	var connection_result = socket.connect_to_url(websocket_url)
	if connection_result != OK:
		push_error("Can't start websocket connection")
	multiplayer.peer_connected.connect(_on_peer_connected)

func _process(_delta):
	if socket_init_in_progress and socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		socket_init_in_progress = false
		register()
		return
	
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			SocketMessageHandler.handle_new_message(self)
	
	webrtc.poll()
#endregion

#region Public

func start_game():
	var peer_ids: Array[int] = []
	peer_ids.assign(webrtc.get_peers().keys())
	peer_ids.push_front(mds_player_state.player_id)
	game_started.emit(peer_ids)

func create_lobby():
	if mds_player_state.player_name == "":
		push_error("Can't join a lobby with empty `player_name`")
		return
	var message: Dictionary = {
		"type": "CREATE_LOBBY",
		"playerName": mds_player_state.player_name,
	}
	var json_message: String = JSON.stringify(message)
	socket.send_text(json_message)
	webrtc.create_mesh(mds_player_state.player_id)
	multiplayer.multiplayer_peer = webrtc
	set_multiplayer_authority(mds_player_state.player_id)
	mds_lobby_state.is_host = true
	mds_lobby_state.ready_players[mds_player_state.player_id] = true
	mds_lobby_state.emit_changed()
	print_debug("[MdsWebRTC] Lobby creation request sent to signaling server")
	%ConnectionCheckerTimer.start()

func list_lobbies():
	var message: Dictionary = { "type": "LIST_LOBBIES" }
	var json_message: String = JSON.stringify(message)
	socket.send_text(json_message)
	print_debug("[MdsWebRTC] Lobby listing request sent to signaling server")

#endregion

#region Private

func _on_ice_candidate(media: String, index: int, ice_name: String, destination_player_id: int):
	var message: Dictionary = {
			"type": "ICE",
			"sourcePlayerId": mds_player_state.player_id,
			"destinationPlayerId": destination_player_id,
			"media": media,
			"index": index,
			"name": ice_name,
		}
	var json_message: String = JSON.stringify(message)
	socket.send_text(json_message)

func handle_session_creation(type: String, sdp: String, dest_player_id: int):
	webrtc.get_peer(dest_player_id).get("connection").set_local_description(type, sdp)
	if type == "offer":
		# This SDP is an offer, it will be transmitted to the newly connected player
		# It is initiated from create_webrtc_connection_between_player
		var message: Dictionary = {
			"type": "OFFER",
			"playerId": mds_player_state.player_id,
			"newPlayerId": dest_player_id,
			"sdp": sdp,
		}
		var json_message: String = JSON.stringify(message)
		socket.send_text(json_message)
	else:
		# This SDP answer is created after handling the offer from an already connected player
		# `create_webrtc_connection_from_offer`
		var message: Dictionary = {
			"type": "ANSWER",
			"sourcePlayerId": mds_player_state.player_id,
			"destinationPlayerId": dest_player_id,
			"sdp": sdp,
		}
		var json_message: String = JSON.stringify(message)
		socket.send_text(json_message)

func _on_connection_checker_timer() -> void:
	ping.rpc()

func _on_peer_connected(player_id: int) -> void:
	mds_lobby_state.ready_players[player_id] = true
	mds_lobby_state.emit_changed()

func register():
	var message: Dictionary = {
		"type": "REGISTER",
		"playerId": mds_player_state.player_id
	}
	var json_message: String = JSON.stringify(message)
	socket.send_text(json_message)

func handle_join_lobby(lobby_id: String):
	if mds_player_state.player_name == "":
		push_error("Can't join a lobby with empty `player_name`")
		return
	webrtc.create_mesh(mds_player_state.player_id)
	multiplayer.multiplayer_peer = webrtc
	var message: Dictionary = {
		"type": "JOIN_LOBBY",
		"lobbyId": lobby_id,
		"playerName": mds_player_state.player_name,
	}
	var json_message: String = JSON.stringify(message)
	socket.send_text(json_message)
	set_multiplayer_authority(int(lobby_id))
	mds_lobby_state.is_host = false
	mds_lobby_state.ready_players[mds_player_state.player_id] = true
	mds_lobby_state.emit_changed()

func create_webrtc_connection_between_player(remote_player_id: int):
	var peer: WebRTCPeerConnection = WebRTCPeerConnection.new()
	peer.initialize({
		"iceServers": [ { "urls": ["stun:stun.l.google.com:19302"] } ]
	})
	var err = webrtc.add_peer(peer, remote_player_id)
	assert(err == OK, "[%s] Failed to add peer %s" % [mds_player_state.player_id, remote_player_id])
	# Link signals
	peer.session_description_created.connect(handle_session_creation.bind(remote_player_id))
	peer.ice_candidate_created.connect(_on_ice_candidate.bind(remote_player_id))
	# Create SDP to share with the newly created peer
	peer.create_offer()

func create_webrtc_connection_from_offer(remote_player_id: int, sdp: String):
	# Init a new peer connection
	var peer: WebRTCPeerConnection = WebRTCPeerConnection.new()
	peer.initialize({
		"iceServers": [ { "urls": ["stun:stun.l.google.com:19302"] } ]
	})
	# Add peer to WebRTCMultiplayerPeer
	var err = webrtc.add_peer(peer, remote_player_id)
	assert(err == OK, "[%s] Failed to add peer %s" % [mds_player_state.player_id, remote_player_id])
	# Link signals
	peer.session_description_created.connect(handle_session_creation.bind(remote_player_id))
	peer.ice_candidate_created.connect(_on_ice_candidate.bind(remote_player_id))
	# Load the provided remote SDP
	peer.set_remote_description("offer", sdp)

#endregion

#region RPCs
@rpc("authority", "call_remote", "reliable")
func ping():
	pong.rpc_id(get_multiplayer_authority(), multiplayer.get_unique_id(), multiplayer.get_peers().size())

@rpc("any_peer", "call_remote", "reliable")
func pong(remote_player_id: int, number_of_connections: int):
	if number_of_connections == _number_of_players - 1:
		mds_lobby_state.ready_players[remote_player_id] = true
		mds_lobby_state.emit_changed()
#endregion
