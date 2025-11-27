extends CharacterBody3D

const SPEED: float = 9.0
const JUMP_VELOCITY: float = 9.0
const MOUSE_SENSITIVITY: float = 0.003  
const LOOK_UP_LIMIT: float = deg_to_rad(60)
const LOOK_DOWN_LIMIT: float = deg_to_rad(-40)

@export var box_scene: PackedScene = preload("res://Box.tscn")
@export var shoot_force: float = 20.0

@onready var neck: Node3D = $Neck
@onready var camera: Camera3D = $Neck/Camera3D
@onready var hold_position: Node3D = $Neck/Camera3D/HoldPosition

var pitch: float = 0.0
var held_object: RigidBody3D = null

@export var grab_distance: float = 4.0
@export var throw_force: float = 6.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if not is_inside_tree():
		return

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		neck.rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		pitch = clamp(pitch - event.relative.y * MOUSE_SENSITIVITY, LOOK_DOWN_LIMIT, LOOK_UP_LIMIT)
		camera.rotation.x = pitch

	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event is InputEventMouseButton and event.pressed:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if Input.is_action_just_pressed("car"):
		set_physics_process(not is_physics_processing())

	if event.is_action_pressed("interact"):
		if held_object != null:
			drop_object()
		else:
			try_pick_up()

	if event.is_action_pressed("shoot"):
		shoot_box()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction: Vector3 = (neck.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if held_object != null:
		held_object.global_transform = hold_position.global_transform
	move_and_slide()
func try_pick_up() -> void:
	var space = get_world_3d().direct_space_state
	var from: Vector3 = camera.global_transform.origin
	var to: Vector3 = from + -camera.global_transform.basis.z * grab_distance

	var params = PhysicsRayQueryParameters3D.new()
	params.from = from
	params.to = to
	params.exclude = [self]
	params.collide_with_bodies = true
	params.collide_with_areas = false

	var result = space.intersect_ray(params)

	if result and result.has("collider") and result["collider"] is RigidBody3D:
		var obj: RigidBody3D = result["collider"]
		obj.freeze = true
		obj.get_parent().remove_child(obj)
		hold_position.add_child(obj)
		obj.transform = Transform3D.IDENTITY
		held_object = obj 

func drop_object() -> void:
	if held_object == null:
		return

	held_object.get_parent().remove_child(held_object)
	get_tree().current_scene.add_child(held_object)
	held_object.global_transform = hold_position.global_transform
	held_object.freeze = false

	var forward: Vector3 = -camera.global_transform.basis.z
	held_object.apply_impulse(Vector3.ZERO, forward * throw_force)
	held_object = null

func shoot_box() -> void:
	if box_scene == null or not is_inside_tree():
		return

	var gun_position_node: Node3D = get_node_or_null("Neck/Camera3D/GunPosition")
	if gun_position_node == null or not gun_position_node.is_inside_tree():
		return

	var box_instance: RigidBody3D = box_scene.instantiate() as RigidBody3D

	var forward: Vector3 = -gun_position_node.global_transform.basis.z
	var spawn_pos: Vector3 = gun_position_node.global_transform.origin + forward * 1.5

	var box_transform: Transform3D = gun_position_node.global_transform
	box_transform.origin = spawn_pos
	box_instance.global_transform = box_transform

	get_tree().current_scene.add_child(box_instance)
	box_instance.apply_impulse(Vector3.ZERO, forward * shoot_force)
#made by TheBitstarDev on github.com
