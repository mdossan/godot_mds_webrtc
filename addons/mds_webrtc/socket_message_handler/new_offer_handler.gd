class_name NewOfferHandler

static func handle(mds_webrtc: MdsWebRTC, data: Dictionary) -> void:
	var sdp: String = data.get("sdp")
	var offering_player_id: int = data.get("offeringPlayerId")
	mds_webrtc.create_webrtc_connection_from_offer(offering_player_id, sdp)
