extends CharacterBody2D

class_name Player

@export var player_number: int = 1
@export var speed: int = 50
@export var power: int = 3 
@export var bombs: int = 1
@export var money: int = 0
@export var timebomb: bool = false

var last_direction: String = "down"
var is_dead: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bomb_placement_system: BombPlacementSystem = $BombPlacementSystem

@export var death_sound: AudioStream  # Assign your death sound in the editor


func _ready():
	add_to_group("player")
	# Connect the animation_finished signal to the callback.
	sprite.connect("animation_finished", Callable(self, "_on_animatedSprite_animation_finished"))

func _on_animatedSprite_animation_finished():
	# Once the death animation is finished, remove the node.
	queue_free()

func _physics_process(_delta):
	if is_dead:
		return

	velocity = Vector2.ZERO
	var moved = false

	if Input.is_action_pressed("right"):
		velocity.x += 1
		last_direction = "right"
		moved = true
	elif Input.is_action_pressed("left"):
		velocity.x -= 1
		last_direction = "left"
		moved = true

	if Input.is_action_pressed("down"):
		velocity.y += 1
		last_direction = "down"
		moved = true
	elif Input.is_action_pressed("up"):
		velocity.y -= 1
		last_direction = "up"
		moved = true
	elif Input.is_action_just_pressed("drop_bomb"):
		bomb_placement_system.place_bomb(timebomb)

	if timebomb and Input.is_action_just_released("drop_bomb"):
		bomb_placement_system.trigger_all_timebombs()

	velocity = velocity.normalized()
	# Adjust the speed so that the effective global movement is what you expect.
	velocity *= speed * Globals.global_scale_factor

	move_and_slide()
	update_animation(moved)

func update_animation(moving: bool):
	if moving:
		sprite.play("move_%s_%d" % [last_direction, player_number])
	else:
		sprite.play("idle_%s_%d" % [last_direction, player_number])

func die():
	# Prevent duplicate execution.
	if is_dead:
		return
	is_dead = true

	# Play the death sound if available.
	if death_sound:
		var sound_player = AudioStreamPlayer2D.new()
		sound_player.stream = death_sound
		add_child(sound_player)
		sound_player.play()

	# Play the death animation (ensure it's named "death" in your AnimatedSprite2D).
	sprite.play("death_%d" % player_number)

func stop(duration: float) -> void:
	var original_speed = speed  # Save the current speed.
	speed = 0                   # Stop the player by setting speed to 0.
	# Wait for the duration of the stop.
	await get_tree().create_timer(duration).timeout
	
	# Restore the original speed after the timer expires.
	speed = original_speed
	
