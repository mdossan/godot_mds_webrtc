class_name MdsLobbyState extends Resource

var is_host: bool = false
var players: Array[String] = []
var ready_players: Dictionary[int, bool] = {}
var player_names_by_player_ids: Dictionary[int, String] = {}
