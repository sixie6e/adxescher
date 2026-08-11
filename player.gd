extends CharacterBody3D
class_name Player

@export var run_speed: float = 4.0
@export var gravity_force: float = 35.0

@export var death_y_min: float = -15.0 
@export var death_y_max: float = 15.0 

var is_gravity_flipped: bool = false
var touch_start_pos: Vector2 = Vector2.ZERO
var current_intersection: Area3D = null

func _physics_process(_delta: float) -> void:
        var local_forward = -global_transform.basis.z
        var local_down = -global_transform.basis.y		
        var current_gravity_dir = local_down if not is_gravity_flipped else -local_down
        
        velocity = (local_forward * run_speed) + (current_gravity_dir * gravity_force)
        up_direction = -local_down if not is_gravity_flipped else local_down
        
        if global_position.y < death_y_min or global_position.y > death_y_max:
                die()
        
        move_and_slide()

func _input(event: InputEvent) -> void:
        if event is InputEventScreenTouch:
                if event.pressed:
                        touch_start_pos = event.position
                else:
                        var swipe = event.position - touch_start_pos
                        if swipe.length() > 50:
                                if abs(swipe.y) > abs(swipe.x):
                                        flip_gravity()
                                else:
                                        attempt_turn(sign(swipe.x))

func flip_gravity() -> void:
        is_gravity_flipped = !is_gravity_flipped
        $Sprite3D.flip_v = is_gravity_flipped
        # detach from current floor
        global_position += up_direction * 0.5 

func attempt_turn(direction: int) -> void:
        if current_intersection != null:
                # -1 is left, 1 is right. 90 degrees on local Y
                var turn_angle = deg_to_rad(-90 * direction)
                global_rotate(global_transform.basis.y.normalized(), turn_angle)
                current_intersection = null

func die() -> void:
        get_tree().reload_current_scene()
        return
