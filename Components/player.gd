extends RigidBody2D

const SPEED = 3000.0
const FRICTION = 0.99
const BALL_RADIUS = 16.0
const MIN_SEPARATION = 1.1
const STOP_THRESHOLD = 5.0
const FORCE_MULTIPLIER = 1.5

func _ready() -> void:
	position.x = get_parent().get_viewport().size.x
	position.y = get_parent().get_viewport().size.y
	gravity_scale = 0
	linear_damp = 1.0
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = 1.0
	physics_material.friction = 0.1
	physics_material_override = physics_material

func _integrate_forces(_state: PhysicsDirectBodyState2D) -> void:
	linear_velocity *= FRICTION
	
	if linear_velocity.length() < STOP_THRESHOLD:
		linear_velocity = Vector2.ZERO

func apply_input(input_vector: Vector2):
	linear_velocity = input_vector * SPEED * FORCE_MULTIPLIER

func _on_body_entered(other: Node):
	if other is RigidBody2D:
		handle_ball_collision(other)
	elif other is StaticBody2D:
		handle_wall_collision(other)

func handle_ball_collision(other: RigidBody2D):
	var m1 = mass if mass > 0 else 1.0
	var m2 = other.mass if other.mass > 0 else 1.0
	
	var normal = (other.global_position - global_position).normalized()
	var relative_velocity = linear_velocity - other.linear_velocity
	
	if relative_velocity.dot(normal) > 0:
		return
	
	var v1n = linear_velocity.dot(normal)
	var v2n = other.linear_velocity.dot(normal)
	
	var new_v1n = ((v1n * (m1 - m2)) + (2 * m2 * v2n)) / (m1 + m2)
	var new_v2n = ((v2n * (m2 - m1)) + (2 * m1 * v1n)) / (m1 + m2)
	
	linear_velocity += (new_v1n - v1n) * normal * FORCE_MULTIPLIER
	other.linear_velocity += (new_v2n - v2n) * normal * FORCE_MULTIPLIER
	
	var overlap = (BALL_RADIUS * 2) - global_position.distance_to(other.global_position)
	if overlap > 0:
		var correction = normal * (overlap / 2.0 + MIN_SEPARATION)
		global_position -= correction
		other.global_position += correction

func handle_wall_collision(wall: StaticBody2D):
	var normal = (wall.global_position - global_position).normalized()
	linear_velocity = linear_velocity.bounce(normal)
