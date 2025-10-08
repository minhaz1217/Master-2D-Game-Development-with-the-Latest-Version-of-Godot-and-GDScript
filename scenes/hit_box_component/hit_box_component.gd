extends Area2D
class_name HitBoxComponent

signal on_hit_hurtbox(area: Area2D)

var damage := 1.0
var critical := false
var knockback_power := 0.0
var source: Node2D


func enable() -> void:
	set_deferred("monitoring", true)
	set_deferred("monitorable", true)
	
func disable() -> void:
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	
	
func setup(damage: float, critical: float, knockback: float, source: Node2D) -> void:
	self.damage = damage
	self.critical = damage
	self.knockback_power = knockback
	self.source = source


func _on_area_entered(area: Area2D) -> void:
	if area is HurtBoxComponent:
		on_hit_hurtbox.emit(area)
		print(area.owner.name)
