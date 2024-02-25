import queue
from server import packet
from autobahn.twisted.websocket import WebSocketServerProtocol

class GameServerProtocol(WebSocketServerProtocol):
	def __init__(self):
		super().__init__()
		self._packet_queue: queue.Queue[tuple['GameServerProtocol', 'packet.Packet']] = queue.Queue()
		self._state: callable = None
	
	def PLAY(self, sender: 'GameServerProtocol', p: packet.Packet):
		pass

	def tick(self):
		# process next packet in queue
		if not self._packet_queue.empty():
			server_protocol, packet = self._packet_queue.get()
			self._state(server_protocol, packet)

	def broadcast(self, packet: packet.Packet, exclude_self: bool = False):
		for other in self.factory.players:
			if other == self and exclude_self:
				other.onPacket(self, packet)

	def send_client(self, packet: packet.Packet):
		b = bytes(packet)
		self.sendMessage(b)

	def onPacket(self, sender: 'GameServerProtocol', packet: packet.Packet):
		self._packet_queue.put((sender, packet))
		print(f'Queue packet: {packet}')

	#override
	def onConnect(self, request):
		print(f"Client connected: {request.Peer}")

	#override
	def onOpen(self):
		print(f"WebSocket connection established!")
		self._state = self.PLAY

	#override
	def onClose(self, wasClean, code, reason):
		self.factory.players.remove(self)
		print(f"Websockets connection closed {"unexpectly" if not wasClean else "cleanly"} with code {code}: {reason}")

	def onMessage(self, payload, isBinary):
		decoded_payload = payload.decode('utf-8')

		try:
			json_packet: packet.Packet = packet.from_json(decoded_payload)
		except Exception as e:
			print(f"Could not load message as packet: {e}. Message was: {decoded_payload}")

		self.onPacket(self, json_packet)
