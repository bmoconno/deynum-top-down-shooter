extends KinematicBody2D
#######################################
# Constants - these values don't change
#######################################

# Maximum speed the player can move
const MAX_SPEED = 200
# Acceleration for the player (also used for deceleration)
const ACCELERATION = 2000
# The time, in seconds, between bullets being fired
const FIRE_RATE = 0.2
# How fast the bullet travels
const BULLET_SPEED = 300
# A reference to the Bullet scene, so we can make new instances of it
const BULLET = preload("res://Bullet.tscn")
# A reference to the GunBlast scene, so we can make new instances of it
const GUN_BLAST = preload("res://GunBlast.tscn")
# A refernece to the Blood scene, so we can make new instances of it
const BLOOD = preload("res://Blood.tscn")
# The AnimationPlayer node for Player, onready means it doesn't set this until 
# Godot's built in _ready function runs for this Player node
onready var ANIMATION_PLAYER = $AnimationPlayer

#######################################
# Variable - these values do change
#######################################

# A 2D vector for the direction/speed the player is currently moving
var motion = Vector2()
# Is the gun ready to fire?
var reloaded = true
# How much the health the player has
var health = 100.0
# Difficuly will be used to increase damage received, each difficulty level
# increases damage taken by the player by 1/3
var difficulty = 0

# This function is built into Godot, it is called every frame
func _process(delta):
	# Point the Player node at the mouse pointer
	look_at(get_global_mouse_position())
	
	# If the player presses the fire button and the gun is ready to shoot...
	if Input.is_action_pressed("left_mouse") && reloaded:
		# ...shoot the gun
		shoot()

# This function is built into Godot, it is called every physics frame
func _physics_process(delta):
	# Get the direction the player is pressing
	var direction = get_move_direction()
	
	# Figure out how much acceleration to apply, we do this by multiplying our 
	# ACCELERATION constant by delta. The delta variable is given to us by Godot 
	# as part of the _physics_process function, it is the time in seconds
	# since the last time _physics_process was called.
	var acceleration = ACCELERATION * delta
	
	# If the player isn't pressing any direction buttons...
	if direction == Vector2.ZERO:
		# ... apply friction to slow them down
		apply_friction(acceleration)
	else: # Otherwise...
		# ... apply movement based on acceleration
		apply_movement(direction * acceleration)
		# Since the Player is moving, turn on the move animation
		ANIMATION_PLAYER.play("move")
	
	# Update the Player's motion using the move_and_slide function.
	# Godot's built in move_and_slide function will cause the Player to slide
	# instead of abruptly stopping when it collides with something
	motion = move_and_slide(motion)

# This function checks which buttons the player is pressing so we know which 
# direction they want to go
func get_move_direction():
	# Start with a 2D vector of (0,0)
	var direction = Vector2.ZERO
	# Set the x value of the direction vector based on the left and right 
	# buttons being pressed. The Input.is_action_pressed function returns true 
	# or false, which we can turn into 1 or 0 by changing it into an integer
	# with the int function. 
	#
	# So if the right button is pressed (true = 1) and left button is not 
	# (false = 0) we get direction.x = 1 - 0 which is 1.
	#
	# This works because of the coordinate system used by godot, which looks 
	# like this:
	#
	#						   (-1,-1)  |   (1,-1)
	#						            |    
	#						   ---------0---------
	#						            |
	#						   (-1,1)   |   (1,1)
	#
	# Negative y values are above the x-axis, and positive y values are below the 
	# x axis. While x values are more like you're used to from math class, where
	# positive x values are to the right of the y-axis and negative x values are
	# to the left of the y-axis
	direction.x = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left"))
	direction.y = int(Input.is_action_pressed("down")) - int(Input.is_action_pressed("up"))
	
	# When we return the value, we normalize it so that the vector length is 
	# always 1, if we don't do this the player would actually more faster on
	# angles because the position (1,1) is actually further away from (0,0) than
	# (0,1) is.
	return direction.normalized()

# Slow the player down at a steady rate, this helps prevent jerky movement
func apply_friction(deceleration):
	# If the player is moving faster than how much we want to slow them down by...
	if motion.length() > deceleration:
		# ... slow them down
		motion -= motion.normalized() * deceleration
	else:# Otherwise...
		# ... set their movement to zero, since we don't want to send them backwards
		motion = Vector2.ZERO
		# and set the Player's animation back to idle
		ANIMATION_PLAYER.play("idle")

# Apply acceleration to the player
func apply_movement(acceleration):
	# Add the acceleration we figured out to the player's current motion
	motion += acceleration
	# Then use Godot's clamped function to make sure they aren't moving faster
	# than our MAX_SPEED constant
	motion = motion.clamped(MAX_SPEED)

# Shoot a bullet out of the gun
func shoot():
	# Make a new instance of the Bullet scene
	var bullet = BULLET.instance()
	# Set the position of the bullet to position of the Gun node (we can use $Gun
	# as a shortcut to refernce the node) on Player, we do this so that the 
	# bullet doesn't come from the middle of the player sprite
	bullet.position = $Gun.get_global_position()
	# Rotate the bullet by the same amount the Player is rotated, so the bullet
	# doesn't look like it's flying sideways
	bullet.rotation_degrees = rotation_degrees
	# Use Godot's apply_impulse function to a one-time force to the bullet, like
	# how a bullet gets shot out of a gun. The first parameter is offset, since
	# we don't want an offset... we use a vector of (0,0) for that. The second 
	# parameter is the impule/force we apply to the bullet. We use our BULLET_SPEED
	# constant on the x-axis and 0 on the y-axis to make the bullet move in the 
	# direction we want, then we rotate that by the Player's rotation so it comes
	# out the right direction
	bullet.apply_impulse(Vector2.ZERO, Vector2(BULLET_SPEED, 0).rotated(rotation))
	# Set the group for our bullet so the Player can't shoot themselves
	bullet.add_to_group("Player")
	# Set the damage for the bullet, this will later be modified by power ups
	# and guns and stuff
	bullet.set_damage(50)
	# Use built in Godot functions to get the parent node (YSort), then add
	# our new bullet instance to it.
	get_parent().call_deferred("add_child", bullet)
	# Play the GunBlast animation
	var gunBlast = GUN_BLAST.instance()
	# Set the position of the GunBlast animation to the position of the gun
	gunBlast.position = $Gun.position
	# Add the GunBlast animation to the Player node, so it sticks to the gun
	add_child(gunBlast)
	# Since the gun has just shot, it's no longer reloaded, so it can't shoot again
	reloaded = false
	# yield means nothing else happens until a condition has been met, for this
	# yeild, we make a new timer for FIRE_RATE seconds. Once that timer has ended
	# it sends a "timeout" signal that let's the yield function know we can start
	# doing stuff again
	yield(get_tree().create_timer(FIRE_RATE), "timeout")
	# Now that we've waited for FIRE_RATE seconds, the gun is reloaded and can
	# shoot again
	reloaded = true

# Called when the Player's health gets below 0
func death():
	print("Dead!")
	# Handle death here, menu/continue screen?
	pass

# Called when something hits the Player
func take_damage(damage):
	# Modify the damage based on difficulty level
	var incoming = damage + float((1.0/3) * difficulty * damage)
	print("Player took " + String(incoming) + " damage")
	print(health)
	# Remove the modified damage from the Player's health
	health -= incoming
	# If the Player's health is blow 0, they die
	var blood = BLOOD.instance()
	blood.position = get_global_position()
	if health <= 0:
		blood.set_type("SPLATTER")
		get_parent().get_node("Blood").call_deferred("add_child", blood)
		#get_tree().get_root().call_deferred("add_child", blood)
		#get_parent().call_deferred("add_child", blood)
		death()
	else:
		blood.set_type("DROPS")
		#get_tree().get_root().call_deferred("add_child", blood)
		#get_parent().call_deferred("add_child", blood)
		get_parent().get_node("Blood").call_deferred("add_child", blood)

# The player has been hit... might not use this
func _on_HitBox_body_entered(body):
	
	pass # Replace with function body.
