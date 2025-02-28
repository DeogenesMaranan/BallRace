extends Node2D

@onready var wall_generator = $WallGenerator
@onready var turn_manager = $TurnManager

func _ready():
	var viewport_rect = get_viewport_rect()
	wall_generator.generate_walls(viewport_rect)
	turn_manager.turn_switched.connect(_on_turn_switched)

func _on_joystick_input_received(input_vector: Vector2):
	if not turn_manager.are_balls_moving():
		print(turn_manager.get_current_player())
		turn_manager.get_current_player().apply_input(input_vector)
		turn_manager.switch_turn()

func _on_turn_switched(_current_player: RigidBody2D):
	pass

func _process(_delta: float):
	turn_manager.process_turn_state()
