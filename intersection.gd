extends Area3D

func _on_body_entered(body: Node3D) -> void:
		if body is Player:
				body.current_intersection = self

func _on_body_exited(body: Node3D) -> void:
		if body is Player and body.current_intersection == self:
				body.current_intersection = null
