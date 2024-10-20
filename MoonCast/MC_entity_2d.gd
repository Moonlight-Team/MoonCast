extends Area2D
##Base entity for everything that interacts with [class MoonCastPlayer2D].
class_name MoonCastEntity2D

func _init() -> void:
	connect(&"body_entered", validate_player_contact)

##Internal function used by 
func validate_player_contact(contact:Node2D) -> void:
	#this is a roundabout check to get around GDScript classes not being recognized
	#by get_class()
	if contact.has_meta(&"is_player"):
		_on_player_contact(contact as MoonCastPlayer2D)
		
		var vertical_difference:float 
		var horizontal_difference:float
		#if the player is to the left
		if contact.global_position.x < global_position.x:
			horizontal_difference = global_position.x - contact.global_position.x
		else:
			horizontal_difference = contact.global_position.x - global_position.x
		#if the player is above 
		if contact.global_position.y < global_position.y:
			vertical_difference = global_position.y - contact.global_position.y
		else:
			vertical_difference = contact.global_position.y - global_position.y
		
		var vertical_wins:bool = vertical_difference > horizontal_difference
		
		if vertical_wins:
			_on_vertical_player_contact(contact as MoonCastPlayer2D)
		else:
			_on_horizontal_player_contact(contact as MoonCastPlayer2D)

##Virtual function called when this [MoonCastEntity] comes into contact with
##a [MoonCastPlayer2D]. This is called before [member _on_horizontal_player_contact] and
##[member _on_vertical_player_contact].
@warning_ignore("unused_parameter")
func _on_player_contact(player:MoonCastPlayer2D) -> void:
	pass

##Virtual function called when a horizontal quadrant of this [MoonCastEntity] comes 
##into contact with a [MoonCastPlayer2D].
@warning_ignore("unused_parameter")
func _on_horizontal_player_contact(player:MoonCastPlayer2D) -> void:
	pass

##Virtual function called when a horizontal quadrant of this [MoonCastEntity] comes 
##into contact with a [MoonCastPlayer2D].
@warning_ignore("unused_parameter")
func _on_vertical_player_contact(player:MoonCastPlayer2D) -> void:
	pass
