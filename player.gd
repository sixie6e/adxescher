extends CharacterBody3D
class_name Player

@export var run_speed: float = 4.0
@export var gravity_force: float = 35.0
@export var target_node: Node3D
@export var rotation_speed: float = 10.0

var current_intersection: Area3D = null
var touch_start_pos: Vector2 = Vector2.ZERO
var flip_cooldown: float = 0.0

@onready var floor_ray: RayCast3D = $RayCast3D if has_node("RayCast3D") else null

func _physics_process(delta: float) -> void:
    if flip_cooldown > 0.0:
        flip_cooldown -= delta

    var local_forward = -global_transform.basis.z
    var local_down = -global_transform.basis.y

    # check for gaps after cooldown delay
    if flip_cooldown <= 0.0 and floor_ray != null and not floor_ray.is_colliding():
        execute_flip()
        local_forward = -global_transform.basis.z
        local_down = -global_transform.basis.y

    velocity = (local_forward * run_speed) + (local_down * gravity_force)
    up_direction = -local_down
    
    move_and_slide()

func execute_flip() -> void:
    # 180 degrees around axis
    rotate_object_local(Vector3.FORWARD, PI)
    # nudge in new local down direction to clear block edge
    global_position += -global_transform.basis.y * 0.6
    flip_cooldown = 0.3

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            touch_start_pos = event.position
        else:
            var swipe = event.position - touch_start_pos
            if swipe.length() > 50:
                if abs(swipe.x) > abs(swipe.y):
                    attempt_turn(Vector3.UP, sign(swipe.x))
                else:
                    attempt_turn(Vector3.RIGHT, sign(swipe.y))

func attempt_turn(axis: Vector3, direction: float) -> void:
    if current_intersection != null:
        var angle = deg_to_rad(-90.0 * direction)
        rotate_object_local(axis, angle)
        current_intersection = null

func die() -> void:
    get_tree().reload_current_scene()
