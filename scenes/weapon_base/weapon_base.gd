extends Node2D
class_name WeaponBase

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var cooldown_timer: Timer = $CooldownTimer

var data: ItemWeapon
var is_attacking := false
