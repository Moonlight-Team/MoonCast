#include "mooncast_resources.hpp"

StringName MoonCastControlTable::get_direction_up(){
	return direction_up;
}

void MoonCastControlTable::set_direction_up(StringName new_direction_up){
	direction_up = new_direction_up;
}

StringName MoonCastControlTable::get_direction_down(){
	return direction_down;
}

void MoonCastControlTable::set_direction_down(StringName new_direction_down){
	direction_down = new_direction_down;
}

StringName MoonCastControlTable::get_direction_left(){
	return direction_left;
}

void MoonCastControlTable::set_direction_left(StringName new_direction_left){
	direction_left = new_direction_left;
}

StringName MoonCastControlTable::get_direction_right(){
	return direction_right;
}

void MoonCastControlTable::set_direction_right(StringName new_direction_right){
	direction_right = new_direction_right;
}

StringName MoonCastControlTable::get_action_roll(){
	return action_roll;
}

void MoonCastControlTable::set_action_roll(StringName new_action_roll){
	action_roll = new_action_roll;
}

StringName MoonCastControlTable::get_action_jump(){
	return action_jump;
}

void MoonCastControlTable::set_action_jump(StringName new_action_jump){
	action_jump = new_action_jump;
}

Dictionary MoonCastControlTable::get_action_custom(){
	return action_custom;
}

void MoonCastControlTable::set_action_custom(Dictionary new_action_custom){
	action_custom = new_action_custom;
}

StringName MoonCastControlTable::get_camera_up(){
	return camera_up;
}

void MoonCastControlTable::set_camera_up(StringName new_camera_up){
	camera_up = new_camera_up;
}

StringName MoonCastControlTable::get_camera_down(){
	return camera_down;
}

void MoonCastControlTable::set_camera_down(StringName new_camera_down){
	camera_down = new_camera_down;
}

StringName MoonCastControlTable::get_camera_left(){
	return camera_left;
}

void MoonCastControlTable::set_camera_left(StringName new_camera_left){
	camera_left = new_camera_left;
}

StringName MoonCastControlTable::get_camera_right(){
	return camera_right;
}

void MoonCastControlTable::set_camera_right(StringName new_camera_right){
	camera_right = new_camera_right;
}



void MoonCastControlTable::_bind_methods(){
	ClassDB::bind_method(D_METHOD("get_direction_up"), &MoonCastControlTable::get_direction_up);
	ClassDB::bind_method(D_METHOD("set_direction_up", "direction_up"), &MoonCastControlTable::set_direction_up);
	ClassDB::bind_method(D_METHOD("get_direction_down"), &MoonCastControlTable::get_direction_down);
	ClassDB::bind_method(D_METHOD("set_direction_down", "direction_down"), &MoonCastControlTable::set_direction_down);
	ClassDB::bind_method(D_METHOD("get_direction_left"), &MoonCastControlTable::get_direction_left);
	ClassDB::bind_method(D_METHOD("set_direction_left", "direction_left"), &MoonCastControlTable::set_direction_left);
	ClassDB::bind_method(D_METHOD("get_direction_right"), &MoonCastControlTable::get_direction_right);
	ClassDB::bind_method(D_METHOD("set_direction_right", "direction_right"), &MoonCastControlTable::set_direction_right);

	ClassDB::bind_method(D_METHOD("get_action_roll"), &MoonCastControlTable::get_action_roll);
	ClassDB::bind_method(D_METHOD("set_action_roll", "action_roll"), &MoonCastControlTable::set_action_roll);
	ClassDB::bind_method(D_METHOD("get_action_jump"), &MoonCastControlTable::get_action_jump);
	ClassDB::bind_method(D_METHOD("set_action_jump", "action_jump"), &MoonCastControlTable::set_action_jump);
		ClassDB::bind_method(D_METHOD("get_action_custom"), &MoonCastControlTable::get_action_custom);
	ClassDB::bind_method(D_METHOD("set_action_custom", "action_custom"), &MoonCastControlTable::set_action_custom);

	ClassDB::bind_method(D_METHOD("get_camera_up"), &MoonCastControlTable::get_camera_up);
	ClassDB::bind_method(D_METHOD("set_camera_up", "camera_up"), &MoonCastControlTable::set_camera_up);
	ClassDB::bind_method(D_METHOD("get_camera_down"), &MoonCastControlTable::get_camera_down);
	ClassDB::bind_method(D_METHOD("set_camera_down", "camera_down"), &MoonCastControlTable::set_camera_down);
	ClassDB::bind_method(D_METHOD("get_camera_left"), &MoonCastControlTable::get_camera_left);
	ClassDB::bind_method(D_METHOD("set_camera_left", "camera_left"), &MoonCastControlTable::set_camera_left);
	ClassDB::bind_method(D_METHOD("get_camera_right"), &MoonCastControlTable::get_camera_right);
	ClassDB::bind_method(D_METHOD("set_camera_right", "camera_right"), &MoonCastControlTable::set_camera_right);

	ADD_PROPERTY(PropertyInfo(Variant::STRING_NAME, "direction_up"), "set_direction_up", "get_direction_up");
	ADD_PROPERTY(PropertyInfo(Variant::STRING_NAME, "direction_down"), "set_direction_down", "get_direction_down");
	ADD_PROPERTY(PropertyInfo(Variant::STRING_NAME, "direction_left"), "set_direction_left", "get_direction_left");
	ADD_PROPERTY(PropertyInfo(Variant::STRING_NAME, "direction_right"), "set_direction_right", "get_direction_right");

	ADD_PROPERTY(PropertyInfo(Variant::STRING_NAME, "action_jump"), "set_action_jump", "get_action_jump");
	ADD_PROPERTY(PropertyInfo(Variant::STRING_NAME, "action_roll"), "set_action_roll", "get_action_roll");
	ADD_PROPERTY(PropertyInfo(Variant::DICTIONARY, "action_custom"), "set_action_custom", "get_action_custom");

	ADD_PROPERTY(PropertyInfo(Variant::STRING_NAME, "camera_up"), "set_camera_up", "get_camera_up");
	ADD_PROPERTY(PropertyInfo(Variant::STRING_NAME, "camera_down"), "set_camera_down", "get_camera_down");
	ADD_PROPERTY(PropertyInfo(Variant::STRING_NAME, "camera_left"), "set_camera_left", "get_camera_left");
	ADD_PROPERTY(PropertyInfo(Variant::STRING_NAME, "camera_right"), "set_camera_right", "get_camera_right");
}

StringName MoonCastAnimation::get_animation(){
	return animation;
}

void MoonCastAnimation::set_animation(StringName new_animation){
	animation = new_animation;
}

bool MoonCastAnimation::get_can_turn_vertical(){
	return can_turn_vertical;
}

void MoonCastAnimation::set_can_turn_vertical(bool new_can_turn_vertical){
	can_turn_vertical = new_can_turn_vertical;
}

bool MoonCastAnimation::get_can_turn_horizontal(){
	return can_turn_horizontal;
}

void MoonCastAnimation::set_can_turn_horizontal(bool new_can_turn_horizontal){
	can_turn_horizontal = new_can_turn_horizontal;
}

bool MoonCastAnimation::get_override_rotation(){
	return override_rotation;
}

void MoonCastAnimation::set_override_rotation(bool new_override_rotation){
	override_rotation = new_override_rotation;
}

bool MoonCastAnimation::get_override_collision(){
	return override_collision;
}

void MoonCastAnimation::set_override_collision(bool new_override_collision){
	override_collision = new_override_collision;
}

float MoonCastAnimation::get_rotation_snap(){
	return rotation_snap;
}

void MoonCastAnimation::set_rotation_snap(float new_rotation_snap){
	rotation_snap = new_rotation_snap;
}

bool MoonCastAnimation::get_rotation_smooth(){
	return rotation_smooth;
}

void MoonCastAnimation::set_rotation_smooth(bool new_rotation_smooth){
	rotation_smooth = new_rotation_smooth;
}

StringName MoonCastAnimation::get_next_animation(){
	return next_animation;
}

void MoonCastAnimation::set_next_animation(StringName new_next_animation){
	next_animation = new_next_animation;
}

float MoonCastAnimation::get_speed(){
	return speed;
}

void MoonCastAnimation::set_speed(float new_speed){
	speed = new_speed;
}

void MoonCastAnimation::_bind_methods(){
	ClassDB::bind_method(D_METHOD("get_animation"), &MoonCastAnimation::get_animation);
	ClassDB::bind_method(D_METHOD("set_animation", "animation"), &MoonCastAnimation::set_animation);

	ClassDB::bind_method(D_METHOD("get_speed"), &MoonCastAnimation::get_speed);
	ClassDB::bind_method(D_METHOD("set_speed", "speed"), &MoonCastAnimation::set_speed);

	ClassDB::bind_method(D_METHOD("get_can_turn_vertical"), &MoonCastAnimation::get_can_turn_vertical);
	ClassDB::bind_method(D_METHOD("set_can_turn_vertical", "can_turn_vertical"), &MoonCastAnimation::set_can_turn_vertical);
	ClassDB::bind_method(D_METHOD("get_can_turn_horizontal"), &MoonCastAnimation::get_can_turn_horizontal);
	ClassDB::bind_method(D_METHOD("set_can_turn_horizontal", "can_turn_horizontal"), &MoonCastAnimation::set_can_turn_horizontal);

	ClassDB::bind_method(D_METHOD("get_override_rotation"), &MoonCastAnimation::get_override_rotation);
	ClassDB::bind_method(D_METHOD("set_override_rotation", "override_rotation"), &MoonCastAnimation::set_override_rotation);
	ClassDB::bind_method(D_METHOD("get_override_collision"), &MoonCastAnimation::get_override_collision);
	ClassDB::bind_method(D_METHOD("set_override_collision", "override_collision"), &MoonCastAnimation::set_override_collision);

	ClassDB::bind_method(D_METHOD("get_rotation_snap"), &MoonCastAnimation::get_rotation_snap);
	ClassDB::bind_method(D_METHOD("set_rotation_snap", "rotation_snap"), &MoonCastAnimation::set_rotation_snap);
	ClassDB::bind_method(D_METHOD("get_rotation_smooth"), &MoonCastAnimation::get_rotation_smooth);
	ClassDB::bind_method(D_METHOD("set_rotation_smooth", "rotation_smooth"), &MoonCastAnimation::set_rotation_smooth);


	ClassDB::bind_method(D_METHOD("get_next_animation"), &MoonCastAnimation::get_next_animation);
	ClassDB::bind_method(D_METHOD("set_next_animation", "next_animation"), &MoonCastAnimation::set_next_animation);


	ADD_PROPERTY(PropertyInfo(Variant::STRING_NAME, "animation"), "set_animation", "get_animation");
	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "speed"), "set_speed", "get_speed");

	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "can_turn_vertical"), "set_can_turn_vertical", "get_can_turn_vertical");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "can_turn_horizontal"), "set_can_turn_horizontal", "get_can_turn_horizontal");

	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "override_rotation"), "set_override_rotation", "get_override_rotation");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "override_collision"), "set_override_collision", "get_override_collision");

	ADD_PROPERTY(PropertyInfo(Variant::FLOAT, "rotation_snap"), "set_rotation_snap", "get_rotation_snap");
	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "rotation_smooth"), "set_rotation_smooth", "get_rotation_smooth");


	//non-editor scripting variables
	ADD_PROPERTY(PropertyInfo(Variant::STRING_NAME, "next_animation"), "set_next_animation", "get_next_animation");

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
