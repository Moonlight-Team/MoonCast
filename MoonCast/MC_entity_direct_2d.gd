extends CollisionObject2D
##A new version of MoonCastEntity2D that provides extra options and a more consistent 
##API.
class_name MoonCastEntityDirect2D
##The mode this MoonCastEntity2D is in. If it's an area, it will behave like an
## Area2D node. If it's solid, it will behave like an AnimatableBody2D. If it's
##rigid, it will behave like a RigidBody2D
@export_enum("Area", "Solid", "Rigid") var mode:int
##Defines how this MoonCastEntity2D will check for its visibility, if it will at all.
@export_enum("None", "In Player Range", "On-Screen") var visiblity_detection:int

##Called when in a MoonCastPlayer2D comes into contact with this MoonCastEntity.
##This is either when a body collision occurs in Ridid/Solid mode, or when the player
##enters the bounds of the entity's area in area mode.
func _on_player_contact(player:MoonCastPlayer2D) -> void:
	pass

##Called every frame that there is a MoonCastPlayer2D within the bounds of 
##the MoonCastEntity, if the MoonCastEntity is on area mode.
func _player_in_bounds(player:MoonCastPlayer2D) -> void:
	pass
