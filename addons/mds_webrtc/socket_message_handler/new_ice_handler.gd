class_name NewIceHandler

static func handle(mds_webrtc: MdsWebRTC, data: Dictionary) -> void:
	var source_player_id: int = data.get("sourcePlayerId")
	var media: String = data.get("media")
	var index: int = data.get("index")
	var ice_name: String = data.get("name")
	var remote_peer: WebRTCPeerConnection = mds_webrtc.webrtc.get_peer(source_player_id).get("connection")
	var err = remote_peer.add_ice_candidate(media, index, ice_name)
	assert(err == OK, "CANT ADD ICE %s" % err)
