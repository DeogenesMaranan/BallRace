extends Sprite2D

@onready var parent = $".."

var pressing = false
var last_posVector = Vector2.ZERO
var moved = false

@export var maxLength = 200
@export var deadZone = 5

signal input_received(input_vector: Vector2)

func _ready() -> void:
	maxLength *= parent.scale.x

func _process(_delta: float) -> void:
	if parent.is_joystick_enabled():
		if pressing:
			moved = true
			if get_global_mouse_position().distance_to(parent.global_position) <= maxLength:
				global_position = get_global_mouse_position()
			else:
				var angle = parent.global_position.angle_to_point(get_global_mouse_position())
				global_position.x = parent.global_position.x + cos(angle) * maxLength
				global_position.y = parent.global_position.y + sin(angle) * maxLength
		else:
			global_position = global_position.lerp(parent.global_position, 0.2)
	else:
		global_position = parent.global_position

func calculateVector():
	var new_posVector = Vector2.ZERO
	
	if abs(global_position.x - parent.global_position.x) >= deadZone:
		new_posVector.x = (global_position.x - parent.global_position.x) / maxLength
	if abs(global_position.y - parent.global_position.y) >= deadZone:
		new_posVector.y = (global_position.y - parent.global_position.y) / maxLength
	
	if new_posVector != Vector2.ZERO:
		last_posVector = new_posVector

func _on_button_button_down() -> void:
	if parent.is_joystick_enabled():
		pressing = true
		moved = false

func _on_button_button_up() -> void:
	if pressing:
		pressing = false
		if moved:
			calculateVector()
			emit_signal("input_received", last_posVector)
		moved = false
