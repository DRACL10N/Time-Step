extends KinematicBody2D


onready var GRAVITY = ProjectSettings.get("physics/2d/default_gravity")
onready var SM = $StateMachine
onready var MT = $MovementTracker
onready var SPRITE = $Sprite
onready var SLASH_POINT = $Sprite/SlashPoint
onready var COOLDOWN = $Sprite/SlashPoint/Cooldown
onready var COLLISION = $CollisionShape2D
onready var ANIMATION_PLAYER = $AnimationPlayer
onready var JUMP_SOUND = $Jump

export var DEATH_VECTOR = Vector2(50, -220)
export var SPEED = 150
export var JUMP_VELOCITY = 350
export var LAUNCH_SPEED = 700

const Slash = preload("res://src/Actor/Player/Slash/PlayerSlash.tscn")

var attacking = false
var velocity = Vector2.ZERO


func _ready():
	Globals.PLAYER = self


func apply_gravity(delta):
	velocity.y += GRAVITY * delta


func apply_movement():
	velocity = move_and_slide(velocity, Vector2.UP)


func handle_move_input():
	var direction = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	velocity.x = direction * SPEED
	if direction != 0:
		SPRITE.scale.x = direction


func handle_launch():
	velocity = Vector2(0, -LAUNCH_SPEED)
	COLLISION.set_deferred("disabled", true)


func handle_attack():
	if ANIMATION_PLAYER.get_current_animation() == "":
		attacking = false
	else:
		attacking = true
		velocity = Vector2.ZERO


func handle_slash():
	var slash = Slash.instance()
	slash.global_position = SLASH_POINT.global_position
	slash.scale.x = SPRITE.scale.x
	
	slash.set_as_toplevel(true)
	SLASH_POINT.add_child(slash)


func handle_slice_hit(body):
	if "Armstrong" in body.name:
		body.ANIMATION_PLAYER.play("die")


func handle_death():
	if SM.state != SM.States.DEAD:
		SM.state = SM.States.DEAD
		
		velocity.x = DEATH_VECTOR.x * SPRITE.scale.x
		velocity.y = DEATH_VECTOR.y
	elif SM.state == SM.States.DEAD:
		rotation_degrees = clamp(rotation_degrees + 5 * SPRITE.scale.x, -90, 90)


func end_game():
	Globals.GAME.end_game()
