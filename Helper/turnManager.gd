extends Node

signal turn_switched(current_player: RigidBody2D)

@onready var player1: RigidBody2D = $"../Player1"
@onready var player2: RigidBody2D = $"../Player2"
@onready var joystick: Node2D = $"../HUD/BotCenter/Joystick"
@onready var turn_label: Label = $"../HUD/TopCenter/CurrentPlayer"
@onready var players: Array[RigidBody2D] = [player1, player2]
@onready var current_player: RigidBody2D

var tween: Tween

func _ready():
	if players.size() > 0:
		current_player = players[0]
		_update_turn_label()
		_highlight_current_player()

func switch_turn():
	var current_index = players.find(current_player)
	current_index = (current_index + 1) % players.size()
	current_player = players[current_index]
	emit_signal("turn_switched", current_player)
	_update_turn_label()
	_highlight_current_player()

func get_current_player() -> RigidBody2D:
	return current_player

func set_players(new_players: Array[RigidBody2D]):
	players = new_players
	if players.size() > 0:
		current_player = players[0]
		_update_turn_label()
		_highlight_current_player()

func _update_turn_label():
	if turn_label:
		turn_label.text = "Player 1's Turn" if current_player == players[0] else "Player 2's Turn"

func _highlight_current_player():
	for player in players:
		player.get_node("Sprite2D").modulate = Color(1, 1, 1, 0.5)  # Dim all players
	current_player.get_node("Sprite2D").modulate = Color.WHITE  # Highlight the current player

func start_fade(target_color: Color):
	if tween and tween.is_running():
		tween.kill()
	
	tween = get_tree().create_tween()
	tween.tween_property(joystick, "modulate", target_color, 0.3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func are_balls_moving() -> bool:
	for player in players:
		if player.linear_velocity.length() > 5:
			return true
	return false

func process_turn_state():
	if are_balls_moving():
		if joystick.is_joystick_enabled():
			joystick.set_enabled(false)
			start_fade(Color(1, 1, 1, 0.1))
	else:
		if not joystick.is_joystick_enabled():
			start_fade(Color.WHITE)
			joystick.set_enabled(true)
