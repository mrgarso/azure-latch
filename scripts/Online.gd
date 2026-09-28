extends Node
#online autoload

var myself: Player = null
var name_id := ""
var players := {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


func host(port: int) -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_server(port)
	if err != OK:
		push_error("host failed: %s" % err)
		return
	multiplayer.multiplayer_peer = peer

func join(ip:String, port:int) -> void:
	var peer := ENetMultiplayerPeer.new()
	var err := peer.create_client(ip, port)
	if err != OK:
		push_error("le join failed: %s" % err)
		return
	multiplayer.multiplayer_peer = peer

@warning_ignore("unused_parameter")
func _on_peer_connected(id: int) -> void:
	pass

func _on_peer_disconnected(id: int) -> void:
	if players.has(id):
		players[id].queue_free()
		players.erase(id)
