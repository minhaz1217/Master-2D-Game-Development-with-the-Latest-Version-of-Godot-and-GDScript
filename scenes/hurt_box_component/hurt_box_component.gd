extends Area2D
class_name HurtBoxComponent

signal on_damaged(hitbox: HitBoxComponent)


func _on_area_entered(area: Area2D) -> void:
	if area is HitBoxComponent:
		on_damaged.emit(area)
