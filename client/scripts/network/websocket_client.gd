extends Node

const Packet = preload("res://scripts/network/packet.gd")

signal connected
signal data
signal disconnected
signal error

var _client = WebSocketClient.new()

func _ready():
	_client.connect("connection_closed", self, "_closed")
	_client.connect("connection_error", self, "_closed")
	_client.connect("connection_established", self, "_connected")
	_client.connect("data_received", self, "_on_data_received")

func _process(delta):
	_client.poll()

func connect_to_server(hostname: String, port: int) -> void:
	# соединяемся с сервером и посылаем соотв. сигнал
	var websocket_url = "ws://" + str(hostname) + ":" + str(port)
	var err = _client.connect_to_url(websocket_url)
	if err:
		print("Unable to connect")
		set_process(false)
		emit_signal("error")

#func send_packet(packet: Packet):
func send_packet(packet: Packet):
	# отправляет пакет на сервер
	_send_string(packet.to_string())

func _closed(was_clean = false):
	print("Connection closed, clean: " + str(was_clean))
	set_process(false)
	emit_signal("disconnected", was_clean)

func _connected(protocol = ""):
	print("Connected with protocol: ", protocol)
	emit_signal("connected")

func _on_data_received():
	var data: String = _client.get_peer(1).get_packet().get_string_from_utf8()
	print("Got data from server: ", data)
	emit_signal("data")

func _send_string(string: String):
	_client.get_peer(1).put_packet(string.to_utf8())
	print("Sent string: ", string)
