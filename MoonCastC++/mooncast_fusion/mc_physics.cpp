#include "mc_physics.hpp"

bool floor_is_fall_angle = false;
float forward_axis = 0.0f;


void MoonCastPhysicsState::enter_air(){
	//collision_angle = 0.0f;
	//up_direction = default_up_direction;

	emit_signal("contact_air", this);
}

void MoonCastPhysicsState::land_on_ground(){
	//Transfer space_velocity to ground_velocity
	Vector2 applied_ground_speed; applied_ground_speed.set_rotation(collision_angle);
	applied_ground_speed *= Vector2(space_velocity.z, space_velocity.y);
	ground_velocity = applied_ground_speed.x + applied_ground_speed.y;

	//land in a roll if the player can
	if(get_can_be_rolling() && false){
		//and Input.is_action_pressed(controls.action_roll):
		is.rolling = true;
	}

	//play_sound_effect(sfx_roll_name)
	else {
		is.rolling = false;
	}
}

bool MoonCastPhysicsState::process_air(MoonCastPhysicsPacket &p_state){
    //allow midair rolling if it's enabled
    if (not is.rolling){ //TODO: The actual other checks here
        is.rolling = true;
        //sfx_callback(sfx_roll_name)
    }
    //only move if the player does not have the roll lock or has it and is not rolling in a jump
    bool movable = (control_flags & JUMP_ROLL_LOCK) ? false : is.jumping not_eq is.rolling;
    if (movable){
        if ((SGN(space_velocity.z) != SGN(forward_axis)) or (Math::absf(space_velocity.z) < air_top_speed)){
            //Only let the player move in midair if they aren't already at max speed
            space_velocity.z += air_acceleration * forward_axis;
        }
    }
    //calculate air drag. This makes it so that the player moves at a slightly
    //slower horizontal speed when jumping up, before hitting the [jump_short_limit].
    if (space_velocity.y < 0 and space_velocity.y > -jump_short_limit){
        space_velocity.z -= (space_velocity.z * 0.125f) / 256.0f;
    }
    //apply gravity
    space_velocity.y += air_gravity_strength;

    return true;
}

bool MoonCastPhysicsState::process_ground(MoonCastPhysicsPacket &p_state){

    p_state.ground_angle = Math::stepify(p_state.ground_angle, 0.01f);

    float sine_ground_angle = Math::sin(p_state.ground_angle);

    //Calculate movement based on the mode
    if (is.rolling) {
        float prev_ground_vel_sign = SGN(ground_velocity);

        //Apply slope factors

        if (Math::stepify(p_state.ground_angle, 0.01f) == 0.0f){ //Level ground
            ground_velocity -= rolling_flat_factor * forward_axis;

            //Stop the player if they turn around
            if (SGN(ground_velocity) != prev_ground_vel_sign){ground_velocity = 0.0f;}
        } else { //A hill of some sort
            float factor = (SGN(ground_velocity) == SGN(sine_ground_angle)) ? rolling_downhill_factor : rolling_uphill_factor;

            ground_velocity += factor * sine_ground_angle;
        }

        //Allow the player to actively slow down if they try to move in the opposite direction
        if (SGN(forward_axis) != SGN(ground_velocity)){
            ground_velocity += rolling_active_stop * forward_axis;
        }

        //Stop the player if they turn around
        if (SGN(ground_velocity) != prev_ground_vel_sign){
            ground_velocity = 0.0f;
            is.rolling = false;
        }
    } else { //slope factors for being on foot

        if (is.moving or is.slipping){
            ground_velocity += ground_slope_factor * sine_ground_angle;
        } else {
            if (floor_is_fall_angle){
                ground_velocity += ground_slope_factor * sine_ground_angle;
            }
        }
    }

    //Do rolling or crouching checks

    if (get_abs_ground_velocity() > rolling_min_speed){
        is.crouching = false;

        //Roll if the player tries to, and is not already rolling
    } else {
        can_be.rolling = false;
        if (ground_velocity == 0.0f and is.rolling){
            is.rolling = false;
        }
        //don't allow crouching when balacing
        if (not is.balancing){

        }
    }
    return true;
}
