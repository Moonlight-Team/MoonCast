@icon("res://MoonCast/assets/MoonCastAbility.png")
extends Node
##The base class for creating modular character abilities in MoonCast
class_name MoonCastAbility
##If this MoonCastAbility will be active
@export var active:bool = true

#Sidestep for the fact that GDScript classes can't be identified by get_class()
func _init() -> void:
	set_meta(&"Ability_flag", true)

#func _setup(physics:MoonCastPhysicsTable) -> void:
	#pass

#func _pre_physics(physics:MoonCastPhysicsTable) -> void:
	#pass

#func _post_physics(physics:MoonCastPhysicsTable) -> void:
	#pass

#func _hurt(physics:MoonCastPhysicsTable) -> void:
	#pass

#func _jump(physics:MoonCastPhysicsTable) -> void:
	#pass

#func _air_contact(physics:MoonCastPhysicsTable) -> void:
	#pass

#func _air_state(physics:MoonCastPhysicsTable) -> void:
	#pass

#func _ground_contact(physics:MoonCastPhysicsTable) -> void:
	#pass

#func _ground_state(physics:MoonCastPhysicsTable) -> void:
	#pass

#func _wall_contact(physics:MoonCastPhysicsTable) -> void:
	#pass

#func _setup_custom_state(physics:MoonCastPhysicsTable) -> void:
	#pass

#func _custom_state(physics:MoonCastPhysicsTable) -> bool:
	#return true


#func _setup_2D(player:MoonCastPlayer2D) -> void:
	#pass

#func _pre_physics_2D(player:MoonCastPlayer2D) -> void:
	#pass

#func _post_physics_2D(player:MoonCastPlayer2D) -> void:
	#pass

#func _hurt_2D(player:MoonCastPlayer2D) -> void:
	#pass

#func _jump_2D(player:MoonCastPlayer2D) -> void:
	#pass

#func _air_contact_2D(player:MoonCastPlayer2D) -> void:
	#pass

#func _air_state_2D(player:MoonCastPlayer2D) -> void:
	#pass

#func _ground_contact_2D(player:MoonCastPlayer2D) -> void:
	#pass

#func _ground_state_2D(player:MoonCastPlayer2D) -> void:
	#pass

#func _wall_contact_2D(player:MoonCastPlayer2D) -> void:
	#pass

#func _setup_custom_state_2D(player:MoonCastPlayer2D) -> void:
	#pass

#func _custom_state_2D(player:MoonCastPlayer2D) -> bool:
	#return true
