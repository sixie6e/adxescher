extends Node3D

@export var path_segment_scene: PackedScene
@export var intersection_scene: PackedScene
@export var obstacle_scene: PackedScene

@export var segments_per_straight: int = 5
@export var max_depth: int = 4
@export var obstacle_spawn_chance: float = 0.3
@export var branch_chance: float = 0.4 # reduced to account for 5 possible directions

var visited_positions: Array[Vector3] = []

func _ready() -> void:
	randomize()
	generate_map()

func generate_map() -> void:
	visited_positions.clear()
	
	var path_queue: Array[Dictionary] = []
	
	path_queue.append({
		"pos": Vector3.ZERO,
		"forward": Vector3.FORWARD,
		"up": Vector3.UP,
		"depth": 0
	})
	
	while path_queue.size() > 0:
		var head: Dictionary = path_queue.pop_front()
		if head["depth"] < max_depth:
			generate_branch(head, path_queue)

func generate_branch(head: Dictionary, queue: Array[Dictionary]) -> void:
	var cursor: Vector3 = head["pos"]
	var forward: Vector3 = head["forward"]
	var up: Vector3 = head["up"]
	var depth: int = head["depth"]
	
	for i in range(segments_per_straight):
		if not is_position_visited(cursor):
			visited_positions.append(cursor.round())
			
			var segment = path_segment_scene.instantiate()
			add_child(segment)
			segment.global_position = cursor
			segment.look_at(cursor + forward, up)
			
			if i > 0 and obstacle_scene != null and randf() <= obstacle_spawn_chance:
				var obstacle = obstacle_scene.instantiate()
				segment.add_child(obstacle)
				var side = 1.0 if randf() > 0.5 else -1.0
				obstacle.position.y = side * 0.5
		
		cursor += forward * 2.0

	if intersection_scene != null:
		var intersection = intersection_scene.instantiate()
		add_child(intersection)
		intersection.global_position = cursor
		intersection.look_at(cursor + forward, up)

	# branching options
	var right: Vector3 = forward.cross(up).normalized()
	
	var possible_branches: Array[Dictionary] = [
		{"forward": forward, "up": up},         # Straight
		{"forward": right, "up": up},           # Right
		{"forward": -right, "up": up},          # Left
		{"forward": up, "up": -forward},        # Pitch Up
		{"forward": -up, "up": forward}         # Pitch Down
	]
	
	for branch in possible_branches:
		var dir_forward: Vector3 = branch["forward"]
		var dir_up: Vector3 = branch["up"]
		
		# maintain straight path; branch randomly into turns/verticals
		if dir_forward == forward or randf() <= branch_chance:
			queue.append({
				"pos": cursor + dir_forward * 2.0,
				"forward": dir_forward,
				"up": dir_up,
				"depth": depth + 1
			})

func is_position_visited(pos: Vector3) -> bool:
	var rounded_pos = pos.round()
	for visited in visited_positions:
		if visited.distance_to(rounded_pos) < 1.0:
			return true
	return false
