extends StaticBody2D

var health = 1000

func death():
	# Remove the dead Car from the scene.. this will eventually be replaced with wreckage on fire
	queue_free()

# This is called when a Bullet hits the Car
func take_damage(damage):
	# Lower the Car's health by the damage amount
	health -= damage
	
	if health <= 0:
		# Call the Car death function
		death()
