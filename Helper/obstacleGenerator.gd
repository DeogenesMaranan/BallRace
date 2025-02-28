extends Node2D

@export_group("Dynamic Obstacles")
@export var dynamic_min_count: int = 75
@export var dynamic_max_count: int = 100
@export var dynamic_min_size: float = 5.0
@export var dynamic_max_size: float = 50.0
@export var dynamic_color: Color = Color.BLUE
@export var dynamic_collision_margin: int = 100

@export_group("Static Obstacles")
@export var static_min_count: int = 75
@export var static_max_count: int = 100
@export var static_min_size: float = 5.0
@export var static_max_size: float = 50.0
@export var static_color: Color = Color.BLACK
@export var static_collision_margin: int = 100

@export var min_spacing: float = 30.0
@export var max_placement_attempts: int = 100

var existing_obstacles = []

func generate_obstacles(viewport_rect: Rect2):
	var width = viewport_rect.size.x * 4
	var height = viewport_rect.size.y * 4
	existing_obstacles.clear()
	
	# Generate dynamic obstacles
	var dynamic_count = randi_range(dynamic_min_count, dynamic_max_count)
	_generate_obstacles(dynamic_count, width, height, true)
	
	# Generate static obstacles
	var static_count = randi_range(static_min_count, static_max_count)
	_generate_obstacles(static_count, width, height, false)

func _generate_obstacles(count: int, width: float, height: float, is_dynamic: bool):
	for _i in range(count):
		var placed = false
		var attempts = 0
		
		while attempts < max_placement_attempts and not placed:
			attempts += 1
			# Generate position
			var position = _generate_position(width, height, is_dynamic)
			
			# Generate size parameters
			var size = _generate_size(is_dynamic)
			
			# Check collisions
			if not _check_collision(position, size, is_dynamic):
				# Add obstacle to scene and tracking list
				if is_dynamic:
					_create_dynamic_obstacle(position, size)
					existing_obstacles.append({
						"type": "dynamic",
						"position": position,
						"radius": size
					})
				else:
					_create_static_obstacle(position, size)
					existing_obstacles.append({
						"type": "static",
						"position": position,
						"size": size
					})
				placed = true

func _generate_position(width: float, height: float, is_dynamic: bool) -> Vector2:
	var margin = dynamic_collision_margin if is_dynamic else static_collision_margin
	return Vector2(
		randf_range(margin, width - margin),
		randf_range(margin, height - margin)
	)

func _generate_size(is_dynamic: bool):
	if is_dynamic:
		return randf_range(dynamic_min_size, dynamic_max_size)
	else:
		return Vector2(
			randf_range(static_min_size, static_max_size),
			randf_range(static_min_size, static_max_size)
		)

func _check_collision(position: Vector2, size, is_dynamic: bool) -> bool:
	for obstacle in existing_obstacles:
		if is_dynamic:
			var dynamic_radius = size + min_spacing
			if obstacle.type == "dynamic":
				var existing_radius = obstacle.radius + min_spacing
				if _circles_overlap(position, dynamic_radius, obstacle.position, existing_radius):
					return true
			else:
				var existing_size = obstacle.size + Vector2.ONE * min_spacing * 2
				if _circle_rect_overlap(position, dynamic_radius, obstacle.position, existing_size):
					return true
		else:
			var static_size = size + Vector2.ONE * min_spacing * 2
			if obstacle.type == "dynamic":
				var existing_radius = obstacle.radius + min_spacing
				if _circle_rect_overlap(obstacle.position, existing_radius, position, static_size):
					return true
			else:
				var existing_size = obstacle.size + Vector2.ONE * min_spacing * 2
				if _rects_overlap(position, static_size, obstacle.position, existing_size):
					return true
	return false

func _circles_overlap(pos1: Vector2, radius1: float, pos2: Vector2, radius2: float) -> bool:
	return pos1.distance_to(pos2) < (radius1 + radius2)

func _circle_rect_overlap(circle_pos: Vector2, circle_radius: float, rect_pos: Vector2, rect_size: Vector2) -> bool:
	var rect_half = rect_size / 2
	var rect_min = rect_pos - rect_half
	var rect_max = rect_pos + rect_half
	
	var closest_x = clamp(circle_pos.x, rect_min.x, rect_max.x)
	var closest_y = clamp(circle_pos.y, rect_min.y, rect_max.y)
	
	var distance_squared = pow(circle_pos.x - closest_x, 2) + pow(circle_pos.y - closest_y, 2)
	return distance_squared < pow(circle_radius, 2)

func _rects_overlap(rect1_pos: Vector2, rect1_size: Vector2, rect2_pos: Vector2, rect2_size: Vector2) -> bool:
	var rect1_min = rect1_pos - rect1_size/2
	var rect1_max = rect1_pos + rect1_size/2
	var rect2_min = rect2_pos - rect2_size/2
	var rect2_max = rect2_pos + rect2_size/2
	
	return (rect1_min.x < rect2_max.x and rect1_max.x > rect2_min.x and
			rect1_min.y < rect2_max.y and rect1_max.y > rect2_min.y)

func _create_dynamic_obstacle(position: Vector2, radius: float):
	var obstacle = RigidBody2D.new()
	obstacle.position = position
	obstacle.gravity_scale = 0
	
	var shape = CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.shape.radius = radius
	
	var visual = Sprite2D.new()
	visual.texture = _create_circle_texture(radius, dynamic_color)
	visual.position = Vector2(-radius, -radius)
	
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = 0.5
	obstacle.physics_material_override = physics_material
	
	obstacle.add_child(shape)
	obstacle.add_child(visual)
	add_child(obstacle)

func _create_static_obstacle(position: Vector2, size: Vector2):
	var obstacle = StaticBody2D.new()
	obstacle.position = position
	
	var shape = CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = size
	
	var visual = ColorRect.new()
	visual.size = size
	visual.color = static_color
	visual.position = Vector2(-size.x/2, -size.y/2)
	
	obstacle.add_child(shape)
	obstacle.add_child(visual)
	add_child(obstacle)

func _create_circle_texture(radius: float, color: Color) -> Texture2D:
	var image = Image.create(radius * 2, radius * 2, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	
	var center = Vector2(radius, radius)
	for x in image.get_width():
		for y in image.get_height():
			if Vector2(x, y).distance_to(center) <= radius:
				image.set_pixel(x, y, color)
	
	return ImageTexture.create_from_image(image)
