extends Sprite

#######################################
# Constants - these values don't change
#######################################

# The sprite sheet for blood drops
const DROPS = preload("res://blood-drops.png")
# The sprite sheet for blood splatter
const SPLATTER = preload("res://blood-splatter.png")

# Called when the node enters the scene tree for the first time.
func _ready():
	# Initialize the random number generator
	randomize()
	# Pick a random frame.
	frame = randi() % 3

# Set the blood type, so we know which sprite sheet to use
func set_type(blood):
	if blood == "DROPS":
		texture = DROPS
	elif blood == "SPLATTER":
		texture = SPLATTER
