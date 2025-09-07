extends Area2D
##A Sonic-styled item box. 
class_name ItemMonitor2D

enum BoxMode {
	Blank,
	OneUp,
	TenRings,
	BasicShield,
	SpeedShoes,
	
	Shuffle = 0xFF
}

const sprite_box_norm:Texture2D = preload("res://Demo/global_objects/item_monitor/item_monitor.tres")
const sprite_box_broken:Texture2D = preload("res://Demo/global_objects/item_monitor/item_monitor_broken.tres")

const sprite_1up:Texture2D = preload("res://Demo/global_objects/item_monitor/overlay_1up.tres")
const sprite_blank:Texture2D = preload("res://Demo/global_objects/item_monitor/overlay_blank.tres")
const sprite_10ring:Texture2D = preload("res://Demo/global_objects/item_monitor/overlay_ring.tres")
const sprite_shield:Texture2D = preload("res://Demo/global_objects/item_monitor/overlay_shield.tres")
const sprite_speedshoes:Texture2D = preload("res://Demo/global_objects/item_monitor/overlay_speed_shoes.tres")

@export var mode:BoxMode
##The state of the monitor.
@export var popped:bool = false
##The up direction for the monitor. If hit from the top, the player will bounce off of it. If hit from the sides, the player will
##either move through it (if rolling) or will collide with it like a wall. And from the bottom, the player will cause it to fall down.
@export var up_direction:Vector2 = Vector2.UP

@onready var box_sprite:Sprite2D = $"Box"
@onready var item_sprite:Sprite2D = $"ItemType"

func _ready() -> void:
	connect(&"body_entered", detect_player)
	
	set_physics_process(true)
	
	if popped:
		pop_monitor()
	else:
		un_pop_monitor()

func detect_player(body:Node2D) -> void:
	if body is MoonCastPlayer2D:
		
		var player:MoonCastPlayer2D = body as MoonCastPlayer2D
		
		if not player:
			push_error("Cast Failed!")
			return
		
		if not popped and (player.physics.is_rolling or player.physics.is_jumping):
			
			var approach_dot:float = absf(up_direction.dot(player.velocity.normalized()))
			
			if not player.physics.is_grounded and approach_dot > 0.5:
				#send the player up if they were approaching from above
				player.physics.vertical_velocity = -player.physics.vertical_velocity
			
			pop_monitor()
		else:
			#stay solid
			
			pass
	else:
		#stay solid
		pass

func pop_monitor() -> void:
	print("Item box ", name, " popped")
	popped = true
	box_sprite.texture = sprite_box_broken
	item_sprite.hide()
	set_deferred(&"process_mode", Node.PROCESS_MODE_DISABLED)

func un_pop_monitor() -> void:
	popped = false
	box_sprite.texture = sprite_box_norm
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
	item_sprite.show()
	set_deferred(&"process_mode", Node.PROCESS_MODE_PAUSABLE)
