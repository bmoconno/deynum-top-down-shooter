extends Sprite
#######################################
# Constants - these values don't change
#######################################

# A reference to the Enemy scene, so we can make new instances of it
const ENEMY = preload("res://Enemy.tscn")
# Once the EnemySpawner is ready in the scene, set it's reference to the Player
onready var PLAYER = get_parent().get_node("YSort").get_node("Player")
# Once the EnemySpawner is ready in the scene, set it's reference to the YSort
onready var YSORT = get_parent().get_node("YSort")
# How close to the spawner the Player needs to be for it to spawn Enemies
const SPAWN_DISTANCE = 80
# How many seconds between Enemies spawns
const SPAWN_RATE = 1

#######################################
# Variable - these values do change
#######################################

var spawning = false

#######################################
# Exports - these values can be set in the inspector
#######################################
export var enemy_count = 5

# This function is built into Godot, it is called every frame
func _process(delta):
	# Get the distance from the Player to the EnemySpawner's Spawn node
	var distance = PLAYER.get_global_position() - $Spawn.get_global_position()
	
	# If the player is close enough, there's still enemies inside, and we're not
	# already spawning an enemy...
	if distance.length() < SPAWN_DISTANCE && enemy_count && !spawning:
		# ... spawn an Enemy
		spawn_enemy()

# This function spawns an Enemy node and adds it to the YSort
func spawn_enemy():
	# Play the door animation
	$AnimationPlayer.play("open")
	# Set the spawning variable so we don't spawn another Enemy yet
	spawning = true
	# Make a new Enemy instance
	var enemy = ENEMY.instance()
	# Set it's position to the Spawn node's location
	enemy.position = $Spawn.get_global_position()
	# Add the enemy to the YSort node so it can be hidden by the tileset
	YSORT.add_child(enemy)
	# Decrement the enemy count since we just spawned an enemy
	enemy_count -= 1
	# Wait for SPAWN_RATE seconds...
	yield(get_tree().create_timer(SPAWN_RATE), "timeout")
	# ... then set the spawning variable to false so we can spawn again
	spawning = false
