class_name LobbiesHandler

static func handle(mds_webrtc: MdsWebRTC, data: Dictionary) -> void:
	var lobbies: Array[Dictionary] = []
	lobbies.assign(data.get("lobbies"))
	mds_webrtc.received_lobbies.emit(lobbies)
	mds_webrtc.mds_available_state.lobbies = lobbies
	mds_webrtc.mds_available_state.emit_changed()
	print_debug("[MdsWebRTC][%s]: Receiving `RESULT_LIST_LOBBIES` event from signaling server" % mds_webrtc.mds_player_state.player_id)
