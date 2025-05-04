#ifndef MOONCAST_PLAYER_2D_H
#define MOONCAST_PLAYER_2D_H

#include "scene/2d/physics_body_2d.h"
#include "scene/2d/sprite.h"

#include "mooncast_macros.h"
#include "mc_physics.hpp"

class MoonCastAbility;

class MoonCastPlayer2D: public PhysicsBody2D {
	OBJ_TYPE(MoonCastPlayer2D, PhysicsBody2D);

public: //editor export variables
	VAR_SETGET_DEFINITION(bool, rotation_static_collision);
    VAR_SETGET_DEFINITION(bool, rotation_classic_snap);
    VAR_SETGET_DEFINITION(float, rotation_snap_interval);
    VAR_SETGET_DEFINITION(float, rotation_adjustment_speed);
    VAR_SETGET_DEFINITION(float, visual_rotation);

    VAR_SETGET_DEFINITION(StringName, sfx_jump_name);
    VAR_SETGET_DEFINITION(StringName, sfx_roll_name);
    VAR_SETGET_DEFINITION(StringName, sfx_skid_name);
    VAR_SETGET_DEFINITION(StringName, sfx_hurt_name);

    VAR_SETGET_DEFINITION(Ref<MoonCastPhysicsState>, physics);
    VAR_SETGET_DEFINITION(Ref<MoonCastControlTable>, controls);

    //camera stuff here

    VAR_SETGET_DEFINITION(Ref<MoonCastAnimation>, anim_stand);
    VAR_SETGET_DEFINITION(Ref<MoonCastAnimation>, anim_look_up);
    VAR_SETGET_DEFINITION(Ref<MoonCastAnimation>, anim_crouch);
    VAR_SETGET_DEFINITION(Ref<MoonCastAnimation>, anim_roll);
    VAR_SETGET_DEFINITION(Dictionary, anim_run);
    VAR_SETGET_DEFINITION(Dictionary, anim_skid);
    VAR_SETGET_DEFINITION(Ref<MoonCastAnimation>, anim_push);
    VAR_SETGET_DEFINITION(Ref<MoonCastAnimation>, anim_jump);
    VAR_SETGET_DEFINITION(Ref<MoonCastAnimation>, anim_free_fall);
    VAR_SETGET_DEFINITION(Ref<MoonCastAnimation>, anim_death);
    VAR_SETGET_DEFINITION(Dictionary, anim_death_custom);

    VAR_SETGET_DEFINITION(StringName, sfx_bus);
    VAR_SETGET_DEFINITION(Ref<AudioStream>, sfx_jump);
    VAR_SETGET_DEFINITION(Ref<AudioStream>, sfx_roll);
    VAR_SETGET_DEFINITION(Ref<AudioStream>, sfx_skid);
    VAR_SETGET_DEFINITION(Ref<AudioStream>, sfx_hurt);
    VAR_SETGET_DEFINITION(Dictionary, sfx_custom);

    VAR_SETGET_DEFINITION(Vector<MoonCastAbility*>, abilities);
    VAR_SETGET_DEFINITION(Dictionary, ability_data);

    Vector<MoonCastAbility*> state_abilities;

    VAR_SETGET_DEFINITION(Ref<MoonCastAnimation>, current_anim);

private: //state variables
	bool animation_set;
    bool animation_custom;

    AnimationPlayer *animations;
    Sprite2D *sprite_2d;
    StreamPlayer *sfx_player;
    float jump_timer;
    float control_lock_timer;
	float ground_snap_timer;
    float collision_angle;

    MoonCastPhysicsPacket state;

	//Vector<PhysicsServer2D::MotionResult> motion_results;
	//Vector<Ref<KinematicCollision2D>> slide_colliders;

    void detect_children();

    void draw_debug_info();

    void calculate_ray_points();

    void physics_process();

    void update_animations();

	void update_collision_rotation();

protected:
    static void _bind_methods();

public:

    void _notification(int what);

	void move_and_slide();

    MoonCastPlayer2D();

};
#endif
