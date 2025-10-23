extends Node2D
class_name WeaponBase

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision : CollisionShape2D = %CollisionShape2D
@onready var cooldown_timer: Timer = $CooldownTimer

var data: ItemWeapon
var is_attacking := false
var atk_start_pos: Vector2
var targets: Array[Enemy]
var closest_target: Enemy
var weapon_spread: float

func _ready() -> void:
	atk_start_pos = sprite_2d.position


func setup_weapon(data: ItemWeapon) -> void:
	self.data = data
	collision.shape.radius = data.stats.max_range
	
func get_closest_target() -> Node2D:
	if targets.size() == 0:
		return
	var closest_enemy := targets[0]
	var closest_distance := global_position.distance_to(closest_enemy.global_position)
	
	for i in range(1, targets.size()):
		var target: Enemy = targets[i]
		var distance := global_position.distance_to(target.global_position)
		
		if distance < closest_distance:
			closest_enemy = target
			closest_distance = distance
	
	return closest_enemy

func can_use_weapon() -> bool:
	return cooldown_timer.is_stopped() and closest_target


func _on_range_area_area_entered(area: Area2D) -> void:
	targets.push_back(area)


func _on_range_area_area_exited(area: Area2D) -> void:
	targets.erase(area)
	if targets.size() == 0:
		closest_target = null
