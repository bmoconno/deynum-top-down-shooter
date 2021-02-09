extends AnimatedSprite

# Use the animation_finished signal to let us know when to delete the sprite
func _on_GunBlast_animation_finished():
	queue_free()
