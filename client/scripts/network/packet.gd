extends Object

var _action: String
var _payloads: Array

func _init(action: String, payloads: Array):
	_action = action
	_payloads = payloads

func tostring() -> String:
	var serlialize_dict: Dictionary = {"a": _action}
	for i in range(len(_payloads)):
		serlialize_dict["p%d" % i] = _action[i]
	var data: String = JSON.print(serlialize_dict)
	return data

static func json_to_action_payloads(json_str: String) -> Array:
	var action: String
	var payloads: Array = []
	var obj_dict: Dictionary = JSON.parse(json_str).result

	for key in obj_dict.keys():
		var value = obj_dict[key]
		if key == "a":
			action = value
		elif key[0] == "p":
			var index: int = key.split_floats("p", true)[1]
			payloads.insert(index, value)

	return [action, payloads]
