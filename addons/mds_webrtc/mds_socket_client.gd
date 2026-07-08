class_name MdsSocketClient extends Node

@export var mds_webrtc: MdsWebRTC
@export var websocket_url = "ws://localhost:4242"
var socket: WebSocketPeer = WebSocketPeer.new()
var socket_init_in_progress = true

func init_socket() -> void:
	var connection_result = socket.connect_to_url(websocket_url)
	if connection_result != OK:
		push_error("Can't start websocket connection")

func close() -> void:
	socket.close()

func _process(_delta: float) -> void:
	if socket_init_in_progress and socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		socket_init_in_progress = false
		register()
		return
	
	socket.poll()
	var state = socket.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			SocketMessageHandler.handle_new_message(self, mds_webrtc)

func send_data(data: Dictionary) -> void:
	var json_message: String = JSON.stringify(data)
	socket.send_text(json_message)

func register():
	send_data({
		"type": "REGISTER",
		"playerId": mds_webrtc.mds_player_state.player_id
	})
