extends Unit
class_name Player

@export var dash_duration := 0.5
@export var dash_speed_multi := 4
@export var dash_cooldown := 1.5

@onready var dash_timer: Timer = $DashTimer
@onready var dash_cool_down_timer: Timer = $DashCoolDownTimer
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var trail: Trail = %Trail
@onready var weapon_container: WeaponContainer = $WeaponContainer

var current_weapons: Array[WeaponBase]

var move_dir: Vector2
var is_dashing := false
var dash_available := true

func _ready() -> void:
	super._ready()
	dash_timer.wait_time = dash_duration
	dash_cool_down_timer.wait_time = dash_cooldown
	
	add_weapon(preload("uid://bt2q6m7u68chb"))
	add_weapon(preload("uid://bt2q6m7u68chb"))
	add_weapon(preload("uid://bt2q6m7u68chb"))
	add_weapon(preload("uid://bt2q6m7u68chb"))
	add_weapon(preload("uid://bt2q6m7u68chb"))
	add_weapon(preload("uid://bt2q6m7u68chb"))

func _process(delta: float) -> void:
	move_dir = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var current_velocity := move_dir * stats.speed
	
	if is_dashing:
		current_velocity *= dash_speed_multi
	
	position += current_velocity * delta
	
	position.x = clamp(position.x, -1000, 1000)
	position.y = clamp(position.y, -500, 500)
	
	if can_dash():
		start_dash()
	
	update_animations()
	update_rotation()
	

func add_weapon(data:ItemWeapon) -> void:
	var weapon = data.scene.instantiate() as WeaponBase
	add_child(weapon)
	weapon.setup_weapon(data)
	current_weapons.append(weapon)
	
	weapon_container.update_weapon_position(current_weapons)

func update_animations() -> void:
	if move_dir.length() > 0:
		anim_player.play("move")
	else:
		anim_player.play("idle")

func update_rotation() -> void:
	if move_dir == Vector2.ZERO:
		return
		
	if move_dir.x >= 0.1:
		visuals.scale = Vector2(-0.5 , 0.5)
	else:
		visuals.scale = Vector2(0.5 , 0.5)

func start_dash()->void:
	is_dashing = true
	dash_timer.start()
	trail.start_trail()
	visuals.modulate.a = 0.5
	collision.set_deferred("disabled", true)
	
func can_dash() -> bool:
	return not is_dashing and \
	dash_cool_down_timer.is_stopped() and \
	Input.is_action_just_pressed("dash") and \
	move_dir != Vector2.ZERO

func is_facing_right() -> bool:
	return visuals.scale.x == -0.5

func _on_dash_timer_timeout() -> void:
	is_dashing = false
	visuals.modulate.a = 1
	move_dir = Vector2.ZERO
	collision.set_deferred("disabled", false)
	dash_cool_down_timer.start()
