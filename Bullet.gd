extends RigidBody2D

# This function is attached to the signal from VisibilityNotifier2D on the Bullet
func _on_VisibilityNotifier2D_screen_exited():
	# Once the Bullet is no longer on the screen, remove it from memory by calling
	# Godot's queue_free function... so we don't get slowdowns from having like
	# 10000000000 bullets in memory
	queue_free()


func _on_Bullet_body_entered(body):
	# Eventually we'll check here to see if it hit a bad guy or something
	# The bullet hit something, remove it from memory
	queue_free()
