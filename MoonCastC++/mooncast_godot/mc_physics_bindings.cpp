#include "mc_physics.hpp"

void MoonCastPhysicsTable::_bind_methods(){

	ClassDB::bind_method(D_METHOD("get_ground_velocity"), &MoonCastPhysicsTable::get_ground_velocity);
	ClassDB::bind_method(D_METHOD("set_ground_velocity", "ground_velocity"), &MoonCastPhysicsTable::set_ground_velocity);

	ClassDB::bind_method(D_METHOD("get_jump_spam_timer"), &MoonCastPhysicsTable::get_jump_spam_timer);
	ClassDB::bind_method(D_METHOD("set_jump_spam_timer", "jump_spam_timer"), &MoonCastPhysicsTable::set_jump_spam_timer);
	ClassDB::bind_method(D_METHOD("get_slip_timer"), &MoonCastPhysicsTable::get_slip_timer);
	ClassDB::bind_method(D_METHOD("set_slip_timer", "slip_timer"), &MoonCastPhysicsTable::set_slip_timer);
	ClassDB::bind_method(D_METHOD("get_is_movement_locked"), &MoonCastPhysicsTable::get_is_movement_locked);
	ClassDB::bind_method(D_METHOD("set_is_movement_locked", "is_movement_locked"), &MoonCastPhysicsTable::set_is_movement_locked);
	ClassDB::bind_method(D_METHOD("get_is_grounded"), &MoonCastPhysicsTable::get_is_grounded);
	ClassDB::bind_method(D_METHOD("set_is_grounded", "is_grounded"), &MoonCastPhysicsTable::set_is_grounded);
	ClassDB::bind_method(D_METHOD("get_is_rolling"), &MoonCastPhysicsTable::get_is_rolling);
	ClassDB::bind_method(D_METHOD("set_is_rolling", "is_rolling"), &MoonCastPhysicsTable::set_is_rolling);
	ClassDB::bind_method(D_METHOD("get_is_pushing"), &MoonCastPhysicsTable::get_is_pushing);
	ClassDB::bind_method(D_METHOD("set_is_pushing", "is_pushing"), &MoonCastPhysicsTable::set_is_pushing);
	ClassDB::bind_method(D_METHOD("get_on_ceiling"), &MoonCastPhysicsTable::get_on_ceiling);
	ClassDB::bind_method(D_METHOD("set_on_ceiling", "on_ceiling"), &MoonCastPhysicsTable::set_on_ceiling);
	ClassDB::bind_method(D_METHOD("get_on_wall"), &MoonCastPhysicsTable::get_on_wall);
	ClassDB::bind_method(D_METHOD("set_on_wall", "on_wall"), &MoonCastPhysicsTable::set_on_wall);


	ClassDB::bind_method(D_METHOD("get_control_3d_turn_around_threshold"), &MoonCastPhysicsTable::get_control_3d_turn_around_threshold);
	ClassDB::bind_method(D_METHOD("set_control_3d_turn_around_threshold", "control_3d_turn_around_threshold"), &MoonCastPhysicsTable::set_control_3d_turn_around_threshold);
	ClassDB::bind_method(D_METHOD("get_control_3d_turn_speed"), &MoonCastPhysicsTable::get_control_3d_turn_speed);
	ClassDB::bind_method(D_METHOD("set_control_3d_turn_speed", "control_3d_turn_speed"), &MoonCastPhysicsTable::set_control_3d_turn_speed);

	ClassDB::bind_method(D_METHOD("get_control_roll_move_lock"), &MoonCastPhysicsTable::get_control_roll_move_lock);
	ClassDB::bind_method(D_METHOD("set_control_roll_move_lock", "control_roll_move_lock"), &MoonCastPhysicsTable::set_control_roll_move_lock);
	ClassDB::bind_method(D_METHOD("get_control_roll_midair_activate"), &MoonCastPhysicsTable::get_control_roll_midair_activate);
	ClassDB::bind_method(D_METHOD("set_control_roll_midair_activate", "control_roll_midair_activate"), &MoonCastPhysicsTable::set_control_roll_midair_activate);
	ClassDB::bind_method(D_METHOD("get_control_jump_is_vulnerable"), &MoonCastPhysicsTable::get_control_jump_is_vulnerable);
	ClassDB::bind_method(D_METHOD("set_control_jump_is_vulnerable", "control_jump_is_vulnerable"), &MoonCastPhysicsTable::set_control_jump_is_vulnerable);
	ClassDB::bind_method(D_METHOD("get_control_jump_roll_lock"), &MoonCastPhysicsTable::get_control_jump_roll_lock);
	ClassDB::bind_method(D_METHOD("set_control_jump_roll_lock", "control_jump_roll_lock"), &MoonCastPhysicsTable::set_control_jump_roll_lock);
	ClassDB::bind_method(D_METHOD("get_control_jump_hold_repeat"), &MoonCastPhysicsTable::get_control_jump_hold_repeat);
	ClassDB::bind_method(D_METHOD("set_control_jump_hold_repeat", "control_jump_hold_repeat"), &MoonCastPhysicsTable::set_control_jump_hold_repeat);

	ClassDB::bind_method(D_METHOD("get_absolute_speed_cap"), &MoonCastPhysicsTable::get_absolute_speed_cap);
	ClassDB::bind_method(D_METHOD("set_absolute_speed_cap", "absolute_speed_cap"), &MoonCastPhysicsTable::set_absolute_speed_cap);
	ClassDB::bind_method(D_METHOD("get_wall_threshold"), &MoonCastPhysicsTable::get_wall_threshold);
	ClassDB::bind_method(D_METHOD("set_wall_threshold", "wall_threshold"), &MoonCastPhysicsTable::set_wall_threshold);
	ClassDB::bind_method(D_METHOD("get_physics_collision_power"), &MoonCastPhysicsTable::get_physics_collision_power);
	ClassDB::bind_method(D_METHOD("set_physics_collision_power", "physics_collision_power"), &MoonCastPhysicsTable::set_physics_collision_power);
	ClassDB::bind_method(D_METHOD("get_physics_weight"), &MoonCastPhysicsTable::get_physics_weight);
	ClassDB::bind_method(D_METHOD("set_physics_weight", "physics_weight"), &MoonCastPhysicsTable::set_physics_weight);

	ClassDB::bind_method(D_METHOD("get_ground_min_speed"), &MoonCastPhysicsTable::get_ground_min_speed);
	ClassDB::bind_method(D_METHOD("set_ground_min_speed", "ground_min_speed"), &MoonCastPhysicsTable::set_ground_min_speed);
	ClassDB::bind_method(D_METHOD("get_ground_stick_speed"), &MoonCastPhysicsTable::get_ground_stick_speed);
	ClassDB::bind_method(D_METHOD("set_ground_stick_speed", "ground_stick_speed"), &MoonCastPhysicsTable::set_ground_stick_speed);
	ClassDB::bind_method(D_METHOD("get_ground_top_speed"), &MoonCastPhysicsTable::get_ground_top_speed);
	ClassDB::bind_method(D_METHOD("set_ground_top_speed", "ground_top_speed"), &MoonCastPhysicsTable::set_ground_top_speed);
	ClassDB::bind_method(D_METHOD("get_ground_cap_speed"), &MoonCastPhysicsTable::get_ground_cap_speed);
	ClassDB::bind_method(D_METHOD("set_ground_cap_speed", "ground_cap_speed"), &MoonCastPhysicsTable::set_ground_cap_speed);
	ClassDB::bind_method(D_METHOD("get_ground_acceleration"), &MoonCastPhysicsTable::get_ground_acceleration);
	ClassDB::bind_method(D_METHOD("set_ground_acceleration", "ground_acceleration"), &MoonCastPhysicsTable::set_ground_acceleration);
	ClassDB::bind_method(D_METHOD("get_ground_deceleration"), &MoonCastPhysicsTable::get_ground_deceleration);
	ClassDB::bind_method(D_METHOD("set_ground_deceleration", "ground_deceleration"), &MoonCastPhysicsTable::set_ground_deceleration);
	ClassDB::bind_method(D_METHOD("get_ground_skid_speed"), &MoonCastPhysicsTable::get_ground_skid_speed);
	ClassDB::bind_method(D_METHOD("set_ground_skid_speed", "ground_skid_speed"), &MoonCastPhysicsTable::set_ground_skid_speed);
	ClassDB::bind_method(D_METHOD("get_ground_slip_time"), &MoonCastPhysicsTable::get_ground_slip_time);
	ClassDB::bind_method(D_METHOD("set_ground_slip_time", "ground_slip_time"), &MoonCastPhysicsTable::set_ground_slip_time);
	ClassDB::bind_method(D_METHOD("get_ground_slip_angle"), &MoonCastPhysicsTable::get_ground_slip_angle);
	ClassDB::bind_method(D_METHOD("set_ground_slip_angle", "ground_slip_angle"), &MoonCastPhysicsTable::set_ground_slip_angle);
	ClassDB::bind_method(D_METHOD("get_ground_fall_angle"), &MoonCastPhysicsTable::get_ground_fall_angle);
	ClassDB::bind_method(D_METHOD("set_ground_fall_angle", "ground_fall_angle"), &MoonCastPhysicsTable::set_ground_fall_angle);
	ClassDB::bind_method(D_METHOD("get_ground_slope_factor"), &MoonCastPhysicsTable::get_ground_slope_factor);
	ClassDB::bind_method(D_METHOD("set_ground_slope_factor", "ground_slope_factor"), &MoonCastPhysicsTable::set_ground_slope_factor);

	ClassDB::bind_method(D_METHOD("get_air_custom_gravity"), &MoonCastPhysicsTable::get_air_custom_gravity);
	ClassDB::bind_method(D_METHOD("set_air_custom_gravity", "air_custom_gravity"), &MoonCastPhysicsTable::set_air_custom_gravity);
	ClassDB::bind_method(D_METHOD("get_air_top_speed"), &MoonCastPhysicsTable::get_air_top_speed);
	ClassDB::bind_method(D_METHOD("set_air_top_speed", "air_top_speed"), &MoonCastPhysicsTable::set_air_top_speed);
	ClassDB::bind_method(D_METHOD("get_air_acceleration"), &MoonCastPhysicsTable::get_air_acceleration);
	ClassDB::bind_method(D_METHOD("set_air_acceleration", "air_acceleration"), &MoonCastPhysicsTable::set_air_acceleration);
	ClassDB::bind_method(D_METHOD("get_air_gravity_strength"), &MoonCastPhysicsTable::get_air_gravity_strength);
	ClassDB::bind_method(D_METHOD("set_air_gravity_strength", "air_gravity_strength"), &MoonCastPhysicsTable::set_air_gravity_strength);

	ClassDB::bind_method(D_METHOD("get_rolling_min_speed"), &MoonCastPhysicsTable::get_rolling_min_speed);
	ClassDB::bind_method(D_METHOD("set_rolling_min_speed", "rolling_min_speed"), &MoonCastPhysicsTable::set_rolling_min_speed);
	ClassDB::bind_method(D_METHOD("get_rolling_active_stop"), &MoonCastPhysicsTable::get_rolling_active_stop);
	ClassDB::bind_method(D_METHOD("set_rolling_active_stop", "rolling_active_stop"), &MoonCastPhysicsTable::set_rolling_active_stop);
	ClassDB::bind_method(D_METHOD("get_rolling_flat_factor"), &MoonCastPhysicsTable::get_rolling_flat_factor);
	ClassDB::bind_method(D_METHOD("set_rolling_flat_factor", "rolling_flat_factor"), &MoonCastPhysicsTable::set_rolling_flat_factor);
	ClassDB::bind_method(D_METHOD("get_rolling_uphill_factor"), &MoonCastPhysicsTable::get_rolling_uphill_factor);
	ClassDB::bind_method(D_METHOD("set_rolling_uphill_factor", "rolling_uphill_factor"), &MoonCastPhysicsTable::set_rolling_uphill_factor);
	ClassDB::bind_method(D_METHOD("get_rolling_downhill_factor"), &MoonCastPhysicsTable::get_rolling_downhill_factor);
	ClassDB::bind_method(D_METHOD("set_rolling_downhill_factor", "rolling_downhill_factor"), &MoonCastPhysicsTable::set_rolling_downhill_factor);

	ClassDB::bind_method(D_METHOD("get_jump_velocity"), &MoonCastPhysicsTable::get_jump_velocity);
	ClassDB::bind_method(D_METHOD("set_jump_velocity", "jump_velocity"), &MoonCastPhysicsTable::set_jump_velocity);
	ClassDB::bind_method(D_METHOD("get_jump_short_limit"), &MoonCastPhysicsTable::get_jump_short_limit);
	ClassDB::bind_method(D_METHOD("set_jump_short_limit", "jump_short_limit"), &MoonCastPhysicsTable::set_jump_short_limit);
	ClassDB::bind_method(D_METHOD("get_jump_spam_timer"), &MoonCastPhysicsTable::get_jump_spam_timer);
	ClassDB::bind_method(D_METHOD("set_jump_spam_timer", "jump_spam_timer"), &MoonCastPhysicsTable::set_jump_spam_timer);


	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "ground_velocity"), "set_ground_velocity", "get_ground_velocity");

	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "jump_spam_timer"), "set_jump_spam_timer", "get_jump_spam_timer");
	ADD_PROPERTY(PropertyInfo(Variant::OBJECT, "slip_timer"), "set_slip_timer", "get_slip_timer");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "is_movement_locked"), "set_is_movement_locked", "get_is_movement_locked");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "is_grounded"), "set_is_grounded", "get_is_grounded");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "is_rolling"), "set_is_rolling", "get_is_rolling");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "is_pushing"), "set_is_pushing", "get_is_pushing");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "on_ceiling"), "set_on_ceiling", "get_on_ceiling");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "on_wall"), "set_on_wall", "get_on_wall");


	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "control_3d_turn_around_threshold"), "set_control_3d_turn_around_threshold", "get_control_3d_turn_around_threshold");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "control_3d_turn_speed"), "set_control_3d_turn_speed", "get_control_3d_turn_speed");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "control_roll_move_lock"), "set_control_roll_move_lock", "get_control_roll_move_lock");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "control_roll_midair_activate"), "set_control_roll_midair_activate", "get_control_roll_midair_activate");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "control_jump_is_vulnerable"), "set_control_jump_is_vulnerable", "get_control_jump_is_vulnerable");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "control_jump_roll_lock"), "set_control_jump_roll_lock", "get_control_jump_roll_lock");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "control_jump_hold_repeat"), "set_control_jump_hold_repeat", "get_control_jump_hold_repeat");

	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "vertical_velocity_cap"), "set_vertical_velocity_cap", "get_vertical_velocity_cap");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "forward_velocity_cap"), "set_forward_velocity_cap", "get_forward_velocity_cap");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "strafe_velocity_cap"), "set_strafe_velocity_cap", "get_strafe_velocity_cap");

	ADD_PROPERTY(PropertyInfo(Variant::VECTOR3, "absolute_speed_cap"), "set_absolute_speed_cap", "get_absolute_speed_cap");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "wall_threshold"), "set_wall_threshold", "get_wall_threshold");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "physics_collision_power"), "set_physics_collision_power", "get_physics_collision_power");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "physics_weight"), "set_physics_weight", "get_physics_weight");

	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "ground_min_speed"), "set_ground_min_speed", "get_ground_min_speed");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "ground_stick_speed"), "set_ground_stick_speed", "get_ground_stick_speed");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "ground_top_speed"), "set_ground_top_speed", "get_ground_top_speed");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "ground_cap_speed"), "set_ground_cap_speed", "get_ground_cap_speed");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "ground_acceleration"), "set_ground_acceleration", "get_ground_acceleration");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "ground_deceleration"), "set_ground_deceleration", "get_ground_deceleration");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "ground_skid_speed"), "set_ground_skid_speed", "get_ground_skid_speed");

	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "ground_slip_time"), "set_ground_slip_time", "get_ground_slip_time");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "ground_slip_angle"), "set_ground_slip_angle", "get_ground_slip_angle");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "ground_fall_angle"), "set_ground_fall_angle", "get_ground_fall_angle");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "ground_slope_factor"), "set_ground_slope_factor", "get_ground_slope_factor");

	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "air_custom_gravity"), "set_air_custom_gravity", "get_air_custom_gravity");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "air_top_speed"), "set_air_top_speed", "get_air_top_speed");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "air_acceleration"), "set_air_acceleration", "get_air_acceleration");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "air_gravity_strength"), "set_air_gravity_strength", "get_air_gravity_strength");

	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "rolling_min_speed"), "set_rolling_min_speed", "get_rolling_min_speed");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "rolling_active_stop"), "set_rolling_active_stop", "get_rolling_active_stop");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "rolling_flat_factor"), "set_rolling_flat_factor", "get_rolling_flat_factor");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "rolling_uphill_factor"), "set_rolling_uphill_factor", "get_rolling_uphill_factor");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "rolling_downhill_factor"), "set_rolling_downhill_factor", "get_rolling_downhill_factor");

	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "jump_velocity"), "set_jump_velocity", "get_jump_velocity");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "jump_short_limit"), "set_jump_short_limit", "get_jump_short_limit");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "jump_spam_timer"), "set_jump_spam_timer", "get_jump_spam_timer");
};
