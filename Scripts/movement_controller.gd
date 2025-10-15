extends Node
class_name MovementController

@export_category("Links")
@export var player: CharacterBody3D
@export var input_handler: InputHandler
@export var main_camera: Camera3D
@export var character_collision: CollisionShape3D
@export var stand_up_check_area: Area3D

@export_category("Movement Settings")
@export var can_move: bool = true
@export_range(0.1, 20.0) var walk_speed: float = 4.0
@export_range(5.0, 30.0) var sprint_speed: float = 8.0
@export_range(0.1, 20.0) var crouch_speed: float = 2.0
@export_range(0.01, 1.0) var acceleration: float = 0.15
@export_range(0.0, 1.0) var air_control: float = 0.03
@export_range(1.0, 23.0) var jump_speed: float = 5.0
@export_range(0.1, 50.0) var mouse_sensitivity: float = 0.1
@export_range(0.01, 1.0) var ground_friction: float = 0.08

@export var crouch_height: float = 1.4
@export var stand_height: float = 2.0
@export var crouch_speed_transition: float = 8.0

var _rotation_x: float = 0.0
var _rotation_y: float = 0.0
var _velocity: Vector3 = Vector3.ZERO
var _target_velocity: Vector3 = Vector3.ZERO

var is_crouching := false
var is_sprinting := false
var _ground_speed: float = 0.0


# ------------------ SETUP ------------------
func _ready() -> void:
	if not player or not input_handler or not main_camera:
		push_error("MovementController: player, input_handler or camera not assigned!")
		return

	input_handler.on_jump.connect(jump)
	input_handler.on_crouch_enter.connect(on_crouch_enter)
	input_handler.on_crouch_exit.connect(on_crouch_exit)
	input_handler.on_sprint_enter.connect(func(): is_sprinting = true)
	input_handler.on_sprint_exit.connect(func(): is_sprinting = false)


# ------------------ INPUT ------------------
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and input_handler.is_input:
		rotate_character(event)


# ------------------ PHYSICS ------------------
func _physics_process(delta: float) -> void:
	if not can_move or not player:
		return
	print(stand_up_check_area.has_overlapping_bodies())
	var on_floor := player.is_on_floor()
	var direction := get_movement_direction()

	if on_floor:
		_ground_speed = get_current_speed()
		_target_velocity = direction * _ground_speed
	else:
		_target_velocity = direction * _ground_speed

	var lerp_factor := acceleration if on_floor else air_control
	_velocity.x = lerp(_velocity.x, _target_velocity.x, lerp_factor)
	_velocity.z = lerp(_velocity.z, _target_velocity.z, lerp_factor)

	if on_floor and direction == Vector3.ZERO:
		_velocity.x = lerp(_velocity.x, 0.0, ground_friction)
		_velocity.z = lerp(_velocity.z, 0.0, ground_friction)

	apply_gravity(delta)
	update_collider(delta)
	player.velocity = _velocity
	player.move_and_slide()
	_velocity = player.velocity

# ------------------ MOVEMENT HELPERS ------------------

func get_current_speed() -> float:
	if is_crouching and player.is_on_floor():
		return crouch_speed
	if is_sprinting and input_handler.input_dir.z < 0.0:
		return sprint_speed
	return walk_speed


func get_movement_direction() -> Vector3:
	var forward := -player.transform.basis.z
	var right := player.transform.basis.x
	return (right * input_handler.input_dir.x + forward * input_handler.input_dir.z).normalized()


func on_crouch_enter():
	is_crouching = true
	main_camera._target_height = main_camera.crouch_height


func on_crouch_exit():
	if not stand_up_check_area.has_overlapping_bodies(): 
		is_crouching = false
		main_camera._target_height = main_camera.default_height


func jump() -> void:
	if player.is_on_floor() and !is_crouching:
		_velocity.y = jump_speed


func update_collider(delta: float) -> void:
	if not character_collision:
		return

	var capsule := character_collision.shape
	if capsule == null or capsule is not CapsuleShape3D:
		return

	var target_height = crouch_height if is_crouching else stand_height

	capsule.height = lerp(capsule.height, target_height, delta * crouch_speed_transition)


# ------------------ ROTATION ------------------
func rotate_character(event: InputEvent) -> void:
	player.rotation_degrees.y = _rotation_y
	_rotation_y -= event.relative.x * mouse_sensitivity
	_rotation_x -= event.relative.y * mouse_sensitivity
	_rotation_x = clamp(_rotation_x, -85.0, 85.0)
	main_camera.rotate_camera_x(_rotation_x)


# ------------------ GRAVITY ------------------
func apply_gravity(delta: float) -> void:
	_velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
