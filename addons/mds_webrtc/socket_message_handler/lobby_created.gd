class_name LobbyCreatedHandler

static func handle(mds_webrtc: MdsWebRTC, data: Dictionary) -> void:
	print_debug("[MdsWebRTC]: Receiving `LOBBY_CREATED` event from signaling server")
	mds_webrtc.mds_lobby_state.players.append(mds_webrtc.mds_player_state.player_name)
	mds_webrtc.mds_lobby_state.player_ids.append(mds_webrtc.mds_player_state.player_id)
	mds_webrtc.mds_lobby_state.player_names_by_player_ids[mds_webrtc.mds_player_state.player_id] = mds_webrtc.mds_player_state.player_name
	mds_webrtc.mds_lobby_state.emit_changed()
	mds_webrtc.lobby_created.emit()
