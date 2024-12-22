extends MoonCastAbility

const switch_sfx_name:StringName = &"switch_character"

@export var button_switch:StringName

@export var skin_sfx:AudioStream

@export var skins:Array[SpriteFrames]

var current_skin:int = 0

func _setup_2D(player:MoonCastPlayer2D) -> void:
	player.add_edit_sound_effect(switch_sfx_name, skin_sfx)

func _post_physics_2D(player:MoonCastPlayer2D) -> void:
	if Input.is_action_just_pressed(button_switch):
		current_skin += 1
		if current_skin > skins.size() - 1:
			current_skin = 0
		
		player.node_animated_sprite.sprite_frames = skins[current_skin]
		
		player.play_sound_effect(switch_sfx_name)
