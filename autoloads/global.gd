extends Node

signal on_create_block_text(unit: Node2D)
signal on_create_damage_text(unit: Node2D, hitbox: HitBoxComponent)

const FLASH_MATERIAL = preload("uid://coi4nu8ohpgeo")
const FLOATING_TEXT = preload("uid://c1sti5gh5yk0y")

enum UpgradeTier{
	COMMON,
	RARE,
	EPIC,
	LEGENDARY	
}

var player: Player



func get_change_success(chance: float) -> bool:
	var random := randf_range(0, 1.0)
	if(random < chance):
		return true
	return false
