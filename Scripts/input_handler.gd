extends Node
class_name InputHandler

var input_dir: Vector3 = Vector3.ZERO
var is_input: bool = true

signal on_sprint_enter
signal on_sprint_exit
signal on_crouch_enter
signal on_crouch_exit
signal on_jump


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _process(_delta: float) -> void:
	handle_input()


func handle_input() -> void:
	if is_input:
		input_dir = Vector3.ZERO
		
		# --- Movement ---
		if Input.is_action_pressed("input_right"):
			input_dir.x -= 1
		if Input.is_action_pressed("input_left"):
			input_dir.x += 1
		if Input.is_action_pressed("input_forward"):
			input_dir.z -= 1
		if Input.is_action_pressed("input_backward"):
			input_dir.z += 1
			
		if Input.is_action_just_pressed("accelerate"):
			on_sprint_enter.emit()
		if Input.is_action_just_released("accelerate"):
			on_sprint_exit.emit()
		
		if Input.is_action_just_pressed("jump"):
			on_jump.emit()

		if Input.is_action_just_pressed("crouch"):
			on_crouch_enter.emit()
		if Input.is_action_just_released("crouch"):
			on_crouch_exit.emit()
		
	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()
