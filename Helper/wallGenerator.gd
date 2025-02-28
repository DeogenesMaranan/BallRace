extends Node2D

@export var collision_margin: int = 100
@export var wall_color: Color = Color.RED
@export var finish_line_color: Color = Color.GREEN
const FINISH_SIZE_HORIZONTAL = Vector2(200, 100)
const FINISH_SIZE_VERTICAL = Vector2(100, 200)
@onready var obstacle_generator: Node2D = $"../ObstacleGenerator"
@onready var win_screen: Control = $"../HUD/Center/WinScreen"

signal finish_line_reached

func generate_walls(viewport_rect: Rect2):
	var width = viewport_rect.size.x * 4
	var height = viewport_rect.size.y * 4
	
	# Randomly choose finish line wall and generate position
	var finish_wall = ["top", "bottom", "left", "right"][randi() % 4]
	var finish_pos: Vector2
	var finish_size: Vector2
	
	match finish_wall:
		"top":
			finish_size = FINISH_SIZE_HORIZONTAL
			finish_pos = Vector2(randf_range(finish_size.x/2, width - finish_size.x/2), -collision_margin/2.0)
		"bottom":
			finish_size = FINISH_SIZE_HORIZONTAL
			finish_pos = Vector2(randf_range(finish_size.x/2, width - finish_size.x/2), height + collision_margin/2.0)
		"left":
			finish_size = FINISH_SIZE_VERTICAL
			finish_pos = Vector2(-collision_margin/2.0, randf_range(finish_size.y/2, height - finish_size.y/2))
		"right":
			finish_size = FINISH_SIZE_VERTICAL
			finish_pos = Vector2(width + collision_margin/2.0, randf_range(finish_size.y/2, height - finish_size.y/2))
	
	# Generate all walls with abstract shapes
	_generate_wall_with_finish(width, height, finish_wall, finish_pos, finish_size)
	_generate_corner_rectangles(width, height)  # Add rectangles in the corners
	obstacle_generator.generate_obstacles(viewport_rect)

func _generate_wall_with_finish(width: float, height: float, wall_side: String, finish_pos: Vector2, finish_size: Vector2):
	match wall_side:
		"top":
			_generate_abstract_horizontal(finish_pos.x - finish_size.x/2, 0, -collision_margin/2.0, true)  # Left segment
			_generate_abstract_horizontal(width - (finish_pos.x + finish_size.x/2), finish_pos.x + finish_size.x/2, -collision_margin/2.0, true)  # Right segment
			_generate_vertical_wall(height, -collision_margin/2.0, true)  # Left wall
			_generate_vertical_wall(height, width + collision_margin/2.0, false)  # Right wall
			_generate_abstract_horizontal(width, 0, height + collision_margin/2.0, false)  # Bottom wall
		"bottom":
			_generate_abstract_horizontal(finish_pos.x - finish_size.x/2, 0, height + collision_margin/2.0, false)  # Left segment
			_generate_abstract_horizontal(width - (finish_pos.x + finish_size.x/2), finish_pos.x + finish_size.x/2, height + collision_margin/2.0, false)  # Right segment
			_generate_vertical_wall(height, -collision_margin/2.0, true)  # Left wall
			_generate_vertical_wall(height, width + collision_margin/2.0, false)  # Right wall
			_generate_abstract_horizontal(width, 0, -collision_margin/2.0, true)  # Top wall
		"left":
			_generate_abstract_vertical(finish_pos.y - finish_size.y/2, 0, -collision_margin/2.0, true)  # Top segment
			_generate_abstract_vertical(height - (finish_pos.y + finish_size.y/2), finish_pos.y + finish_size.y/2, -collision_margin/2.0, true)  # Bottom segment
			_generate_horizontal_wall(width, -collision_margin/2.0, true)  # Top wall
			_generate_horizontal_wall(width, height + collision_margin/2.0, false)  # Bottom wall
			_generate_abstract_vertical(height, 0, width + collision_margin/2.0, false)  # Right wall
		"right":
			_generate_abstract_vertical(finish_pos.y - finish_size.y/2, 0, width + collision_margin/2.0, false)  # Top segment
			_generate_abstract_vertical(height - (finish_pos.y + finish_size.y/2), finish_pos.y + finish_size.y/2, width + collision_margin/2.0, false)  # Bottom segment
			_generate_horizontal_wall(width, -collision_margin/2.0, true)  # Top wall
			_generate_horizontal_wall(width, height + collision_margin/2.0, false)  # Bottom wall
			_generate_abstract_vertical(height, 0, -collision_margin/2.0, true)  # Left wall
	
	_create_finish_line(finish_pos, finish_size)

func _generate_abstract_horizontal(length: float, start_x: float, y_pos: float, is_top: bool):
	var segment_base = 80.0
	var current_x = start_x
	while length > 0:
		var segment_width = min(randf_range(50, 100), length)
		var segment_height = collision_margin * randf_range(0.8, 1.2)
		var y_offset = y_pos + (collision_margin/2.0 * (-1 if is_top else 1))
		
		var wall = StaticBody2D.new()
		wall.position = Vector2(current_x + segment_width/2, y_offset)
		
		var shape = CollisionShape2D.new()
		shape.shape = RectangleShape2D.new()
		shape.shape.size = Vector2(segment_width, segment_height)
		
		var visual = ColorRect.new()
		visual.size = shape.shape.size
		visual.color = wall_color
		visual.position = -shape.shape.size/2
		
		wall.add_child(shape)
		wall.add_child(visual)
		add_child(wall)
		
		current_x += segment_width
		length -= segment_width

func _generate_abstract_vertical(height: float, start_y: float, x_pos: float, is_left: bool):
	var segment_base = 80.0
	var current_y = start_y
	while height > 0:
		var segment_height = min(randf_range(50, 100), height)
		var segment_width = collision_margin * randf_range(0.8, 1.2)
		var x_offset = x_pos + (collision_margin/2.0 * (-1 if is_left else 1))
		
		var wall = StaticBody2D.new()
		wall.position = Vector2(x_offset, current_y + segment_height/2)
		
		var shape = CollisionShape2D.new()
		shape.shape = RectangleShape2D.new()
		shape.shape.size = Vector2(segment_width, segment_height)
		
		var visual = ColorRect.new()
		visual.size = shape.shape.size
		visual.color = wall_color
		visual.position = -shape.shape.size/2
		
		wall.add_child(shape)
		wall.add_child(visual)
		add_child(wall)
		
		current_y += segment_height
		height -= segment_height

func _generate_vertical_wall(height: float, x_pos: float, is_left: bool):
	_generate_abstract_vertical(height + collision_margin, -collision_margin/2.0, x_pos, is_left)

func _generate_horizontal_wall(width: float, y_pos: float, is_top: bool):
	_generate_abstract_horizontal(width + collision_margin, -collision_margin/2.0, y_pos, is_top)

func _generate_corner_rectangles(width: float, height: float):
	var corner_positions = [
		Vector2(-collision_margin/2.0, -collision_margin/2.0),  # Top-left
		Vector2(width + collision_margin/2.0, -collision_margin/2.0),  # Top-right
		Vector2(-collision_margin/2.0, height + collision_margin/2.0),  # Bottom-left
		Vector2(width + collision_margin/2.0, height + collision_margin/2.0)  # Bottom-right
	]
	
	for pos in corner_positions:
		var rect_size = Vector2(randf_range(75, 100), randf_range(75, 100))
		var rect = StaticBody2D.new()
		rect.position = pos
		
		var shape = CollisionShape2D.new()
		shape.shape = RectangleShape2D.new()
		shape.shape.size = rect_size
		
		var visual = ColorRect.new()
		visual.size = rect_size
		visual.color = wall_color
		visual.position = -rect_size/2
		
		rect.add_child(shape)
		rect.add_child(visual)
		add_child(rect)

func _create_finish_line(pos: Vector2, size: Vector2):
	var finish_line = StaticBody2D.new()
	finish_line.position = pos
	
	# Wall collision
	var wall_shape = CollisionShape2D.new()
	wall_shape.shape = RectangleShape2D.new()
	wall_shape.shape.size = size
	finish_line.add_child(wall_shape)
	
	# Visual
	var visual = ColorRect.new()
	visual.size = size
	visual.color = finish_line_color
	visual.position = -size/2
	finish_line.add_child(visual)
	
	# Detection area
	var area = Area2D.new()
	var area_shape = CollisionShape2D.new()
	area_shape.shape = wall_shape.shape.duplicate()
	area.add_child(area_shape)
	area.connect("body_entered", _on_finish_area_entered)
	finish_line.add_child(area)
	
	add_child(finish_line)

func _on_finish_area_entered(body):
	if body is Player:
		print(body.name + " reached the finish line! 🎉")
		if body.name == "Player1":
			win_screen.show_winner("Player 1")
		else:
			win_screen.show_winner("Player 2")
		emit_signal("finish_line_reached")
