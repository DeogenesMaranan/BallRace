extends Node2D

@onready var wall_generator = $WallGenerator
@onready var turn_manager = $TurnManager
@onready var win_screen: Control = $HUD/Center/WinScreen

func _ready():
	var viewport_rect = get_viewport_rect()
	wall_generator.generate_walls(viewport_rect)
	win_screen.restart_game.connect(_restart_game)
	win_screen.quit_game.connect(_quit_game)
	
func _on_joystick_input_received(input_vector: Vector2):
	if not turn_manager.are_balls_moving():
		turn_manager.get_current_player().apply_input(input_vector)
		turn_manager.switch_turn()

func _process(_delta: float):
	turn_manager.process_turn_state()
	
func _restart_game():
	get_tree().reload_current_scene()

func _quit_game():
	get_tree().quit()
