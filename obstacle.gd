extends Area3D
class_name Obstacle

func _on_body_entered(body: Node3D) -> void:
		if body is Player:
				body.die()
