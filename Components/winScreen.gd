extends Control

@onready var overlay = $ColorRect
@onready var winner_label = $PopUp/WinnerLabel
@onready var play_again_button = $PopUp/PlayAgainButton
@onready var quit_button = $PopUp/QuitButton

signal restart_game
signal quit_game

func _ready():
	play_again_button.pressed.connect(_on_play_again_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	hide()

func show_winner(player_name: String):
	winner_label.text = player_name + " Wins!"
	overlay.color = Color(0, 0, 0, 0.9)
	show()

func _on_play_again_pressed():
	emit_signal("restart_game")

func _on_quit_pressed():
	emit_signal("quit_game")
