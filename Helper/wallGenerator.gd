extends Node2D

@export var collision_margin: int = 50
@export var wall_color: Color = Color.RED
@onready var finish_line: Node2D = $"../FinishLineGenerator"

func generate_walls(viewport_rect: Rect2):
	var width = viewport_rect.size.x * 4
	var height = viewport_rect.size.y * 4
	
	_create_wall(Vector2(width / 2.0, -collision_margin / 2.0), width, collision_margin)  # Top
	_create_wall(Vector2(width / 2.0, height + collision_margin / 2.0), width, collision_margin)  # Bottom
	_create_wall(Vector2(-collision_margin / 2.0, height / 2.0), collision_margin, height)  # Left
	_create_wall(Vector2(width + collision_margin / 2.0, height / 2.0), collision_margin, height)  # Right

	finish_line.generate_finish_line(width, height)
	finish_line.connect("finish_line_reached", _on_finish_line_reached)
	add_child(finish_line)

func _create_wall(target_position: Vector2, w: int, h: int):
	var wall = StaticBody2D.new()
	wall.position = target_position
	
	var shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(w, h)
	shape.shape = rect
	
	var visual = ColorRect.new()
	visual.size = Vector2(w, h)
	visual.color = wall_color
	visual.position = Vector2(-w / 2.0, -h / 2.0)

	wall.add_child(shape)
	wall.add_child(visual)
	add_child(wall)

func _on_finish_line_reached():
	print("Finish line reached! Game over!")
