class_name LobbyJoinedHandler

static func handle(mds_webrtc: MdsWebRTC, data: Dictionary) -> void:
	var players_in_room: Dictionary[String, String] = {}
	players_in_room.assign(data.get("players"))
	mds_webrtc.mds_lobby_state.player_names_by_player_ids = {}
	for player_id: String in players_in_room:
		var key: int = player_id.to_int()
		var player_name: String = players_in_room[player_id]
		mds_webrtc.mds_lobby_state.player_names_by_player_ids[key] = player_name
		mds_webrtc.mds_lobby_state.player_ids.append(key)
	mds_webrtc.mds_lobby_state.emit_changed()
	print_debug("[MdsWebRTC]: Receiving `RESULT_JOIN_LOBBY` event from signaling server")
