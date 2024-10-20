extends MoonCastEntity2D

class_name ItemBox2D

enum BoxMode {
	Blank,
	OneUp,
	TenRings,
	BasicShield,
	SpeedShoes,
	
	
	Shuffle = 0xFF
}

const sprite_box_norm:Texture2D = preload("res://Demo/assets/global_objects/item_monitor.tres")
const sprite_box_broken:Texture2D = preload("res://Demo/assets/global_objects/item_monitor_broken.tres")

const sprite_1up:Texture2D = preload("res://Demo/assets/global_objects/overlay_1up.tres")
const sprite_blank:Texture2D = preload("res://Demo/assets/global_objects/overlay_blank.tres")
const sprite_10ring:Texture2D = preload("res://Demo/assets/global_objects/overlay_ring.tres")
const sprite_shield:Texture2D = preload("res://Demo/assets/global_objects/overlay_shield.tres")
const sprite_speedshoes:Texture2D = preload("res://Demo/assets/global_objects/speed_shoes_overlay.tres")

@export var mode:BoxMode

@export var popped:bool = false

@onready var box_sprite:Sprite2D = $"Box"
@onready var item_sprite:Sprite2D = $"ItemType"

func _ready() -> void:
	if popped:
		pop_monitor()
	else:
		match mode:
			BoxMode.Blank:
				item_sprite.texture = sprite_blank
			BoxMode.OneUp:
				item_sprite.texture = sprite_1up
			BoxMode.TenRings:
				item_sprite.texture = sprite_10ring
			BoxMode.BasicShield:
				item_sprite.texture = sprite_shield
			BoxMode.SpeedShoes:
				item_sprite.texture = sprite_speedshoes

func _on_vertical_player_contact(player:MoonCastPlayer2D) -> void:
	if not popped and player.is_attacking:
		player.space_velocity.y = -player.space_velocity.y
		pop_monitor()

func _on_horizontal_player_contact(player:MoonCastPlayer2D) -> void:
	if not popped and player.is_attacking:
		pop_monitor()

func pop_monitor() -> void:
	popped = true
	box_sprite.texture = sprite_box_broken
	item_sprite.hide()
	set_deferred(&"process_mode", Node.PROCESS_MODE_DISABLED)
