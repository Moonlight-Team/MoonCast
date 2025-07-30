#include "register_types.h"

#include "mc_physics.hpp"
#include "modules/register_module_types.h"
#include "mooncast_ability.hpp"

#include "mooncast_player_2d.hpp"

void initialize_mooncast_godot_module(ModuleInitializationLevel p_level){
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE){
		return;
	}

	GDREGISTER_CLASS(MoonCastPhysicsTable);
	GDREGISTER_CLASS(MoonCastAbility);
	GDREGISTER_CLASS(MoonCastAnimation);
	GDREGISTER_CLASS(MoonCastControlTable);

	//GDREGISTER_CLASS(MoonCastPlayer2D);

}



void uninitialize_mooncast_godot_module(ModuleInitializationLevel p_level){

}
