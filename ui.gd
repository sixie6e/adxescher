extends CanvasLayer

@export var player: Player
@onready var left_button: TouchScreenButton = $LeftButton
@onready var right_button: TouchScreenButton = $RightButton
@onready var forward_button: TouchScreenButton = $ForwardButton
@onready var down_button: TouchScreenButton = $DownButton
@onready var jump_button: TouchScreenButton = $JumpButton

func _ready() -> void:
	if player == null:
		player = get_parent().get_node_or_null("CharacterBody3D")
		
	left_button.pressed.connect(_on_left_pressed)
	right_button.pressed.connect(_on_right_pressed)
	forward_button.pressed.connect(_on_forward_pressed)
	down_button.pressed.connect(_on_down_pressed)
	jump_button.pressed.connect(_on_jump_pressed)

func _on_left_pressed() -> void:
	if player:
		player.turn_left()

func _on_right_pressed() -> void:
	if player:
		player.turn_right()

func _on_forward_pressed() -> void:
	if player:
		player.start_forward()

func _on_down_pressed() -> void:
	if player:
		player.turn_down()

func _on_jump_pressed() -> void:
	if player:
		player.jump()
