extends Node2D

signal turn_switched(current_player: RigidBody2D)

@onready var players: Array[RigidBody2D] = [$"../Player1", $"../Player2"]
@onready var joystick: Node2D = $"../HUD/BotCenter/Joystick"
@onready var turn_label: Label = $"../HUD/TopCenter/CurrentPlayer"
@onready var current_player: RigidBody2D = players[0]
@onready var camera: Camera2D = $"../View"

var tween: Tween

func _ready():
	_update_ui()

func _process(_delta: float):
	if are_balls_moving():
		turn_label.text = "..."
		camera.position = get_moving_ball().position
	else:
		_update_ui()
		camera.position = current_player.position

func switch_turn():
	current_player = players[(players.find(current_player) + 1) % players.size()]
	emit_signal("turn_switched", current_player)
	_update_ui()

func get_current_player() -> RigidBody2D:
	return current_player

func set_players(new_players: Array[RigidBody2D]):
	players = new_players
	current_player = players[0]
	_update_ui()

func _update_ui():
	_update_turn_label()
	_highlight_current_player()
	_update_camera_focus()

func _update_turn_label():
	turn_label.text = "Player 1's Turn" if current_player == players[0] else "Player 2's Turn"

func _highlight_current_player():
	for player in players:
		player.get_node("Sprite2D").modulate = Color(1, 1, 1, 0.5)
	current_player.get_node("Sprite2D").modulate = Color.WHITE

func start_fade(target_color: Color):
	if tween and tween.is_running():
		tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(joystick, "modulate", target_color, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func are_balls_moving() -> bool:
	return players.any(func(p): return p.linear_velocity.length() > 5)

func get_moving_ball() -> RigidBody2D:
	return players.filter(func(p): return p.linear_velocity.length() > 5).front()

func process_turn_state():
	if are_balls_moving():
		if joystick.is_joystick_enabled():
			joystick.set_enabled(false)
			start_fade(Color(1, 1, 1, 0.1))
	else:
		if not joystick.is_joystick_enabled():
			start_fade(Color.WHITE)
			joystick.set_enabled(true)

func _update_camera_focus():
	if camera:
		camera.position = Vector2(camera.position.x, current_player.position.y)
