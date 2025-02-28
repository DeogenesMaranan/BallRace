extends Node2D

@onready var knob = $Knob
var is_enabled = true

func _ready():
	knob.connect("input_received", Callable(self, "_on_input_received"))

func _on_input_received(input_vector: Vector2):
	get_parent().get_parent().get_parent()._on_joystick_input_received(input_vector)

func is_joystick_enabled() -> bool:
	return is_enabled

func set_enabled(enabled: bool):
	is_enabled = enabled
	if not enabled:
		knob.global_position = global_position
