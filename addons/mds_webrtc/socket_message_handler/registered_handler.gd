class_name RegisteredHandler

static func handle(mds_webrtc: MdsWebRTC):
	mds_webrtc.socket_ready.emit()
	print_debug("[MdsWebRTC][%s]: Receiving `REGISTERED` event from signaling server" % mds_webrtc.mds_player_state.player_id)
