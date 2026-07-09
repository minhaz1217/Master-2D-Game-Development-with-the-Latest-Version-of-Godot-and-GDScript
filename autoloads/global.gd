extends Node

signal on_create_block_text(unit: Node2D)
signal on_create_damage_text(unit: Node2D, hitbox: HitBoxComponent)
signal on_upgrade_selected()
signal on_create_heal_text(unit: Node2D, heal: float)
signal on_enemy_died(enemy:Enemy)

const FLASH_MATERIAL = preload("uid://coi4nu8ohpgeo")
const FLOATING_TEXT = preload("uid://c1sti5gh5yk0y")
const COINS_SCENE = preload("uid://c0gxgyeg3phog")
const ITEM_CARD_SCENE = preload("uid://d4ahqxku4821t")
const SELECTION_CARD_SCENE = preload("uid://dnablojs1s8")

const COMMON_STYLES = preload("uid://qyev2vjcdknr")
const EPIC_STYLES = preload("uid://dr2xw2hayf05t")
const LEGENDARY_STYLES = preload("uid://cguomxq65meai")
const RARE_STYLES = preload("uid://dbhd8ppk17who")




const UPGRADE_PROBABILITY_CONFIG = {
	"rare" : { "start_wave": 2, "base_multi": 0.06 },
	"epic" : { "start_wave": 4, "base_multi": 0.02 },
	"legendary" : { "start_wave": 7, "base_multi": 0.0023 }
}

const SHOP_PROBABILITY_CONFIG = {
	"rare" : { "start_wave": 2, "base_multi": 0.10 },
	"epic" : { "start_wave": 4, "base_multi": 0.06 },
	"legendary" : { "start_wave": 7, "base_multi": 0.01 }
}

const TIER_COLORS : Dictionary[UpgradeTier, Color] = {
	UpgradeTier.RARE : Color(0.0, 0.557, 0.741),
	UpgradeTier.EPIC : Color(0.478, 0.251, 0.71),
	UpgradeTier.LEGENDARY : Color(0.906, 0.212, 0.212),
}

var available_players: Dictionary[String, PackedScene] = {
	"Brawler": preload("uid://bw1ea6v4rgaya"),
	"Bunny": preload("uid://5c5ur84y3aqu"),
	"Crazy": preload("uid://bkkm1mrkvayxv"),
	"Knight": preload("uid://p7a3x5qfwefg"),
	"Well Rounded": preload("uid://dif20onumbk7d")
}

enum UpgradeTier{
	COMMON,
	RARE,
	EPIC,
	LEGENDARY	
}

var player: Player
var game_paused := false
var coins: int = 500

var main_player_selected: UnitStats
var main_weapon_selected: ItemWeapon

var equipped_weapons: Array[ItemBase] = []

func get_harvesting_coins() -> void:
	coins += player.stats.harvesting

func get_selected_player() -> Player:
	var player_scene := available_players[main_player_selected.name]
	var player_instance := player_scene.instantiate()
	player = player_instance
	return player

func get_change_success(chance: float) -> bool:
	var random := randf_range(0, 1.0)
	if(random < chance):
		return true
	return false

func calculate_tier_probability(current_wave: int, config: Dictionary) -> Array[float]:
	var common_chance := 0.0
	var rare_chance := 0.0
	var epic_chance := 0.0
	var legendary_chance := 0.0
	
	if current_wave >= config.rare.start_wave:
		rare_chance = min(1.0, (current_wave - config.rare.start_wave + 1) * config.rare.base_multi)
		
	if current_wave >= config.epic.start_wave:
		epic_chance = min(1.0, (current_wave - config.epic.start_wave + 1) * config.epic.base_multi)
		
	if current_wave >= config.legendary.start_wave:
		legendary_chance = min(1.0, (current_wave - config.legendary.start_wave + 1) * config.legendary.base_multi)
	
	var luck_factor: float = (1.0 + (Global.player.stats.luck / 100.0))
	rare_chance *= luck_factor
	epic_chance *= luck_factor
	legendary_chance *= luck_factor
	
	# normalize probabilities
	var total_non_common_chances := rare_chance + epic_chance + legendary_chance
	if total_non_common_chances > 1.0:
		var scale_down := 1.0 / total_non_common_chances
		rare_chance *= scale_down
		epic_chance *= scale_down
		legendary_chance *= scale_down
		total_non_common_chances = 1.0
	
	common_chance = 1.0 - total_non_common_chances
	return [ 
		max(0.0, common_chance),
		max(0.0, rare_chance),
		max(0.0, epic_chance),
		max(0.0, legendary_chance),
	]

func select_items_for_offer(item_pool: Array, current_wave: int, config: Dictionary) -> Array:
	
	var tier_chances := calculate_tier_probability(current_wave, config)
	
	var common_limit = tier_chances[0]
	var epic_limit = tier_chances[1]
	var rare_limit = tier_chances[2]
	var legendary_limit = tier_chances[3]
	
	var offered_items : Array = []
	while(offered_items.size() < 4): 
		var roll := randf()
		var chosen_tier_index := 0
		if(roll < legendary_limit):
			chosen_tier_index = 3
		elif(roll < rare_limit):
			chosen_tier_index = 2
		elif(roll < epic_limit):
			chosen_tier_index = 1
		else: 
			chosen_tier_index = 0
			
		var potential_items: Array = []
		var current_search_tier_index := chosen_tier_index
		
		while potential_items.is_empty() and current_search_tier_index >= 0:
			potential_items = item_pool.filter( func(item:ItemBase): return item.item_tier == current_search_tier_index )
			if potential_items.is_empty():
				current_search_tier_index -= 1
			else:
				break
		
		if not potential_items.is_empty():
			var selected_item = potential_items.pick_random()
			
			if not offered_items.has(selected_item):
				offered_items.append(selected_item)
				
	return offered_items

func get_tier_styles(tier: UpgradeTier) -> StyleBoxFlat:
	match tier:
		UpgradeTier.COMMON:
			return COMMON_STYLES
		UpgradeTier.RARE:
			return RARE_STYLES
		UpgradeTier.EPIC:
			return EPIC_STYLES
		UpgradeTier.LEGENDARY:
			return LEGENDARY_STYLES
		_:
			return COMMON_STYLES
