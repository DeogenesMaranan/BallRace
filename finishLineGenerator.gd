extends Node2D

@export var collision_margin: int = 50
@export var finish_line_color: Color = Color.GREEN
const FINISH_SIZE_HORIZONTAL = Vector2(150, 50)
const FINISH_SIZE_VERTICAL = Vector2(50, 150)
@onready var view: Camera2D = $"../View"

signal finish_line_reached

func generate_finish_line(width: int, height: int):
	var possible_positions = [
		# Top wall
		{"pos": Vector2(randf_range(FINISH_SIZE_HORIZONTAL.x / 2, width - FINISH_SIZE_HORIZONTAL.x / 2), -collision_margin / 2.0), "size": FINISH_SIZE_HORIZONTAL},
		# Bottom wall
		{"pos": Vector2(randf_range(FINISH_SIZE_HORIZONTAL.x / 2, width - FINISH_SIZE_HORIZONTAL.x / 2), height + collision_margin / 2.0), "size": FINISH_SIZE_HORIZONTAL},
		# Left wall
		{"pos": Vector2(-collision_margin / 2.0, randf_range(FINISH_SIZE_VERTICAL.y / 2, height - FINISH_SIZE_VERTICAL.y / 2)), "size": FINISH_SIZE_VERTICAL},
		# Right wall
		{"pos": Vector2(width + collision_margin / 2.0, randf_range(FINISH_SIZE_VERTICAL.y / 2, height - FINISH_SIZE_VERTICAL.y / 2)), "size": FINISH_SIZE_VERTICAL}
	]
	
	var chosen_wall = possible_positions[randi() % possible_positions.size()]

	var finish_line = StaticBody2D.new()
	finish_line.position = chosen_wall["pos"]

	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = chosen_wall["size"]
	shape.shape = rect

	var visual = ColorRect.new()
	visual.size = chosen_wall["size"]
	visual.color = finish_line_color
	visual.position = Vector2(-chosen_wall["size"].x / 2.0, -chosen_wall["size"].y / 2.0)

	var area = Area2D.new()
	area.connect("body_entered", _on_finish_line_reached)

	area.add_child(shape)
	finish_line.add_child(area)
	finish_line.add_child(visual)
	add_child(finish_line)

func _on_finish_line_reached(body):
	if body is Player:
		print(body.name + " reached the finish line! 🎉")
		emit_signal("finish_line_reached")
