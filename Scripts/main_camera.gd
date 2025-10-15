extends Camera3D
class_name CameraController

@export_category("Links")
@export var input_handler: InputHandler
@export var movement_controller: MovementController
@export var player: CharacterBody3D

@export_category("Camera Settings")
@export var bob_frequency: float = 10.0
@export var bob_amplitude: float = 0.07
@export var sprint_bob_multiplier: float = 1.4
@export var tilt_angle: float = 1.4
@export var tilt_speed: float = 8.0
@export var default_height: float = 1.7
@export var crouch_height: float = 1.2
@export var height_lerp_speed: float = 8.0

@export_category("Jump / Land Settings")
@export var jump_offset: float = -0.1
@export var land_offset: float = -0.3
@export var land_recovery_speed: float = 5.0
@export var min_landing_speed: float = 1.0
@export var max_landing_speed: float = 15.0

var _bob_timer: float = 0.0
var _current_tilt: float = 0.0
var _target_height: float
var _current_height: float
var _vertical_offset: float = 0.0
var _velocity_y_prev: float = 0.0
var _was_on_floor: bool = true


func _ready() -> void:
	if not input_handler:
		push_error("CameraController: InputHandler not assigned!")
	if not movement_controller:
		push_error("CameraController: MovementController not assigned!")
	if not player:
		push_error("CameraController: Player not assigned!")

	_target_height = default_height
	_current_height = default_height


func _process(delta: float) -> void:
	var on_floor := player.is_on_floor()
	var moving := movement_controller._target_velocity.length() > 0.1


	handle_jump_and_land(on_floor, delta)

	if moving and on_floor:
		_bob_timer += delta * bob_frequency * (sprint_bob_multiplier if movement_controller.is_sprinting else 1.0)
		var bob_offset := sin(_bob_timer) * bob_amplitude
		_current_height = lerp(_current_height, _target_height + bob_offset, delta * 10.0)
	else:
		_bob_timer = 0.0
		_current_height = lerp(_current_height, _target_height, delta * height_lerp_speed)

	var cam_pos := position
	cam_pos.y = _current_height + _vertical_offset
	position = cam_pos

	var input_x := input_handler.input_dir.x
	var target_tilt := input_x * tilt_angle if moving else 0.0
	_current_tilt = lerp(_current_tilt, target_tilt, delta * tilt_speed)
	rotation_degrees.z = _current_tilt

	_velocity_y_prev = player.velocity.y
	_was_on_floor = on_floor


func rotate_camera_x(_rotation_x: float) -> void:
	rotation_degrees.x = _rotation_x


func handle_jump_and_land(on_floor: bool, delta: float) -> void:
	if not _was_on_floor and on_floor:
		var impact_speed = abs(_velocity_y_prev)

		var t = clamp((impact_speed - min_landing_speed) / (max_landing_speed - min_landing_speed), 0.0, 1.0)

		_vertical_offset = lerp(0.0, land_offset, t)

	elif _was_on_floor and not on_floor and _velocity_y_prev <= 0.0:
		_vertical_offset = jump_offset

	_vertical_offset = lerp(_vertical_offset, 0.0, delta * land_recovery_speed)
