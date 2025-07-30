#ifndef MOONCAST_CORE_H
#define MOONCAST_CORE_H

#include "servers/audio/audio_stream.h"
#include "scene/animation/animation_player.h"
#include "scene/audio/audio_stream_player.h"

#include "mooncast_resources.hpp"

#include "scene/resources/2d/shape_2d.h"
#include "scene/resources/3d/shape_3d.h"

//This is the internal state class, and the location of most of the physics code, of MoonCast
struct MoonCastPhysicsState {
	friend class MoonCastPlayer2D;
	friend class MoonCastPlayer3D;
	public: //enums/typedefs
		enum AnimationTypes :uint8_t {
			ANIM_DEFAULT,
			ANIM_STAND,
			ANIM_LOOK_UP,
			ANIM_BALANCE,
			ANIM_CROUCH,
			ANIM_ROLL,
			ANIM_PUSH,
			ANIM_JUMP,
			ANIM_FREE_FALL,
			ANIM_DEATH,
			ANIM_RUN,
			ANIM_SKID,
		};

		enum SoundEffectTypes {
			SFX_NONE,
			SFX_JUMP,
			SFX_ROLL,
			SFX_SKID,
			SFX_HURT,
		};

	double jump_spam_timer;
	double slip_timer;

	real_t ground_velocity;
	//space velocity
	real_t forward_velocity;
	real_t vertical_velocity;
	real_t strafe_velocity; //only really relevant in 3D, but kept track of regardless

	double timer_jump_spam;
	double timer_slip;

	bool is_movement_locked;
	bool is_grounded;
	bool is_rolling;
	bool is_pushing;
	bool on_ceiling;
	bool on_wall;

    bool on_wall_only(){return on_wall and not is_grounded and not on_ceiling;}
    bool on_floor_only(){return is_grounded and not on_wall and not on_ceiling;}
    bool on_ceiling_only(){return on_ceiling and not is_grounded and not on_wall;}

	void start_jump_timer();

	void update_timers(double p_delta);

	void update_wall_checks(float p_wall_dot, float p_push_dot);

	void ground_update_inputs(bool p_jump_pressed, bool p_crouch_pressed, bool p_movement_input);
	void ground_process_slope(float p_slope_dot);
	void ground_process_input(float p_velocity_dot, float p_acceleration);
	void ground_roll_update();
	void ground_wall_checks();
	//move player
	void ground_fall_slip_checks();


	void air_update_inputs(bool p_jump_pressed, bool p_crouch_pressed, bool p_movement_input);
	void air_process_input(float p_velocity_dot, float p_acceleration);
	void air_apply_drag();

	//move player
	void air_apply_gravity();

	void air_collision_checks();
	//update_wall_checks
	void air_landing_checks();

};

class MoonCastPhysicsTable : public Resource {
	GDCLASS(MoonCastPhysicsTable, Resource);

	MoonCastPhysicsState state;

	Vector3 absolute_speed_cap;

	float control_3d_turn_around_threshold;
	float control_3d_turn_speed;
	float wall_threshold;

	float physics_collision_power;
	float physics_weight;

	float ground_min_speed;
	float ground_stick_speed;
	float ground_top_speed;
	float ground_cap_speed;
	float ground_acceleration;
	float ground_deceleration;
	float ground_skid_speed;
	float ground_slip_time;
	float ground_slip_angle;
	float ground_fall_angle;
	float ground_slope_factor;

	float air_top_speed;
	float air_acceleration;
	float air_gravity_strength;

	float rolling_min_speed;
	float rolling_active_stop;
	float rolling_flat_factor;
	float rolling_uphill_factor;
	float rolling_downhill_factor;

	float jump_velocity;
	float jump_short_limit;
	float jump_spam_timer;


	bool air_custom_gravity;
	bool control_roll_move_lock;
	bool control_roll_midair_activate;
	bool control_jump_is_vulnerable;
	bool control_jump_roll_lock;
	bool control_jump_hold_repeat;



public:
	//proxy setgets for PhysicsState variables

	real_t get_ground_velocity();
	void set_ground_velocity(real_t new_ground_velocity);

	Vector3 get_space_velocity();
	void set_space_velocity(Vector3 p_new_velocity);

	double get_timer_jump_spam();
	void set_timer_jump_spam(double new_jump_spam_timer);
	double get_slip_timer();
	void set_slip_timer(double new_slip_timer);

	bool get_is_movement_locked();
	void set_is_movement_locked(bool new_is_movement_locked);
	bool get_is_grounded();
	void set_is_grounded(bool new_is_grounded);
	bool get_is_rolling();
	void set_is_rolling(bool new_is_rolling);
	bool get_is_pushing();
	void set_is_pushing(bool new_is_pushing);
	bool get_on_ceiling();
	void set_on_ceiling(bool new_on_ceiling);
	bool get_on_wall();
	void set_on_wall(bool new_on_wall);

	//Editor exported config variables

	float get_control_3d_turn_around_threshold();
	void set_control_3d_turn_around_threshold(float new_control_3d_turn_around_threshold);
	float get_control_3d_turn_speed();
	void set_control_3d_turn_speed(float new_control_3d_turn_speed);
	bool get_control_roll_move_lock();
	void set_control_roll_move_lock(bool new_control_roll_move_lock);
	bool get_control_roll_midair_activate();
	void set_control_roll_midair_activate(bool new_control_roll_midair_activate);
	bool get_control_jump_is_vulnerable();
	void set_control_jump_is_vulnerable(bool new_control_jump_is_vulnerable);
	bool get_control_jump_roll_lock();
	void set_control_jump_roll_lock(bool new_control_jump_roll_lock);
	bool get_control_jump_hold_repeat();
	void set_control_jump_hold_repeat(bool new_control_jump_hold_repeat);

	Vector3 get_absolute_speed_cap();
	void set_absolute_speed_cap(Vector3 new_absolute_speed_cap);
	float get_physics_collision_power();
	void set_physics_collision_power(float new_physics_collision_power);
	float get_physics_weight();
	void set_physics_weight(float new_physics_weight);
	float get_wall_threshold();
	void set_wall_threshold(float new_wall_threshold);

	float get_ground_min_speed();
	void set_ground_min_speed(float new_ground_min_speed);
	float get_ground_stick_speed();
	void set_ground_stick_speed(float new_ground_stick_speed);
	float get_ground_top_speed();
	void set_ground_top_speed(float new_ground_top_speed);
	float get_ground_cap_speed();
	void set_ground_cap_speed(float new_ground_cap_speed);
	float get_ground_acceleration();
	void set_ground_acceleration(float new_ground_acceleration);
	float get_ground_deceleration();
	void set_ground_deceleration(float new_ground_deceleration);
	float get_ground_skid_speed();
	void set_ground_skid_speed(float new_ground_skid_speed);
	float get_ground_slip_time();
	void set_ground_slip_time(float new_ground_slip_time);
	float get_ground_slip_angle();
	void set_ground_slip_angle(float new_ground_slip_angle);
	float get_ground_fall_angle();
	void set_ground_fall_angle(float new_ground_fall_angle);
	float get_ground_slope_factor();
	void set_ground_slope_factor(float new_ground_slope_factor);

	bool get_air_custom_gravity();
	void set_air_custom_gravity(bool new_air_custom_gravity);
	float get_air_top_speed();
	void set_air_top_speed(float new_air_top_speed);
	float get_air_acceleration();
	void set_air_acceleration(float new_air_acceleration);
	float get_air_gravity_strength();
	void set_air_gravity_strength(float new_air_gravity_strength);

	float get_rolling_min_speed();
	void set_rolling_min_speed(float new_rolling_min_speed);
	float get_rolling_active_stop();
	void set_rolling_active_stop(float new_rolling_active_stop);
	float get_rolling_flat_factor();
	void set_rolling_flat_factor(float new_rolling_flat_factor);
	float get_rolling_uphill_factor();
	void set_rolling_uphill_factor(float new_rolling_uphill_factor);
	float get_rolling_downhill_factor();
	void set_rolling_downhill_factor(float new_rolling_downhill_factor);

	float get_jump_velocity();
	void set_jump_velocity(float new_jump_velocity);
	float get_jump_short_limit();
	void set_jump_short_limit(float new_jump_short_limit);
	float get_jump_spam_timer();
	void set_jump_spam_timer(float new_jump_spam_timer);


protected:
	static void _bind_methods();

};


#endif
