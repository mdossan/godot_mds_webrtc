class_name NewAnswerHandler

static func handle(mds_webrtc: MdsWebRTC, data: Dictionary) -> void:
	var source_player_id: int = data.get("sourcePlayerId")
	var sdp: String = data.get("sdp")
	var remote_peer: WebRTCPeerConnection = mds_webrtc.webrtc.get_peer(source_player_id).get("connection")
	remote_peer.set_remote_description("answer", sdp)
