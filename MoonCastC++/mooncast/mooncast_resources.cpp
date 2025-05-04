#include "mooncast_resources.hpp"

void MoonCastControlTable::_bind_methods(){
#define LOCAL_BINDING_CLASS MoonCastControlTable

    BIND_SETTER_AND_GETTER(direction_up);
    BIND_SETTER_AND_GETTER(direction_down);
    BIND_SETTER_AND_GETTER(direction_left);
    BIND_SETTER_AND_GETTER(direction_right);

    BIND_SETTER_AND_GETTER(action_jump);
    BIND_SETTER_AND_GETTER(action_roll);
    BIND_SETTER_AND_GETTER(action_custom);

    BIND_SETTER_AND_GETTER(camera_up);
    BIND_SETTER_AND_GETTER(camera_down);
    BIND_SETTER_AND_GETTER(camera_left);
    BIND_SETTER_AND_GETTER(camera_right);

    BIND_EDITOR_PROPERTY(STRING, direction_up);
    BIND_EDITOR_PROPERTY(STRING, direction_down);
    BIND_EDITOR_PROPERTY(STRING, direction_left);
    BIND_EDITOR_PROPERTY(STRING, direction_right);

    BIND_EDITOR_PROPERTY(STRING, action_jump);
    BIND_EDITOR_PROPERTY(STRING, action_roll);
    BIND_EDITOR_PROPERTY(DICTIONARY, action_custom);

    BIND_EDITOR_PROPERTY(STRING, camera_up);
    BIND_EDITOR_PROPERTY(STRING, camera_down);
    BIND_EDITOR_PROPERTY(STRING, camera_left);
    BIND_EDITOR_PROPERTY(STRING, camera_right);

#undef LOCAL_BINDING_CLASS
}

void MoonCastAnimation::_bind_methods(){
#define LOCAL_BINDING_CLASS MoonCastAnimation

    BIND_SETTER_AND_GETTER(override_rotation);
    BIND_SETTER_AND_GETTER(axis_lock_x);
    BIND_SETTER_AND_GETTER(axis_lock_y);
    BIND_SETTER_AND_GETTER(axis_lock_z);
    BIND_SETTER_AND_GETTER(rotation_smooth);

    BIND_SETTER_AND_GETTER(override_collision);

    BIND_EDITOR_PROPERTY(BOOL, override_rotation);
    BIND_EDITOR_PROPERTY(BOOL, axis_lock_x);
    BIND_EDITOR_PROPERTY(BOOL, axis_lock_y);
    BIND_EDITOR_PROPERTY(BOOL, axis_lock_z);
    BIND_EDITOR_PROPERTY(BOOL, rotation_smooth);

    BIND_EDITOR_PROPERTY(BOOL, override_collision);


#undef LOCAL_BINDING_CLASS
}

void MoonCastAnimation::set_override_collision(bool p_new_override_collision){
    override_collision = p_new_override_collision;
}

bool MoonCastAnimation::get_override_collision(){
    return override_collision;
}

void MoonCastAnimation::_animation_start(){

}

void MoonCastAnimation::_animation_process(){

}

void MoonCastAnimation::_animation_cease(){

}

bool MoonCastAnimation::_branch_animation(){
    return false;
}
