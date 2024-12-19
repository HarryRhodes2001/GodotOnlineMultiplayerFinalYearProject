extends CharacterBody3D

signal health_changed(health)
signal ammo_changed(ammunition)

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.003

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var player = $AnimationPlayer
@onready var flash = $Head/Camera3D/assault_rifle/Flash
@onready var raycast = $Head/Camera3D/RayCast3D

# Player Vars
var health = 100
var ammunition = 20
const ammunitionLimit = 20
var authority = 0

func _enter_tree():
	authority = multiplayer.get_unique_id()
	set_multiplayer_authority(authority)

func _ready():
	if not is_multiplayer_authority(): return
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.current = true

func _process(delta: float) -> void:
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
		firing_effects()
		if raycast.is_colliding():
			var hit = raycast.get_collider()
			if hit != null and hit.has_method("damage_received"):
				hit.damage_received()
	
	# If the player presses the R key, then reload the weapon
	if Input.is_action_just_pressed("reload") and player.current_animation != "Reload" and ammunition < ammunitionLimit:
		reload()

func _physics_process(delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor() and authority == 1:
		velocity.y = JUMP_VELOCITY
	elif Input.is_physical_key_pressed(KEY_J) and is_on_floor() and authority == 2:
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir
	if authority == 1:
		input_dir = Input.get_vector("left", "right", "up", "down")
	elif authority == 2:
		input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
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

func damage_received():
	health -= 10
	health_changed.emit(health)

func firing_effects():
	player.stop()
	player.play("Firing")
	ammunition -= 1
	ammo_changed.emit(ammunition)
	flash.restart()
	flash.emitting = true

func reload():
	player.stop()
	player.play("Reload")
	ammunition = ammunitionLimit
	ammo_changed.emit(ammunition)
