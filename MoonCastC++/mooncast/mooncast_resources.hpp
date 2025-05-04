#ifndef MOONCAST_RESOURCES_H
#define MOONCAST_RESOURCES_H

#include "mooncast_macros.h"
#include "core/resource.h"
#include "scene/resources/shape_2d.h"
#include "scene/resources/shape.h"

class MoonCastControlTable: public Resource {
    OBJ_TYPE(MoonCastControlTable, Resource);
private:
    VAR_SETGET_DEFINITION(StringName, direction_up);
    VAR_SETGET_DEFINITION(StringName, direction_down);
    VAR_SETGET_DEFINITION(StringName, direction_left);
    VAR_SETGET_DEFINITION(StringName, direction_right);

    VAR_SETGET_DEFINITION(StringName, action_jump);
    VAR_SETGET_DEFINITION(StringName, action_roll);
    VAR_SETGET_DEFINITION(Dictionary, action_custom);

    VAR_SETGET_DEFINITION(StringName, camera_up);
    VAR_SETGET_DEFINITION(StringName, camera_down);
    VAR_SETGET_DEFINITION(StringName, camera_left);
    VAR_SETGET_DEFINITION(StringName, camera_right);

protected:
	static void _bind_methods();
};

class MoonCastAnimation: public Resource {
    OBJ_TYPE(MoonCastAnimation, Resource);
private:
    StringName next_animation;

    float speed = 1.0f;
    float rotation_snap = Math::deg2rad(30.0);

    VAR_SETGET_DEFINITION(bool, override_rotation);
    VAR_SETGET_DEFINITION(bool, axis_lock_x);
    VAR_SETGET_DEFINITION(bool, axis_lock_y);
    VAR_SETGET_DEFINITION(bool, axis_lock_z);
    VAR_SETGET_DEFINITION(bool, rotation_smooth);

    VAR_SETGET_DECLARATION(bool, override_collision);

protected:
	static void _bind_methods();

public:
    void _animation_start();
    void _animation_process();
    void _animation_cease();
    bool _branch_animation();
};

#endif
