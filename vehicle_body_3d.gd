extends VehicleBody3D

@export var max_engine_force: float = 3000.0
@export var max_brake_force: float = 100.0
@export var max_steering_angle: float = 0.5 
@export var can_be_picked_up: bool = true
@onready var car_camera: Camera3D = $Camera3D
@onready var wheels := {
	"front_left": $fl,
	"front_right": $fr,
	"rear_left": $bl,
	"rear_right": $br
}
var is_driving: bool = false

func _ready() -> void:
	if car_camera:
		car_camera.current = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("car"):
		is_driving = !is_driving
		if car_camera:
			car_camera.current = is_driving
			
func _physics_process(_delta: float) -> void:
	if not is_driving:
		_apply_wheel_physics(0.0, 0.0, 0.0)
		return

	var forward_input := Input.get_action_strength("ui_up") - Input.get_action_strength("ui_down")
	var turn_input := Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	var brake_input := Input.is_action_pressed("brake")

	var engine_force_val: float = forward_input * max_engine_force
	var steering_angle_val: float = turn_input * max_steering_angle
	var brake_val: float = max_brake_force if brake_input else 0.0

	_apply_wheel_physics(engine_force_val, steering_angle_val, brake_val)

func _apply_wheel_physics(engine_force_val: float, steering_angle_val: float, brake_val: float) -> void:
	for key in wheels.keys():
		var wheel = wheels[key]
		if wheel == null:
			continue

		wheel.engine_force = engine_force_val
		wheel.brake = brake_val

		if key in ["front_left", "front_right"]:
			wheel.steering = steering_angle_val
		else:
			wheel.steering = 0.0
#made by TheBitstarDev on github.com
