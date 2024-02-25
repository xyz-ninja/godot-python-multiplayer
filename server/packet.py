import json
import enum

class Action(enum.Enum):
	pass

class Packet:
	def __init__(self, action: Action, *payloads):
		self.action: Action = action
		self.payloads: tuple = payloads

	# позволяет использовать str() на объекте класса
	def __str__(self) -> str:
		# example:
		# {
		#	"action" : "Login"
		#	"p0" : "Password",
		# }
		
		serialize_dict = { "action"  : self.action.name}
		
		for i in range(len(self.payloads)):
			serialize_dict[f'p{i}'] = self.payloads[i]
		
		data = json.dumps(serialize_dict, separators=(',', ': '))

		return data
	
	def __bytes__(self) -> bytes:
		return str(self).encode('utf-8')
	

def from_json(json_str: str) -> Packet:
	obj_dict = json.loads(json_str)

	action = None
	payloads = []

	for key, value in obj_dict.items():
		if key == 'action':
			action = value
		elif key[0] == 'p':
			index = int(key[1:])
			payloads.insert(index, value)

	# используем рефлексию что бы создать специфичный тип пакета который нам нужен
	class_name = action + "Packet"

	try:
		constructor: type = globals()[class_name]
		return constructor(*payloads)
	except KeyError as e:
		print(f"{class_name} is not a valid packet name. Stacktrace {e}")
	except TypeError:
		print(f"{class_name} can't handle arguments {tuple(payloads)}")