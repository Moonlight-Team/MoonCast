#ifndef MOONCAST_CORE_H
#define MOONCAST_CORE_H

#include "scene/main/timer.h"
#include "scene/resources/audio_stream.h"
#include "scene/animation/animation_player.h"
#include "scene/audio/stream_player.h"

#include "mooncast_macros.h"
#include "mooncast_resources.hpp"

typedef void (*mooncast_signal)();

struct MoonCastPhysicsPacket {
    Vector3 travel_direction;
    Vector2 input_direction;

    float delta;
    float ground_angle;
    bool on_ceiling;
    bool on_wall;
    bool on_floor;

    bool on_wall_only(){return on_wall and not on_floor and not on_ceiling;}
    bool on_floor_only(){return on_floor and not on_wall and not on_ceiling;}
    bool on_ceiling_only(){return on_ceiling and not on_floor and not on_wall;}

};

//A class for storing and computing physics stats and other player specific,
class MoonCastPhysicsState: public Resource {
	OBJ_TYPE(MoonCastPhysicsState, Resource);
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

    enum ControlFlags : uint32_t {
        ROLL_ENABLED = 1 << 0,
        ROLL_MOVE_LOCK = 1 << 1,
        ROLL_MIDAIR_ACTIVATE = 1 << 2,
        JUMP_IS_VULNERABLE = 1 << 3,
        JUMP_ROLL_LOCK = 1 << 4,
        JUMP_HOLD_REPEAT = 1 << 5
    };

    enum StateFlags {
        FLAG_MOVING = 1 << 0,
        FLAG_GROUNDED = 1 << 1,
        FLAG_ROLLING = 1 << 2,
        FLAG_JUMPING = 1 << 3,

        FLAG_BALANCING = 1 << 4,
        FLAG_CROUCHING = 1 << 5,
        FLAG_CHANGING_DIRECTION = 1 << 6,
        FLAG_PUSHING = 1 << 7,

        FLAG_SLIPPING = 1 << 8,
        FLAG_CUTSCENE = 1 << 9
    };

    typedef struct PhysicsState {
        bool moving :1;
        bool grounded :1;
        bool rolling :1;
        bool jumping :1;

        bool balancing :1;
        bool crouching :1;
        bool changing_direction :1;
        bool pushing :1;

        bool slipping :1;
        bool in_cutscene :1;
        int : 2;

        int : 4;
    } PhysicsState;

private: //Internal variables
    PhysicsState can_be;
    PhysicsState is;

    uint32_t control_flags;
    float jump_timer; //actual timer

public:
    //Editor exported variables
    VAR_SETGET_DECLARATION(Vector3, absolute_speed_cap);
    VAR_SETGET_DECLARATION(Vector3, gravity_up_direction);
    VAR_SETGET_DECLARATION(float, physics_collision_power);
    VAR_SETGET_DECLARATION(float, physics_weight);

    VAR_SETGET_DECLARATION(float, ground_min_speed);
    VAR_SETGET_DECLARATION(float, ground_stick_speed);
    VAR_SETGET_DECLARATION(float, ground_top_speed);
    VAR_SETGET_DECLARATION(float, ground_cap_speed);
    VAR_SETGET_DECLARATION(float, ground_acceleration);
    VAR_SETGET_DECLARATION(float, ground_deceleration);
    VAR_SETGET_DECLARATION(float, ground_skid_speed);
    VAR_SETGET_DECLARATION(float, ground_slip_angle);
    VAR_SETGET_DECLARATION(float, ground_slope_factor);

    VAR_SETGET_DECLARATION(float, air_top_speed);
    VAR_SETGET_DECLARATION(float, air_acceleration);
    VAR_SETGET_DECLARATION(float, air_gravity_strength);

	VAR_SETGET_DECLARATION(float, rolling_min_speed);
    VAR_SETGET_DECLARATION(float, rolling_active_stop);
    VAR_SETGET_DECLARATION(float, rolling_flat_factor);
    VAR_SETGET_DECLARATION(float, rolling_uphill_factor);
    VAR_SETGET_DECLARATION(float, rolling_downhill_factor);

    VAR_SETGET_DECLARATION(float, jump_velocity);
    VAR_SETGET_DECLARATION(float, jump_short_limit);
    VAR_SETGET_DECLARATION(float, jump_spam_timer);

    //public state variables
    VAR_SETGET_DECLARATION(Vector3, space_velocity);
    VAR_SETGET_DEFINITION(float, collision_angle);
    VAR_SETGET_DECLARATION(float, ground_velocity);

    MC_STATE_FLAG_DEF(moving);
    MC_STATE_FLAG_DEF(grounded);
    MC_STATE_FLAG_DEF(rolling);
    MC_STATE_FLAG_DEF(jumping);
    MC_STATE_FLAG_DEF(balancing);
    MC_STATE_FLAG_DEF(crouching);
    MC_STATE_FLAG_DEF(changing_direction);
    MC_STATE_FLAG_DEF(pushing);
    MC_STATE_FLAG_DEF(slipping);
    MC_STATE_FLAG_DEF(in_cutscene);

protected:
    static void _bind_methods();

public:
    float _FORCE_INLINE_ get_abs_ground_velocity() {return Math::absf(ground_velocity);}

    //Flushes and/or translates all values to smoothly switch between 2D and 3D
    void switch_dimension(bool is_3D);


    //"forward_axis" refers to the the relative z axis in 3D and the x axis in 2D
    void enter_air();
    void land_on_ground();

    bool process_air(MoonCastPhysicsPacket& state);
    bool process_ground(MoonCastPhysicsPacket& state);
};


#endif
