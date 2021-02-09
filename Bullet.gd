extends RigidBody2D

var damage = 1

# This function is attached to the signal from VisibilityNotifier2D on the Bullet
func _on_VisibilityNotifier2D_screen_exited():
	# Once the Bullet is no longer on the screen, remove it from memory by calling
	# Godot's queue_free function... so we don't get slowdowns from having like
	# 10000000000 bullets in memory
	queue_free()


func _on_Bullet_body_entered(body):
	# Eventually we'll check here to see if it hit a bad guy or something
	if "Player" in body.name && !"Player" in get_groups():
		body.take_damage(damage)
		print("Hit Player")
	elif "Enemy" in body.name && !"Enemy" in get_groups():
		body.take_damage(damage)
		print("Hit Enemy")
	# The bullet hit something, remove it from memory
	queue_free()

func set_damage(damage):
	self.damage = damage
