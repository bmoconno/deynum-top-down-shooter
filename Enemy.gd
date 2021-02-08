extends KinematicBody2D

#######################################
# Constants - these values don't change
#######################################

# Maximum speed the enemy can move
const MAX_SPEED = 100
# Acceleration for the enemy (also used for deceleration)
const ACCELERATION = 1500
# The time, in seconds, between bullets being fired
const FIRE_RATE = 0.6
# How fast the bullet travels
const BULLET_SPEED = 150
# A reference to the Bullet scene, so we can make new instances of it
const BULLET = preload("res://Bullet.tscn")
# A reference to the GunBlast scene, so we can make new instances of it
const GUN_BLAST = preload("res://GunBlast.tscn")
# The AnimationPlayer node for Enemy, onready means it doesn't set this until 
# Godot's built in _ready function runs for this Enemy node
onready var ANIMATION_PLAYER = $AnimationPlayer
# Once the Enemy is ready in the scene, set it's reference to the Player
onready var PLAYER = get_parent().get_node('Player')
# How close should the Enemy get to the Player
const ATTACK_DISTANCE = 40
# How close should the Player be before the Enemy sees the Player
const SIGHT_DISTANCE = 100
# The location of sprite sheets for Enemy units
const SPRITE_SHEETS = ["res://enemy-1-sprites.png", "res://enemy-2-sprites.png", "res://enemy-3-sprites.png", "res://enemy-4-sprites.png"]

#######################################
# Variable - these values do change
#######################################

# A 2D vector for the direction/speed the Enemy is currently moving
var motion = Vector2()
# Is the gun ready to fire?
var reloaded = true

# This function is buily into Godot, it is called when the Node is loaded into
# the scene
func _ready():
	# Set the random sprite for this enemy
	set_sprite()

# This function is built into Godot, it is called every physics frame
func _physics_process(delta):
	# See how far away the Enemy is from the Player
	var distance = PLAYER.position - position
	
	# Figure out how much acceleration to apply, we do this by multiplying our 
	# ACCELERATION constant by delta. The delta variable is given to us by Godot 
	# as part of the _physics_process function, it is the time in seconds
	# since the last time _physics_process was called.
	var acceleration = ACCELERATION * delta
	
	# If the Player is close enough to be seen and not too close to shoot at...
	if distance.length() > ATTACK_DISTANCE && distance.length() < SIGHT_DISTANCE:
		# ...move the Enemy toward the player
		var direction = (PLAYER.position - position)
		apply_movement(acceleration * distance)
		# Since the Enemy is moving, turn on the move animation
		ANIMATION_PLAYER.play("move")
	else: # Otherwise...
		# ... slow down the Enemy
		apply_friction(acceleration)
		# Shoot at the player if the gun is reloaded and we can see the them
		if reloaded && distance.length() <= SIGHT_DISTANCE:
			shoot()
	
	# Point the Enemy toward the Player
	look_at(PLAYER.position)
	
	# Update the Enemy's motion using the move_and_slide function.
	# Godot's built in move_and_slide function will cause the Enemy to slide
	# instead of abruptly stopping when it collides with something
	motion = move_and_slide(motion)

# Slow the Enemy down at a steady rate, this helps prevent jerky movement
func apply_friction(deceleration):
	# If the Enemy is moving faster than how much we want to slow them down by...
	if motion.length() > deceleration:
		# ... slow them down
		motion -= motion.normalized() * deceleration
	else:# Otherwise...
		# ... set their movement to zero, since we don't want to send them backwards
		motion = Vector2.ZERO
		# and set the Enemy's animation back to idle
		ANIMATION_PLAYER.play("idle")

# Apply acceleration to the Enemy
func apply_movement(acceleration):
	# Add the acceleration we figured out to the Enemy's current motion
	motion += acceleration
	# Then use Godot's clamped function to make sure they aren't moving faster
	# than our MAX_SPEED constant
	motion = motion.clamped(MAX_SPEED)

# Since we have 4 different enemy sprites, let's assign a random sprite to
# this Enemy instance
func set_sprite():
	# Initialize the random number generator
	randomize()
	# Pick a random integer, then give us it's value mod 4. The Mod or Modulus 
	# operator % will return the remainder from division. So, by using mod 4 on
	# a random integer, we will always have a remainder of 0, 1, 2, or 3
	var type = randi() % 4
	# Set the texture to the randomly selected sprite sheet
	$Sprite.texture = load(SPRITE_SHEETS[type])

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
