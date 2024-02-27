extends Node2D

const NetworkClient = preload("res://scripts/network/websocket_client.gd")
const Packet = preload("res://scripts/network/packet.gd")

onready var _network_client = NetworkClient.new()
var state: FuncRef

func _ready():
	_network_client.connect("connected", self, "_handle_client_connected")
	_network_client.connect("disconnected", self, "_handle_client_disconnected")
	_network_client.connect("error", self, "_handle_network_error")
	_network_client.connect("data", self, "_handle_network_data")

	add_child(_network_client)

	_network_client.connect_to_server("127.0.0.1", 8081)

	state = funcref(self, "PLAY")

func PLAY(packet):
	pass

func _handle_client_connected():
	print("Client connected to server!")

func _handle_client_disconnected(was_clean): 
	OS.alert("Client disconnected %s" % ["cleanly" if was_clean else "unexpected"])
	get_tree().quit()

func _handle_network_error():
	OS.alert("That was an error")

func _handle_network_data(data: String):
	print("Received server data ", data)
	var action_payloads: Array = Packet.json_to_action_payloads(data)
	var packet: Packet = Packet.new(action_payloads[0], action_payloads[1])
	state.call_func(packet)
