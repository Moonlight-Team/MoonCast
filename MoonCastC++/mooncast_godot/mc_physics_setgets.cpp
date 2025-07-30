#include "mc_physics.hpp"

real_t MoonCastPhysicsTable::get_ground_velocity(){
	return state.ground_velocity;
}

void MoonCastPhysicsTable::set_ground_velocity(real_t new_ground_velocity){
	state.ground_velocity = new_ground_velocity;
}

Vector3 MoonCastPhysicsTable::get_space_velocity(){
	return Vector3(state.strafe_velocity, state.vertical_velocity, state.forward_velocity);
}

void MoonCastPhysicsTable::set_space_velocity(Vector3 p_new_vel){
	state.strafe_velocity = p_new_vel.x;
	state.vertical_velocity = p_new_vel.y;
	state.forward_velocity = p_new_vel.z;
}

double MoonCastPhysicsTable::get_timer_jump_spam(){
	return state.jump_spam_timer;
}

void MoonCastPhysicsTable::set_timer_jump_spam(double new_jump_spam_timer){
	state.jump_spam_timer = new_jump_spam_timer;
}

double MoonCastPhysicsTable::get_slip_timer(){
	return state.slip_timer;
}

void MoonCastPhysicsTable::set_slip_timer(double new_slip_timer){
	state.slip_timer = new_slip_timer;
}

bool MoonCastPhysicsTable::get_is_movement_locked(){
	return state.is_movement_locked;
}

void MoonCastPhysicsTable::set_is_movement_locked(bool new_is_movement_locked){
	state.is_movement_locked = new_is_movement_locked;
}

bool MoonCastPhysicsTable::get_is_grounded(){
	return state.is_grounded;
}

void MoonCastPhysicsTable::set_is_grounded(bool new_is_grounded){
	state.is_grounded = new_is_grounded;
}

bool MoonCastPhysicsTable::get_is_rolling(){
	return state.is_rolling;
}

void MoonCastPhysicsTable::set_is_rolling(bool new_is_rolling){
	state.is_rolling = new_is_rolling;
}

bool MoonCastPhysicsTable::get_is_pushing(){
	return state.is_pushing;
}

void MoonCastPhysicsTable::set_is_pushing(bool new_is_pushing){
	state.is_pushing = new_is_pushing;
}

bool MoonCastPhysicsTable::get_on_ceiling(){
	return state.on_ceiling;
}

void MoonCastPhysicsTable::set_on_ceiling(bool new_on_ceiling){
	state.on_ceiling = new_on_ceiling;
}

bool MoonCastPhysicsTable::get_on_wall(){
	return state.on_wall;
}

void MoonCastPhysicsTable::set_on_wall(bool new_on_wall){
	state.on_wall = new_on_wall;
}

float MoonCastPhysicsTable::get_physics_collision_power(){
	return physics_collision_power;
}

void MoonCastPhysicsTable::set_physics_collision_power(float new_physics_collision_power){
	physics_collision_power = new_physics_collision_power;
}

float MoonCastPhysicsTable::get_physics_weight(){
	return physics_weight;
}

void MoonCastPhysicsTable::set_physics_weight(float new_physics_weight){
	physics_weight = new_physics_weight;
}

float MoonCastPhysicsTable::get_ground_min_speed(){
	return ground_min_speed;
}

void MoonCastPhysicsTable::set_ground_min_speed(float new_ground_min_speed){
	ground_min_speed = new_ground_min_speed;
}

float MoonCastPhysicsTable::get_ground_stick_speed(){
	return ground_stick_speed;
}

void MoonCastPhysicsTable::set_ground_stick_speed(float new_ground_stick_speed){
	ground_stick_speed = new_ground_stick_speed;
}

float MoonCastPhysicsTable::get_ground_top_speed(){
	return ground_top_speed;
}

void MoonCastPhysicsTable::set_ground_top_speed(float new_ground_top_speed){
	ground_top_speed = new_ground_top_speed;
}

float MoonCastPhysicsTable::get_ground_cap_speed(){
	return ground_cap_speed;
}

void MoonCastPhysicsTable::set_ground_cap_speed(float new_ground_cap_speed){
	ground_cap_speed = new_ground_cap_speed;
}

float MoonCastPhysicsTable::get_ground_acceleration(){
	return ground_acceleration;
}

void MoonCastPhysicsTable::set_ground_acceleration(float new_ground_acceleration){
	ground_acceleration = new_ground_acceleration;
}

float MoonCastPhysicsTable::get_ground_deceleration(){
	return ground_deceleration;
}

void MoonCastPhysicsTable::set_ground_deceleration(float new_ground_deceleration){
	ground_deceleration = new_ground_deceleration;
}

float MoonCastPhysicsTable::get_ground_skid_speed(){
	return ground_skid_speed;
}

void MoonCastPhysicsTable::set_ground_skid_speed(float new_ground_skid_speed){
	ground_skid_speed = new_ground_skid_speed;
}

float MoonCastPhysicsTable::get_ground_slip_angle(){
	return ground_slip_angle;
}

void MoonCastPhysicsTable::set_ground_slip_angle(float new_ground_slip_angle){
	ground_slip_angle = new_ground_slip_angle;
}

float MoonCastPhysicsTable::get_ground_slope_factor(){
	return ground_slope_factor;
}

void MoonCastPhysicsTable::set_ground_slope_factor(float new_ground_slope_factor){
	ground_slope_factor = new_ground_slope_factor;
}

float MoonCastPhysicsTable::get_air_top_speed(){
	return air_top_speed;
}

void MoonCastPhysicsTable::set_air_top_speed(float new_air_top_speed){
	air_top_speed = new_air_top_speed;
}

float MoonCastPhysicsTable::get_air_acceleration(){
	return air_acceleration;
}

void MoonCastPhysicsTable::set_air_acceleration(float new_air_acceleration){
	air_acceleration = new_air_acceleration;
}

float MoonCastPhysicsTable::get_air_gravity_strength(){
	return air_gravity_strength;
}

void MoonCastPhysicsTable::set_air_gravity_strength(float new_air_gravity_strength){
	air_gravity_strength = new_air_gravity_strength;
}

float MoonCastPhysicsTable::get_rolling_min_speed(){
	return rolling_min_speed;
}

void MoonCastPhysicsTable::set_rolling_min_speed(float new_rolling_min_speed){
	rolling_min_speed = new_rolling_min_speed;
}

float MoonCastPhysicsTable::get_rolling_active_stop(){
	return rolling_active_stop;
}

void MoonCastPhysicsTable::set_rolling_active_stop(float new_rolling_active_stop){
	rolling_active_stop = new_rolling_active_stop;
}

float MoonCastPhysicsTable::get_rolling_flat_factor(){
	return rolling_flat_factor;
}

void MoonCastPhysicsTable::set_rolling_flat_factor(float new_rolling_flat_factor){
	rolling_flat_factor = new_rolling_flat_factor;
}

float MoonCastPhysicsTable::get_rolling_uphill_factor(){
	return rolling_uphill_factor;
}

void MoonCastPhysicsTable::set_rolling_uphill_factor(float new_rolling_uphill_factor){
	rolling_uphill_factor = new_rolling_uphill_factor;
}

float MoonCastPhysicsTable::get_control_3d_turn_around_threshold(){
	return control_3d_turn_around_threshold;
}

void MoonCastPhysicsTable::set_control_3d_turn_around_threshold(float new_control_3d_turn_around_threshold){
	control_3d_turn_around_threshold = new_control_3d_turn_around_threshold;
}

float MoonCastPhysicsTable::get_control_3d_turn_speed(){
	return control_3d_turn_speed;
}

void MoonCastPhysicsTable::set_control_3d_turn_speed(float new_control_3d_turn_speed){
	control_3d_turn_speed = new_control_3d_turn_speed;
}

bool MoonCastPhysicsTable::get_control_roll_move_lock(){
	return control_roll_move_lock;
}

void MoonCastPhysicsTable::set_control_roll_move_lock(bool new_control_roll_move_lock){
	control_roll_move_lock = new_control_roll_move_lock;
}

bool MoonCastPhysicsTable::get_control_roll_midair_activate(){
	return control_roll_midair_activate;
}

void MoonCastPhysicsTable::set_control_roll_midair_activate(bool new_control_roll_midair_activate){
	control_roll_midair_activate = new_control_roll_midair_activate;
}

bool MoonCastPhysicsTable::get_control_jump_is_vulnerable(){
	return control_jump_is_vulnerable;
}

void MoonCastPhysicsTable::set_control_jump_is_vulnerable(bool new_control_jump_is_vulnerable){
	control_jump_is_vulnerable = new_control_jump_is_vulnerable;
}

bool MoonCastPhysicsTable::get_control_jump_roll_lock(){
	return control_jump_roll_lock;
}

void MoonCastPhysicsTable::set_control_jump_roll_lock(bool new_control_jump_roll_lock){
	control_jump_roll_lock = new_control_jump_roll_lock;
}

bool MoonCastPhysicsTable::get_control_jump_hold_repeat(){
	return control_jump_hold_repeat;
}

void MoonCastPhysicsTable::set_control_jump_hold_repeat(bool new_control_jump_hold_repeat){
	control_jump_hold_repeat = new_control_jump_hold_repeat;
}

Vector3 MoonCastPhysicsTable::get_absolute_speed_cap(){
	return absolute_speed_cap;
}

void MoonCastPhysicsTable::set_absolute_speed_cap(Vector3 new_absolute_speed_cap){
	absolute_speed_cap = new_absolute_speed_cap;
}

float MoonCastPhysicsTable::get_wall_threshold(){
	return wall_threshold;
}

void MoonCastPhysicsTable::set_wall_threshold(float new_wall_threshold){
	wall_threshold = new_wall_threshold;
}

float MoonCastPhysicsTable::get_ground_fall_angle(){
	return ground_fall_angle;
}

void MoonCastPhysicsTable::set_ground_fall_angle(float new_ground_fall_angle){
	ground_fall_angle = new_ground_fall_angle;
}

float MoonCastPhysicsTable::get_ground_slip_time(){
	return ground_slip_time;
}

void MoonCastPhysicsTable::set_ground_slip_time(float new_ground_slip_time){
	ground_slip_time = new_ground_slip_time;
}

bool MoonCastPhysicsTable::get_air_custom_gravity(){
	return air_custom_gravity;
}

void MoonCastPhysicsTable::set_air_custom_gravity(bool new_air_custom_gravity){
	air_custom_gravity = new_air_custom_gravity;
}



float MoonCastPhysicsTable::get_rolling_downhill_factor(){
	return rolling_downhill_factor;
}

void MoonCastPhysicsTable::set_rolling_downhill_factor(float new_rolling_downhill_factor){
	rolling_downhill_factor = new_rolling_downhill_factor;
}

float MoonCastPhysicsTable::get_jump_velocity(){
	return jump_velocity;
}

void MoonCastPhysicsTable::set_jump_velocity(float new_jump_velocity){
	jump_velocity = new_jump_velocity;
}

float MoonCastPhysicsTable::get_jump_short_limit(){
	return jump_short_limit;
}

void MoonCastPhysicsTable::set_jump_short_limit(float new_jump_short_limit){
	jump_short_limit = new_jump_short_limit;
}

float MoonCastPhysicsTable::get_jump_spam_timer(){
	return jump_spam_timer;
}

void MoonCastPhysicsTable::set_jump_spam_timer(float new_jump_spam_timer){
	jump_spam_timer = new_jump_spam_timer;
}

