class_name PlayerJoinedHandler

static func handle(mds_webrtc: MdsWebRTC, data: Dictionary) -> void:
	var new_player_id: int = data.get("playerId")
	var new_player_name: String = data.get("playerName")
	mds_webrtc.create_webrtc_connection_between_player(new_player_id)
	mds_webrtc.mds_lobby_state.player_ids.append(new_player_id)
	mds_webrtc.mds_lobby_state.players.append(new_player_name)
	mds_webrtc.mds_lobby_state.player_names_by_player_ids[new_player_id] = new_player_name
	mds_webrtc.mds_lobby_state.emit_changed()
	mds_webrtc._number_of_players += 1
	print_debug("[MdsWebRTC][%s]: Receiving `PLAYER_JOINED` event from signaling server" % mds_webrtc.mds_player_state.player_id)
