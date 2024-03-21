extends Node

const Packet = preload("res:///scripts/network/packet.gd")

signal connected
signal data
signal disconnected
signal error

var _client = WebSocketClient.new()

func _ready():
    _client.connect("connection_closed", self, "_closed")
    _client.connect("connection_error", self, "_closed")
    _client.connect("connection_established", self, "_connected")
    _client.connect("data_received", self, "_on_data")

func _process(delta):
    _client.poll()

func connect_to_server(hostname: String, port: int) -> void:
    var websocket_url = "ws://%s:%d" % [hostname, port]
    var err = _client.connect_to_url(websocket_url)
    if err:
        print("Unable to connect")
        set_process(false)
        emit_signal("error")

func send_packet(packet: Packet) -> void:
    _send_string(packet.tostring())

func _closed(was_clean = false):
    print("Closed, clean: ", was_clean)
    set_process(false)
    emit_signal("disconnected", was_clean)

func _connected(proto = ""):
    print("Connected with protocol: ", proto)
    emit_signal("connected")

func _on_data():
    var data: String = _client.get_peer(1).get_packet().get_string_from_utf8()
    print("Got data from server: ", data)
    emit_signal("data", data)

func _send_string(string: String) -> void:
    _client.get_peer(1).put_packet(string.to_utf8())
    print("Sent string ", string)