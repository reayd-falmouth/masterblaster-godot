extends CharacterBody2D

class_name Player

@export var player_number: int = 1
@export var speed: int = 40
@export var power: int = 3
@export var bombs: int = 1
@export var money: int = 0
@export var timebomb: bool = false
@export var death_sound: AudioStream

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var bomb_placement_system: BombPlacementSystem = $BombPlacementSystem

var last_direction: String = "down"
var is_dead: bool = false

func _ready():
	add_to_group("player")
	sprite.connect("animation_finished", Callable(self, "_on_animatedSprite_animation_finished"))
	update_animation(false)  # Initialize idle animation

func _on_animatedSprite_animation_finished():
	if sprite.animation == "death_%d" % player_number:
		queue_free()

func _physics_process(_delta):
	if is_dead:
		return

	var velocity = Vector2.ZERO
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

	self.velocity = velocity.normalized() * speed
	move_and_slide()

	update_animation(moved)

func update_animation(moving: bool):
	var animation_name = ""
	if is_dead:
		animation_name = "death_%d" % player_number
	else:
		if moving:
			animation_name = "move_%s_%d" % [last_direction, player_number]
		else:
			animation_name = "idle_%s_%d" % [last_direction, player_number]

	if sprite.animation != animation_name:
		sprite.play(animation_name)

func die():
	if is_dead:
		return
	is_dead = true

	if death_sound:
		var sound_player = AudioStreamPlayer2D.new()
		sound_player.stream = death_sound
		add_child(sound_player)
		sound_player.play()

	update_animation(false) # Will trigger death animation

func stop(duration: float) -> void:
	var original_speed = speed
	speed = 0
	await get_tree().create_timer(duration).timeout
	speed = original_speed
