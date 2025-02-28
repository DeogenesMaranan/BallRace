extends Node2D

@export var collision_margin: int = 10
@export var wall_color: Color = Color.RED

@onready var player1 = $Player1
@onready var player2 = $Player2
@onready var turn_label = $HUD/TopCenter/CurrentPlayer
@onready var joystick = $HUD/BotCenter/Joystick

var current_player: RigidBody2D
var players: Array

func _ready():
	var viewport_rect = get_viewport_rect()
	var width = viewport_rect.size.x
	var height = viewport_rect.size.y
	
	# Create walls
	_create_wall(Vector2(width / 2, -collision_margin / 2), width, collision_margin)  # Top
	_create_wall(Vector2(width / 2, height + collision_margin / 2), width, collision_margin)  # Bottom
	_create_wall(Vector2(-collision_margin / 2, height / 2), collision_margin, height)  # Left
	_create_wall(Vector2(width + collision_margin / 2, height / 2), collision_margin, height)  # Right

	players = [player1, player2]
	current_player = player1
	_update_turn_label()
	_highlight_current_player()

func _create_wall(position: Vector2, w: int, h: int):
	var wall = StaticBody2D.new()
	wall.position = position
	
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(w, h)
	shape.shape = rect
	
	var visual = ColorRect.new()
	visual.size = Vector2(w, h)
	visual.color = wall_color
	visual.position = Vector2(-w / 2, -h / 2)

	wall.add_child(shape)
	wall.add_child(visual)
	add_child(wall)

func _on_joystick_input_received(input_vector: Vector2):
	if not _are_balls_moving():
		current_player.apply_input(input_vector)
		switch_turn()

func switch_turn():
	var current_index = players.find(current_player)
	current_index = (current_index + 1) % players.size()
	current_player = players[current_index]
	_update_turn_label()
	_highlight_current_player()

func _update_turn_label():
	turn_label.text = "Player 1's Turn" if current_player == player1 else "Player 2's Turn"

func _highlight_current_player():
	player1.get_node("Sprite2D").modulate = Color(1, 1, 1, 0.5)
	player2.get_node("Sprite2D").modulate = Color(1, 1, 1, 0.5)
	current_player.get_node("Sprite2D").modulate = Color.WHITE

func _are_balls_moving() -> bool:
	for player in players:
		if player.linear_velocity.length() > 5:
			return true
	return false

func _process(delta: float):
	if _are_balls_moving():
		joystick.set_enabled(false)
		joystick.modulate = Color(1, 1, 1, 0.1)
	else:
		joystick.set_enabled(true)
		joystick.modulate = Color.WHITE
