extends Object

var Action: String
var Payloads: Array

func _init(action: String, payloads: Array):
	Action = action
	Payloads = payloads

func tostring() -> String:
	var serialize_dict: Dictionary = {"a": Action}
	for i in range(len(Payloads)):
		serialize_dict["p%d" % i] = Payloads[i]
	var data: String = JSON.print(serialize_dict)
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
