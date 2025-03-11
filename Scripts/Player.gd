extends CharacterBody3D

signal health_changed(health)
signal ammo_changed(ammunition)
signal died(packet)
signal ping(player_id, time)

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var player = $AnimationPlayer
@onready var flash = $Head/Camera3D/assault_rifle/Flash
@onready var raycast = $Head/Camera3D/RayCast3D
@onready var pingTimer = $PingTimer

# Player Vars
var health = 100
var ammunition = 20
const ammunitionLimit = 20
var kills = 0
var deaths = 0

# Ping Vars
var current_time: float

# NOTICE: A fair amount of this code was taken from this tutorial: www.youtube.com/watch?v=n8D3vEx7NAE
# This was helpful to connect emitting signals from the players whilst also using RPC functions
# Some of the code in the tutorial is present in other scripts, the most relevant information starts at 24:53

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())

func _ready():
	if not is_multiplayer_authority(): return
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.current = true
	var packet = [name, 1, "24061067"]
	var compressedPacket = BitPacking.compress(packet)
	BitPacking.decompress(compressedPacket)

func _process(_delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	if ammunition == 0:
		reload()

func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))
	
	# If the player presses the left mouse button, fire the weapon
	# The current animation check is to prevent the animation overlaping and give a firing cooldown
	if Input.is_action_just_pressed("fire") and player.current_animation != "Firing" and ammunition != 0 and player.current_animation != "Reload":
		firing_effects.rpc()
		deduct_ammo()
		if raycast.is_colliding():
			var hit = raycast.get_collider()
			if hit != null and hit.has_method("damage_received"):
				hit.damage_received.rpc_id(hit.get_multiplayer_authority(), name)
	
	# If the player presses the R key, then reload the weapon
	if Input.is_action_just_pressed("reload") and player.current_animation != "Reload" and ammunition < ammunitionLimit:
		reload()

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# This if statement checks to see if the player is moving on the floor and is receiving input.
	# If so, we play the moving animation. Else he is idle.
	if player.current_animation == "Firing" or player.current_animation == "Reload":
		pass
	elif input_dir != Vector2.ZERO and is_on_floor():
		player.play("Moving")
	else:
		player.play("Idle")
	move_and_slide()

# When damaged, remotely emit a signal to the server to change my GUI upon altering my health value
@rpc("any_peer")
func damage_received(att_name):
	health -= 10
	health_changed.emit(health)
	if health <= 0:
		deaths += 1
		health = 100
		health_changed.emit(health)
		var packet = [name, deaths, att_name]
		var compressedPacket = BitPacking.compress(packet)
		died.emit(compressedPacket)

# Call the firing effects on the local instances so that every player sees them
@rpc("call_local")
func firing_effects():
	player.stop()
	player.play("Firing")
	flash.restart()
	flash.emitting = true

# Allows any player to remotely request a ping from the server, this is called once every second
@rpc("any_peer")
func ping_request(player_id, time):
	ping.emit(player_id, time)

# Called when the player fires
func deduct_ammo():
	ammunition -= 1
	ammo_changed.emit(ammunition)

# When the player runs out of ammunition in their current magazine, or hits the 'R' key, reload
func reload():
	player.stop()
	player.play("Reload")
	ammunition = ammunitionLimit
	ammo_changed.emit(ammunition)


func _on_ping_timer_timeout() -> void:
	# If I am the server, do not run this code
	if name == "1":
		pass
	else:
		# Run this in the world instance only!
		if not is_multiplayer_authority():
			return
		
		# Ask for the ping each second as to not overload the server with requests.
		current_time = Time.get_ticks_msec()
		ping_request.rpc(get_multiplayer_authority(), current_time)
