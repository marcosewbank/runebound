extends CharacterBody2D

@export var MAX_SPEED = 200.0
@export var ACCELERATION_SMOOTHING = 2

@onready var damage_interval_timer = $DamageIntervalTimer
@onready var health_component = $HealthComponent
@onready var health_bar = $HealthBar

var number_colliding_bodies = 0

func _ready():
	$CollisionArea2D.body_entered.connect(on_body_entered)
	$CollisionArea2D.body_exited.connect(on_body_exited)
	damage_interval_timer.timeout.connect(on_damage_interval_timer_timeout)
	health_component.health_changed.connect(on_health_changed)
	update_health_display()

func _physics_process(delta: float) -> void:
	_get_direction_input(delta)
	move_and_slide()

func _get_direction_input(delta: float):
	var direction = Input.get_vector("walk_left", "walk_right", "walk_up", "walk_down")
	var target_velocity = direction * MAX_SPEED
	velocity = velocity.lerp(target_velocity, 1 - exp(-delta * ACCELERATION_SMOOTHING))

func on_body_entered(_other_body:Node2D):
	number_colliding_bodies += 1
	check_damage()

func on_body_exited(_other_body:Node2D):
	number_colliding_bodies -= 1

func check_damage():
	if number_colliding_bodies == 0 || !damage_interval_timer.is_stopped():
		return
	
	health_component.damage(1)
	damage_interval_timer.start()
	
	print(health_component.current_health)

func update_health_display():
	health_bar.value = health_component.get_health_percent()

func on_damage_interval_timer_timeout():
	check_damage()

func on_health_changed():
	update_health_display()
