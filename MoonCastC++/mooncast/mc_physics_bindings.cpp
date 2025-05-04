#include "mc_physics.hpp"

void MoonCastPhysicsState::_bind_methods(){
#define LOCAL_BINDING_CLASS MoonCastPhysicsState

    BIND_SETTER_AND_GETTER(ground_min_speed);
    BIND_SETTER_AND_GETTER(ground_stick_speed);
    BIND_SETTER_AND_GETTER(ground_top_speed);
    BIND_SETTER_AND_GETTER(ground_acceleration);
    BIND_SETTER_AND_GETTER(ground_deceleration);
    BIND_SETTER_AND_GETTER(ground_skid_speed);
    BIND_SETTER_AND_GETTER(ground_slope_factor);

    BIND_SETTER_AND_GETTER(air_top_speed);
    BIND_SETTER_AND_GETTER(air_acceleration);
    BIND_SETTER_AND_GETTER(air_gravity_strength);

    BIND_SETTER_AND_GETTER(rolling_min_speed);
    BIND_SETTER_AND_GETTER(rolling_active_stop);
    BIND_SETTER_AND_GETTER(rolling_flat_factor);
    BIND_SETTER_AND_GETTER(rolling_uphill_factor);
    BIND_SETTER_AND_GETTER(rolling_downhill_factor);

    BIND_SETTER_AND_GETTER(jump_velocity);
    BIND_SETTER_AND_GETTER(jump_short_limit);
    BIND_SETTER_AND_GETTER(jump_spam_timer);

	//ADD_GROUP("Ground", "ground_");
    BIND_EDITOR_PROPERTY(REAL, ground_stick_speed);
    BIND_EDITOR_PROPERTY(REAL, ground_top_speed);
    BIND_EDITOR_PROPERTY(REAL, ground_acceleration);
    BIND_EDITOR_PROPERTY(REAL, ground_deceleration);
    BIND_EDITOR_PROPERTY(REAL, ground_skid_speed);
    BIND_EDITOR_PROPERTY(REAL, ground_slope_factor);
    BIND_EDITOR_PROPERTY(REAL, ground_min_speed);

	//ADD_GROUP("Air", "air_");
    BIND_EDITOR_PROPERTY(REAL, air_top_speed);
    BIND_EDITOR_PROPERTY(REAL, air_acceleration);
    BIND_EDITOR_PROPERTY(REAL, air_gravity_strength);

	//ADD_GROUP("Rolling", "rolling_");
    BIND_EDITOR_PROPERTY(REAL, rolling_min_speed);
    BIND_EDITOR_PROPERTY(REAL, rolling_active_stop);
    BIND_EDITOR_PROPERTY(REAL, rolling_flat_factor);
    BIND_EDITOR_PROPERTY(REAL, rolling_uphill_factor);
    BIND_EDITOR_PROPERTY(REAL, rolling_downhill_factor);

	//ADD_GROUP("Jump", "jump_");
    BIND_EDITOR_PROPERTY(REAL, jump_velocity);
    BIND_EDITOR_PROPERTY(REAL, jump_short_limit);
    BIND_EDITOR_PROPERTY(REAL, jump_spam_timer);

    BIND_SETTER_AND_GETTER(is_moving);
    BIND_SETTER_AND_GETTER(is_grounded);
    BIND_SETTER_AND_GETTER(is_rolling);
    BIND_SETTER_AND_GETTER(is_jumping);
    BIND_SETTER_AND_GETTER(is_balancing);
    BIND_SETTER_AND_GETTER(is_crouching);
    BIND_SETTER_AND_GETTER(is_changing_direction);
    BIND_SETTER_AND_GETTER(is_pushing);
    BIND_SETTER_AND_GETTER(is_slipping);
    BIND_SETTER_AND_GETTER(is_in_cutscene);

    BIND_SETTER_AND_GETTER(can_be_moving);
    BIND_SETTER_AND_GETTER(can_be_grounded);
    BIND_SETTER_AND_GETTER(can_be_rolling);
    BIND_SETTER_AND_GETTER(can_be_jumping);
    BIND_SETTER_AND_GETTER(can_be_balancing);
    BIND_SETTER_AND_GETTER(can_be_crouching);
    BIND_SETTER_AND_GETTER(can_be_changing_direction);
    BIND_SETTER_AND_GETTER(can_be_pushing);
    BIND_SETTER_AND_GETTER(can_be_slipping);
    BIND_SETTER_AND_GETTER(can_be_in_cutscene);

    BIND_STORED_PROPERTY(BOOL, is_moving);
    BIND_STORED_PROPERTY(BOOL, is_grounded);
    BIND_STORED_PROPERTY(BOOL, is_rolling);
    BIND_STORED_PROPERTY(BOOL, is_jumping);
    BIND_STORED_PROPERTY(BOOL, is_balancing);
    BIND_STORED_PROPERTY(BOOL, is_crouching);
    BIND_STORED_PROPERTY(BOOL, is_changing_direction);
    BIND_STORED_PROPERTY(BOOL, is_pushing);
    BIND_STORED_PROPERTY(BOOL, is_slipping);
    BIND_STORED_PROPERTY(BOOL, is_in_cutscene);

    BIND_STORED_PROPERTY(BOOL, can_be_moving);
    BIND_STORED_PROPERTY(BOOL, can_be_grounded);
    BIND_STORED_PROPERTY(BOOL, can_be_rolling);
    BIND_STORED_PROPERTY(BOOL, can_be_jumping);
    BIND_STORED_PROPERTY(BOOL, can_be_balancing);
    BIND_STORED_PROPERTY(BOOL, can_be_crouching);
    BIND_STORED_PROPERTY(BOOL, can_be_changing_direction);
    BIND_STORED_PROPERTY(BOOL, can_be_pushing);
    BIND_STORED_PROPERTY(BOOL, can_be_slipping);
    BIND_STORED_PROPERTY(BOOL, can_be_in_cutscene);

#undef MC_INTERNAL_BOOL
};
