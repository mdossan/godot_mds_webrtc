class_name MdsHandshakeSync extends Node

signal player_to_sync_added(player_id: int)

@export var parent: Node3D
@export var remote_players_id: Array[int] = []

func _ready() -> void:
	if get_multiplayer_authority() == multiplayer.get_unique_id():
		multiplayer.peer_disconnected.connect(func(disconnected_player_id): remote_players_id.erase(disconnected_player_id))

	if get_multiplayer_authority() != multiplayer.get_unique_id():
		enable_sync_for_remote_player.rpc_id(get_multiplayer_authority(), multiplayer.get_unique_id())

@rpc("any_peer", "reliable")
func enable_sync_for_remote_player(remote_player_id: int):
	remote_players_id.push_back(remote_player_id)
	player_to_sync_added.emit(remote_player_id)
