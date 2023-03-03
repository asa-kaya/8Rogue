extends RigidBody2D

@export var min_power: float
@export var max_power: float

signal power_changed(new_value: float)

@onready var stick: Node2D = $Stick

enum State { ADJUST_DIRECTION, ADJUST_POWER, HITTING, BALL_MOVING }

var power: float
var power_delta: int
var current_state: State

func _ready():
	change_state(State.BALL_MOVING)

func _process(delta):
	if linear_velocity.length() > 5 and current_state != State.BALL_MOVING:
		change_state(State.BALL_MOVING)
	
	if current_state == State.BALL_MOVING:
		if linear_velocity.length() < 5:
			change_state(State.ADJUST_DIRECTION)
	elif current_state == State.ADJUST_DIRECTION:
		stick.rotate(stick.get_angle_to(get_global_mouse_position()))
	elif current_state == State.ADJUST_POWER:
		power += power_delta
		stick.transform = stick.transform.translated_local(Vector2(-power_delta/10, 0))
		power_changed.emit(power)
		if power <= min_power or power >= max_power:
			power_delta = -power_delta
	elif current_state == State.HITTING:
		stick.transform = stick.transform.translated_local(Vector2(power/100, 0))
		if stick.position.length() < 10:
			stick.position = Vector2.ZERO
			var force_dir := Vector2.from_angle(stick.rotation)
			apply_force(force_dir * power)

func _input(event):
	if current_state == State.ADJUST_DIRECTION and Input.is_action_just_pressed("interact"):
			change_state(State.ADJUST_POWER)
	elif current_state == State.ADJUST_POWER and Input.is_action_just_pressed("interact"):
			change_state(State.HITTING)
			
	if Input.is_action_just_pressed("ui_down"):
		linear_velocity = Vector2.ZERO

func change_state(new_state: State):
	if current_state != null:
		exit_state(current_state)
	
	current_state = new_state
	enter_state(current_state)

func enter_state(state: State):
	if state == State.BALL_MOVING:
		print("ball moving")
		stick.set_visible(false)
	elif state == State.ADJUST_DIRECTION:
		print("adjusting direction")
		stick.set_visible(true)
	elif state == State.ADJUST_POWER:
		print("adjusting power")
		power = min_power
		power_delta = 10

func exit_state(state: State):
	if state == State.BALL_MOVING:
		linear_velocity = Vector2.ZERO
	elif state == State.ADJUST_DIRECTION:
		stick.position = Vector2.ZERO
	elif state == State.ADJUST_POWER:
		pass
