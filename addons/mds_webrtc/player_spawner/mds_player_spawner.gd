@abstract class_name MdsPlayerSpawner extends Node3D

@abstract func create_player_instance(player_id: int) -> Node3D

# Host make an RPC to the player_id to make him spawn his player
# player_id now make rpc to all players to make them spawn his player
# remote players then ping to start synchronization

@export var mds_lobby_state: MdsLobbyState = preload("res://addons/mds_webrtc/mds_lobby_state.tres")

func init_players_spawn() -> void:
	for player_id in mds_lobby_state.player_ids:
		if player_id == get_multiplayer_authority():
			spawn_player(player_id)
		else:
			spawn_player.rpc_id(player_id, player_id)

@rpc("any_peer", "reliable")
func spawn_player(player_id: int):
	var player: Node3D = create_player_instance(player_id)
	player.name = "Player%s" % str(player_id)
	player.set_multiplayer_authority(player_id)
	add_child(player)
