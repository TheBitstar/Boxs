extends Area3D
@export var car_path: NodePath
@export var respawn_position: Vector3 = Vector3(0, 5, 0) 
func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	
func _on_body_entered(body):
	if body is CharacterBody3D:
		body.global_transform.origin = respawn_position
		body.velocity = Vector3.ZERO
#made by TheBitstarDev on github.com
