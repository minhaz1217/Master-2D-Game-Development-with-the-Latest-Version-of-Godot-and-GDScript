extends Node

const FLASH_MATERIAL = preload("uid://coi4nu8ohpgeo")

var player: Player

func get_change_success(chance: float) -> bool:
	var random := randf_range(0, 1.0)
	if(random < chance):
		return true
	return false
