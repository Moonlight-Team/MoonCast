/*************************************************/
/*  register_script_types.cpp                    */
/*************************************************/
/*            This file is part of:              */
/*                GODOT ENGINE                   */
/*************************************************/
/*       Source code within this file is:        */
/*  (c) 2007-2010 Juan Linietsky, Ariel Manzur   */
/*             All Rights Reserved.              */
/*************************************************/

#include "register_types.h"
#include "core/object_type_db.h"

#include "mc_physics.hpp"
#include "mooncast_ability.hpp"

#include "mooncast_player_2d.hpp"

void register_mooncast_types() {
	REGISTER_OBJECT(MoonCastPhysicsState);
	REGISTER_OBJECT(MoonCastAbility);
	REGISTER_OBJECT(MoonCastAnimation);
	REGISTER_OBJECT(MoonCastControlTable);


	REGISTER_OBJECT(MoonCastPlayer2D);

}

void unregister_mooncast_types() {

}
