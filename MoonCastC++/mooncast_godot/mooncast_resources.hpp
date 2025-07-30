#ifndef MOONCAST_RESOURCES_H
#define MOONCAST_RESOURCES_H

#include "core/io/resource.h"

class MoonCastControlTable: public Resource {
    GDCLASS(MoonCastControlTable, Resource);

private:
	StringName direction_up;
	StringName direction_down;
	StringName direction_left;
	StringName direction_right;

	StringName action_roll;
	StringName action_jump;
	Dictionary action_custom;

	StringName camera_up;
	StringName camera_down;
	StringName camera_left;
	StringName camera_right;


public:
	StringName get_direction_up();
	void set_direction_up(StringName new_direction_up);
	StringName get_direction_down();
	void set_direction_down(StringName new_direction_down);
	StringName get_direction_left();
	void set_direction_left(StringName new_direction_left);
	StringName get_direction_right();
	void set_direction_right(StringName new_direction_right);


	StringName get_action_roll();
	void set_action_roll(StringName new_action_roll);
	StringName get_action_jump();
	void set_action_jump(StringName new_action_jump);
	Dictionary get_action_custom();
	void set_action_custom(Dictionary new_action_custom);

	StringName get_camera_up();
	void set_camera_up(StringName new_camera_up);
	StringName get_camera_down();
	void set_camera_down(StringName new_camera_down);
	StringName get_camera_left();
	void set_camera_left(StringName new_camera_left);
	StringName get_camera_right();
	void set_camera_right(StringName new_camera_right);

protected:
	static void _bind_methods();
};

class MoonCastAnimation: public Resource {
    GDCLASS(MoonCastAnimation, Resource);
private:
	StringName animation;
	StringName next_animation;

	bool can_turn_vertical;
	bool can_turn_horizontal;
	bool override_rotation;
	bool override_collision;
	bool rotation_smooth;

	float speed = 1.0f;
    float rotation_snap = Math::deg_to_rad(30.0);

	StringName get_animation();
	void set_animation(StringName new_animation);
	StringName get_next_animation();
	void set_next_animation(StringName new_next_animation);
	float get_speed();
	void set_speed(float new_speed);

	bool get_can_turn_vertical();
	void set_can_turn_vertical(bool new_can_turn_vertical);
	bool get_can_turn_horizontal();
	void set_can_turn_horizontal(bool new_can_turn_horizontal);

	bool get_override_rotation();
	void set_override_rotation(bool new_override_rotation);
	bool get_override_collision();
	void set_override_collision(bool new_override_collision);

	float get_rotation_snap();
	void set_rotation_snap(float new_rotation_snap);
	bool get_rotation_smooth();
	void set_rotation_smooth(bool new_rotation_smooth);

protected:
	static void _bind_methods();

public:
    void _animation_start();
    void _animation_process();
    void _animation_cease();
    bool _branch_animation();
};

#endif
