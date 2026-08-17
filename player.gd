extends CharacterBody3D
class_name Player

@export var run_speed: float = 4.0
@export var jump_velocity: float = 6.0
@export var gravity: float = 15.0
@export var rotation_align_speed: float = 12.0
@export var death_y_min: float = -50.0 
@export var death_y_max: float = 50.0 

var current_intersection: Area3D = null
var is_moving: bool = true
var vertical_velocity: float = 0.0

func _ready() -> void:
	motion_mode = CharacterBody3D.MOTION_MODE_FLOATING

func _physics_process(delta: float) -> void:
	var local_forward = -global_transform.basis.z
	var local_up = global_transform.basis.y

	align_to_surface(delta)

	if not is_on_floor_custom():
		vertical_velocity -= gravity * delta
	else:
		if vertical_velocity < 0:
			vertical_velocity = 0.0

	var move_vector = Vector3.ZERO

	if is_moving:
		move_vector += -global_transform.basis.z * run_speed

	move_vector += global_transform.basis.y * vertical_velocity

	var collision = move_and_collide(move_vector * delta)
	if collision:
		var collider = collision.get_collider()
		if collider is Obstacle or collider.name.contains("Obstacle"):
			die()
		else:
			vertical_velocity = 0.0

	if global_position.y < death_y_min or global_position.y > death_y_max:
		die()

func align_to_surface(delta: float) -> void:
	var space_state = get_world_3d().direct_space_state
	var local_forward = -global_transform.basis.z
	var local_up = global_transform.basis.y

	var ray_start = global_position + (local_up * 0.2)
	var ray_end = ray_start + (local_forward * 1.5)
	
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end)
	query.exclude = [get_rid()]
	var result = space_state.intersect_ray(query)

	if result.size() > 0:
		var surface_normal: Vector3 = result.normal
		
		if abs(local_forward.dot(surface_normal)) > 0.3:
			var current_basis = global_transform.basis
			
			# new up
			var new_up = surface_normal.normalized()
			var new_right = local_forward.cross(new_up).normalized()
			var new_forward = new_up.cross(new_right).normalized()
			var target_basis = Basis(new_right, new_up, -new_forward).orthonormalized()
			var current_quat = current_basis.get_rotation_quaternion()
			var target_quat = target_basis.get_rotation_quaternion()
			var slerped_quat = current_quat.slerp(target_quat, rotation_align_speed * delta)
			
			global_transform.basis = Basis(slerped_quat).orthonormalized()

func is_on_floor_custom() -> bool:
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(
		global_position,
		global_position - global_transform.basis.y * 1.1
	)
	query.exclude = [get_rid()]
	var result = space_state.intersect_ray(query)
	return result.size() > 0

func jump() -> void:
	if is_on_floor_custom():
		vertical_velocity = jump_velocity

func turn_left() -> void:
	attempt_move_or_turn(global_transform.basis.y, deg_to_rad(90))

func turn_right() -> void:
	attempt_move_or_turn(global_transform.basis.y, deg_to_rad(-90))

func turn_up() -> void:
	attempt_move_or_turn(global_transform.basis.x, deg_to_rad(90))

func turn_down() -> void:
	attempt_move_or_turn(global_transform.basis.x, deg_to_rad(-90))

func start_forward() -> void:
	if current_intersection != null or not is_moving:
		is_moving = true
		current_intersection = null

func attempt_move_or_turn(axis: Vector3, angle: float) -> void:
	if current_intersection != null:
		rotate(axis.normalized(), angle)
		global_transform.basis = global_transform.basis.orthonormalized()
		global_position = current_intersection.global_position
		current_intersection = null
	
	is_moving = true

func stop_at_intersection(intersection: Area3D) -> void:
	current_intersection = intersection
	global_position = intersection.global_position
	is_moving = false
	vertical_velocity = 0.0

func die() -> void:
	get_tree().reload_current_scene()
