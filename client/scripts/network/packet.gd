extends Object

var action: String
var payloads: Array

func _init(_action: String, _payloads: Array):
	action = _action
	payloads = _payloads

func to_string() -> String:
	var serialize_dict: Dictionary = {"a": action}
	for i in range(len(payloads)):
		serialize_dict["p" + str(i)] = payloads[i]
	
	var data: String = JSON.print(serialize_dict)
	return data

static func json_to_action_payloads(json: String) -> Array:
	var result_action: String
	var result_payloads: Array = []
	var obj_dict: Dictionary = JSON.parse(json).result

	for key in obj_dict.keys():
		var value = obj_dict[key]
		if key == "a":
			result_action = value
		elif key[0] == "p":
			var index = key.split_floats('p', true)[1]
			result_payloads.insert(index, value)

	return [result_action, result_payloads]
