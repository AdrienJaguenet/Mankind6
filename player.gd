extends Node3D

var moving_speed = 10


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("move_forward"):
		position += -global_transform.basis.z * delta * moving_speed
	if Input.is_action_pressed("move_backward"):
		position += global_transform.basis.z * delta * moving_speed
	if Input.is_action_pressed("move_left"):
		position += -global_transform.basis.x * delta * moving_speed
	if Input.is_action_pressed("move_right"):
		position += global_transform.basis.x * delta * moving_speed
	if Input.is_action_pressed("jump"):
		position += global_transform.basis.y * delta * moving_speed
	if Input.is_action_pressed("crouch"):
		position += -global_transform.basis.y * delta * moving_speed
	pass

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotation.x += -event.relative.y * .01
		rotation.y += -event.relative.x * .01
