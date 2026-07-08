class_name SocketMessageHandler

static func handle_new_message(mds_socket: MdsSocketClient, mds_webrtc: MdsWebRTC) -> void:
	var packet = mds_socket.socket.get_packet()
	if mds_socket.socket.was_string_packet():
		var packet_text = packet.get_string_from_utf8()
		var data: Dictionary = JSON.parse_string(packet_text)
		match data.get("type"):
			"REGISTERED":
				RegisteredHandler.handle(mds_webrtc)
			"LOBBIES":
				LobbiesHandler.handle(mds_webrtc, data)
			"PLAYER_JOINED":
				PlayerJoinedHandler.handle(mds_webrtc, data)
			"LOBBY_CREATED":
				LobbyCreatedHandler.handle(mds_webrtc, data)
			"NEW_OFFER":
				NewOfferHandler.handle(mds_webrtc, data)
			"NEW_ANSWER":
				NewAnswerHandler.handle(mds_webrtc, data)
			"NEW_ICE":
				NewIceHandler.handle(mds_webrtc, data)
			"LOBBY_JOINED":
				LobbyJoinedHandler.handle(mds_webrtc, data)
	else:
		print("< Got binary data from server: %d bytes" % packet.size())
