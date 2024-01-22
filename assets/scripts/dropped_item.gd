extends RigidBody2D

var itemToAdd:Item
var isMagnetized = false
var objectToLookAt:Node

func _process(delta):
	if(isMagnetized):
		$Texture.look_at(objectToLookAt.position)
		apply_impulse(Vector2.RIGHT.rotated($Texture.rotation)*0.025)
	else:
		angular_velocity = 0
		linear_velocity = Vector2(0,0)
