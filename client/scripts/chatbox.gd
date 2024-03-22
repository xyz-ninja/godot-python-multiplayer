extends Control

onready var chat_log = $CanvasLayer/Chat/Log
onready var input_field = $CanvasLayer/Chat/InputBlock/InputField

signal message_sent(message)

func _ready():
	input_field.connect("text_entered", self, "text_entered")

func _input(event: InputEvent):
	if event is InputEventKey and event.pressed:
		match event.scancode:
			KEY_ENTER:
				input_field.grab_focus()
			KEY_ESCAPE:
				input_field.release_focus()

func add_message(text: String):
	chat_log.bbcode_text += text + "\n"

func text_entered(text: String):
	if len(text) > 0:
		input_field.text = ""

		emit_signal("message_sent", text)