extends Node3D

@export var target_node: Node3D
@export var follow_speed: float = 6.0
@export var rotation_speed: float = 4.0

func _physics_process(delta: float) -> void:
		if target_node:
				global_position = global_position.lerp(target_node.global_position, follow_speed * delta)
				
				# slerp rotation to handle instant 90-degree player snaps
				var target_quat = target_node.global_transform.basis.get_rotation_quaternion()
				var current_quat = global_transform.basis.get_rotation_quaternion()
				var new_quat = current_quat.slerp(target_quat, rotation_speed * delta)
				
				global_transform.basis = Basis(new_quat)
