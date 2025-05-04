#include "mc_physics.hpp"

bool MoonCastPhysicsState::get_is_moving(){
    return is.moving;
}

void MoonCastPhysicsState::set_is_moving(bool new_is_moving){
    is.moving = new_is_moving;
	can_be.crouching = not new_is_moving;
}

bool MoonCastPhysicsState::get_is_grounded(){
    return is.grounded;
}

void MoonCastPhysicsState::set_is_grounded(bool new_is_grounded){
	if (new_is_grounded){
		if (not is.grounded){
            land_on_ground();
		}
	} else {
		if (is.grounded){
            enter_air();
		}
	}
    is.grounded = new_is_grounded;
}

bool MoonCastPhysicsState::get_is_rolling(){
    return is.rolling;
}

void MoonCastPhysicsState::set_is_rolling(bool new_is_rolling){
    is.rolling = new_is_rolling;
	can_be.changing_direction = not is.rolling;
}

bool MoonCastPhysicsState::get_is_jumping(){
    return is.jumping;
}

void MoonCastPhysicsState::set_is_jumping(bool new_is_jumping){
    is.jumping = new_is_jumping;
}

bool MoonCastPhysicsState::get_is_balancing(){
    return is.balancing;
}

void MoonCastPhysicsState::set_is_balancing(bool new_is_balancing){
    is.balancing = new_is_balancing;
}

bool MoonCastPhysicsState::get_is_crouching(){
    return is.crouching;
}

void MoonCastPhysicsState::set_is_crouching(bool new_is_crouching){
    is.crouching = new_is_crouching;
}

bool MoonCastPhysicsState::get_is_changing_direction(){
    return is.changing_direction;
}

void MoonCastPhysicsState::set_is_changing_direction(bool new_is_changing_direction){
    is.changing_direction = new_is_changing_direction;
}

bool MoonCastPhysicsState::get_is_pushing(){
    return is.pushing;
}

void MoonCastPhysicsState::set_is_pushing(bool new_is_pushing){
    if (can_be.pushing){
        is.pushing = new_is_pushing;
    }
}

bool MoonCastPhysicsState::get_is_slipping(){
    return is.slipping;
}

void MoonCastPhysicsState::set_is_slipping(bool new_is_slipping){
    is.slipping = new_is_slipping;
}

bool MoonCastPhysicsState::get_is_in_cutscene(){
    return is.in_cutscene;
}

void MoonCastPhysicsState::set_is_in_cutscene(bool new_is_in_cutscene){
    is.in_cutscene = new_is_in_cutscene;
}

bool MoonCastPhysicsState::get_can_be_moving(){
    return can_be.moving;
}

void MoonCastPhysicsState::set_can_be_moving(bool new_can_be_moving){
    can_be.moving = new_can_be_moving;
}

bool MoonCastPhysicsState::get_can_be_grounded(){
    return can_be.grounded;
}

void MoonCastPhysicsState::set_can_be_grounded(bool new_can_be_grounded){
    can_be.grounded = new_can_be_grounded;
}

bool MoonCastPhysicsState::get_can_be_rolling(){
    return can_be.rolling;
}

void MoonCastPhysicsState::set_can_be_rolling(bool new_can_be_rolling){
	if(control_flags & ROLL_ENABLED){
        bool ground_check = (is.grounded ? true : control_flags & ROLL_MIDAIR_ACTIVATE);

        can_be.rolling = ground_check and new_can_be_rolling;

		if(control_flags & ROLL_MOVE_LOCK){
			//can_be.rolling = can_be.rolling and Math::is_zero_approx(input_direction);
		}

	} else {

		can_be.rolling = false;
	}
}

bool MoonCastPhysicsState::get_can_be_jumping(){
    return can_be.jumping;
}

void MoonCastPhysicsState::set_can_be_jumping(bool new_can_be_jumping){
	if (new_can_be_jumping and jump_timer <= 0.001f){
		can_be.jumping = new_can_be_jumping;
	}
}

bool MoonCastPhysicsState::get_can_be_balancing(){
    return can_be.balancing;
}

void MoonCastPhysicsState::set_can_be_balancing(bool new_can_be_balancing){
    can_be.balancing = new_can_be_balancing;
}

bool MoonCastPhysicsState::get_can_be_crouching(){
    return can_be.crouching;
}

void MoonCastPhysicsState::set_can_be_crouching(bool new_can_be_crouching){
    can_be.crouching = new_can_be_crouching;
}

bool MoonCastPhysicsState::get_can_be_changing_direction(){
    return can_be.changing_direction;
}

void MoonCastPhysicsState::set_can_be_changing_direction(bool new_can_be_changing_direction){
    can_be.changing_direction = new_can_be_changing_direction;
}

bool MoonCastPhysicsState::get_can_be_pushing(){
    return can_be.pushing;
}

void MoonCastPhysicsState::set_can_be_pushing(bool new_can_be_pushing){
    can_be.pushing = new_can_be_pushing;
}

bool MoonCastPhysicsState::get_can_be_slipping(){
    return can_be.slipping;
}

void MoonCastPhysicsState::set_can_be_slipping(bool new_can_be_slipping){
    can_be.slipping = new_can_be_slipping;
}

bool MoonCastPhysicsState::get_can_be_in_cutscene(){
    return can_be.in_cutscene;
}

void MoonCastPhysicsState::set_can_be_in_cutscene(bool new_can_be_in_cutscene){
    can_be.in_cutscene = new_can_be_in_cutscene;
}

void MoonCastPhysicsState::set_ground_velocity(float new_gvel)
{
	ground_velocity = new_gvel;
	is.moving = get_abs_ground_velocity() > ground_min_speed;

	//#Easy-access variable for the absolute value of [ground_velocity], because it's

}

float MoonCastPhysicsState::get_ground_velocity() {
	return ground_velocity;
}

#define GENERIC_SETGETS(class_name, type, var)\
type class_name::get_##var(){return var;};\
void class_name::set_##var(type new_##var){var = new_##var;};

GENERIC_SETGETS(MoonCastPhysicsState, float, ground_min_speed);
GENERIC_SETGETS(MoonCastPhysicsState, float, ground_stick_speed);
GENERIC_SETGETS(MoonCastPhysicsState, float, ground_top_speed);
GENERIC_SETGETS(MoonCastPhysicsState, float, ground_acceleration);
GENERIC_SETGETS(MoonCastPhysicsState, float, ground_deceleration);
GENERIC_SETGETS(MoonCastPhysicsState, float, ground_skid_speed);
GENERIC_SETGETS(MoonCastPhysicsState, float, ground_slope_factor);
GENERIC_SETGETS(MoonCastPhysicsState, float, air_top_speed);
GENERIC_SETGETS(MoonCastPhysicsState, float, air_acceleration);
GENERIC_SETGETS(MoonCastPhysicsState, float, air_gravity_strength);
GENERIC_SETGETS(MoonCastPhysicsState, float, rolling_min_speed);
GENERIC_SETGETS(MoonCastPhysicsState, float, rolling_active_stop);
GENERIC_SETGETS(MoonCastPhysicsState, float, rolling_flat_factor);
GENERIC_SETGETS(MoonCastPhysicsState, float, rolling_uphill_factor);
GENERIC_SETGETS(MoonCastPhysicsState, float, rolling_downhill_factor);
GENERIC_SETGETS(MoonCastPhysicsState, float, jump_velocity);
GENERIC_SETGETS(MoonCastPhysicsState, float, jump_short_limit);
GENERIC_SETGETS(MoonCastPhysicsState, float, jump_spam_timer);

#undef GENERIC_SETGETS
