extends Node2D
class_name Unit

@export var stats: UnitStats

@onready var visuals: Node2D = %Visuals
@onready var sprite: Sprite2D = %Sprite
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var health_component: HealthComponent = $HealthComponent
@onready var flash_timer: Timer = $FlashTimer

func _ready() -> void:
	health_component.setup(stats)

func set_flash_material() -> void:
	sprite.material = Global.FLASH_MATERIAL
	flash_timer.start()

func _on_hurt_box_component_on_damaged(hitbox: HitBoxComponent) -> void:
	if health_component.current_health <= 0:
		return
	
	var blocked := Global.get_change_success(stats.block_chance / 100.0)
	if blocked:
		Global.on_create_block_text.emit(self)
		return
	
	set_flash_material()
	
	health_component.take_damage(hitbox.damage)
	Global.on_create_damage_text.emit(self, hitbox)


func _on_flash_timer_timeout() -> void:
	sprite.material = null
