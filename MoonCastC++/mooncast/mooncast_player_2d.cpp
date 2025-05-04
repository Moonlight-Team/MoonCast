#include "mooncast_player_2d.hpp"
#include "mooncast_ability.hpp"
#include "core/os/input.h"

void MoonCastPlayer2D::_bind_methods(){
#define LOCAL_BINDING_CLASS MoonCastPlayer2D

	BIND_SETTER_AND_GETTER(rotation_static_collision);
    BIND_SETTER_AND_GETTER(rotation_classic_snap);
    BIND_SETTER_AND_GETTER(rotation_snap_interval);
    BIND_SETTER_AND_GETTER(rotation_adjustment_speed);
    BIND_SETTER_AND_GETTER(visual_rotation);


    //BIND_SETTER_AND_GETTER(sfx_jump_name);
    //BIND_SETTER_AND_GETTER(sfx_roll_name);
    //BIND_SETTER_AND_GETTER(sfx_skid_name);
    //BIND_SETTER_AND_GETTER(sfx_hurt_name);

    BIND_SETTER_AND_GETTER(physics);
    BIND_SETTER_AND_GETTER(controls);

    BIND_SETTER_AND_GETTER(anim_stand);
    BIND_SETTER_AND_GETTER(anim_look_up);
    BIND_SETTER_AND_GETTER(anim_crouch);
    BIND_SETTER_AND_GETTER(anim_roll);
    BIND_SETTER_AND_GETTER(anim_run);
    BIND_SETTER_AND_GETTER(anim_skid);
    BIND_SETTER_AND_GETTER(anim_push);
    BIND_SETTER_AND_GETTER(anim_jump);
    BIND_SETTER_AND_GETTER(anim_free_fall);
    BIND_SETTER_AND_GETTER(anim_death);
    BIND_SETTER_AND_GETTER(anim_death_custom);

    BIND_SETTER_AND_GETTER(sfx_bus);
    BIND_SETTER_AND_GETTER(sfx_jump);
    BIND_SETTER_AND_GETTER(sfx_roll);
    BIND_SETTER_AND_GETTER(sfx_skid);
    BIND_SETTER_AND_GETTER(sfx_hurt);
    BIND_SETTER_AND_GETTER(sfx_custom);

    BIND_SETTER_AND_GETTER(abilities);
    BIND_SETTER_AND_GETTER(ability_data);

    BIND_SETTER_AND_GETTER(current_anim);

	BIND_EDITOR_PROPERTY(BOOL, rotation_static_collision);
    BIND_EDITOR_PROPERTY(BOOL, rotation_classic_snap);
    BIND_EDITOR_PROPERTY(REAL, rotation_snap_interval);
    BIND_EDITOR_PROPERTY(REAL, rotation_adjustment_speed);
    BIND_STORED_PROPERTY(REAL, visual_rotation);

    //BIND_EDITOR_PROPERTY(STRING, sfx_jump_name);
    //BIND_EDITOR_PROPERTY(STRING, sfx_roll_name);
    //BIND_EDITOR_PROPERTY(STRING, sfx_skid_name);
    //BIND_EDITOR_PROPERTY(STRING, sfx_hurt_name);

    BIND_EDITOR_OBJ_PROPERTY(MoonCastPhysicsState, physics);
    BIND_EDITOR_OBJ_PROPERTY(MoonCastControlTable, controls);

    BIND_EDITOR_OBJ_PROPERTY(MoonCastAnimation, anim_stand);
    BIND_EDITOR_OBJ_PROPERTY(MoonCastAnimation, anim_look_up);
    BIND_EDITOR_OBJ_PROPERTY(MoonCastAnimation, anim_crouch);
    BIND_EDITOR_OBJ_PROPERTY(MoonCastAnimation, anim_roll);
    BIND_EDITOR_PROPERTY(DICTIONARY, anim_run);
    BIND_EDITOR_PROPERTY(DICTIONARY, anim_skid);
    BIND_EDITOR_OBJ_PROPERTY(MoonCastAnimation, anim_push);
    BIND_EDITOR_OBJ_PROPERTY(MoonCastAnimation, anim_jump);
    BIND_EDITOR_OBJ_PROPERTY(MoonCastAnimation, anim_free_fall);
    BIND_EDITOR_OBJ_PROPERTY(MoonCastAnimation, anim_death);
    BIND_EDITOR_PROPERTY(DICTIONARY, anim_death_custom);

    BIND_EDITOR_PROPERTY(STRING, sfx_bus);
    BIND_EDITOR_OBJ_PROPERTY(AudioStream, sfx_jump);
    BIND_EDITOR_OBJ_PROPERTY(AudioStream, sfx_roll);
    BIND_EDITOR_OBJ_PROPERTY(AudioStream, sfx_skid);
    BIND_EDITOR_OBJ_PROPERTY(AudioStream, sfx_hurt);
    BIND_EDITOR_PROPERTY(DICTIONARY, sfx_custom);

    BIND_STORED_PROPERTY(ARRAY, abilities);
    BIND_STORED_PROPERTY(DICTIONARY, ability_data);

    BIND_STORED_PROPERTY(OBJECT, current_anim);

#undef LOCAL_BINDING_CLASS
}

#define MOONCAST_SIGNAL(sig_name, ...)\
	if (abilities.size() > 0){\
		for (int i = 0; i < abilities.size(); i++){\
			if (abilities.get(i)){\
				abilities[i]->sig_name(__VA_ARGS__);\
			}\
		}\
	}

void MoonCastPlayer2D::_notification(int p_what){

    switch (p_what){
        case NOTIFICATION_FIXED_PROCESS:
            if (physics.is_valid()){
                physics_process();
            }
            break;
#ifdef TOOLS_ENABLED
        case NOTIFICATION_DRAW:
			//TODO: check if scene tree is in debug
			if (true){
				draw_debug_info();
			}
#endif
            break;
        case NOTIFICATION_READY:
            break;

		case NOTIFICATION_PARENTED:
			detect_children();
			break;
    }
}

void MoonCastPlayer2D::draw_debug_info(){
	//draw hitbox
	//if (current_anim->get_override_collision() and current_anim->get_collision_shape_2d()){
	//}

	//https://info.sonicretro.org/images/4/45/SPGSensors.png
	//order: left, then right; down, up, and wall

	static Color sensor_a = Color::hex(0x00F000FF); //Color(0, 240, 0);
	static Color sensor_b = Color::hex(0x38FFA2FF); //Color(56, 255, 162);
	static Color sensor_c = Color::hex(0x00AEEFFF); //Color(0, 174, 239);
	static Color sensor_d = Color::hex(0xFFF238FF); //Color(255, 242, 56);
	static Color sensor_e = Color::hex(0xFF38FFFF); //Color(255, 56, 255);
	static Color sensor_f = Color::hex(0xFF5454FF); //Color(255, 84, 84);

	//TODO: Make this go off the size of the current collision shape
	static Point2 max_size(20.0f, 20.0f);

	constexpr bool show_all(true);

	Point2 top_left(0.0f, 0.0f);
	Point2 top_right(max_size.x, 0.0f);
	Point2 bottom_left(0.0f, max_size.y);
	Point2 bottom_right(max_size);
	Point2 mid_left(0.0f, max_size.y / 2.0f);
	Point2 mid_right(max_size.x, max_size.y / 2.0f);
	Point2 center(max_size.x / 2.0f, max_size.y / 2.0f);

	float scale = get_global_transform().get_scale().length();



	if (show_all){
		draw_line(mid_left, bottom_left, sensor_a, scale);
		draw_line(mid_right, bottom_right, sensor_b, scale);

		draw_line(mid_left, top_left, sensor_c, scale);
		draw_line(mid_right, top_right, sensor_d, scale);

		draw_line(center, mid_left, sensor_e, scale);
		draw_line(center, mid_right, sensor_f, scale);
	} else {

		if (physics->ground_velocity < 0.0f){ //going left
			if (physics->space_velocity.y < 0.0f){ //going up
				draw_line(mid_left, top_left, sensor_c);
			} else {
				draw_line(mid_left, bottom_left, sensor_a);
			}

			draw_line(center, mid_left, sensor_e);
		} else {
			if (physics->space_velocity.y < 0.0f){ //going up
				draw_line(mid_right, top_right, sensor_d);
			} else {
				draw_line(mid_right, bottom_right, sensor_b);
			}

			draw_line(center, mid_right, sensor_f);
		}


		//draw the specific lines that correspond to the direction the player is traveling
	}



}

void MoonCastPlayer2D::detect_children(){
	if (!get_child_count()){
		return;
	}

	for (int i = 0; i < get_child_count(); i++){
		Node *cur_child = get_child(i);

		if (cur_child->cast_to<MoonCastAbility>()){
			MoonCastAbility *new_ability = cur_child->cast_to<MoonCastAbility>();
			if (!abilities.find(new_ability)){
				abilities.push_back(new_ability);
			}
		}

		else if (!animations and cur_child->cast_to<AnimationPlayer>()){
			animations = cur_child->cast_to<AnimationPlayer>();
		}

		//TODO: When AnimatedSprite2D/SpriteFrames sucks less, add detection for that

		else if (!sprite_2d and cur_child->cast_to<Sprite2D>()){
			sprite_2d = cur_child->cast_to<Sprite2D>();
		}
	}
}

void MoonCastPlayer2D::calculate_ray_points(){

}

void MoonCastPlayer2D::update_animations(){

}

void MoonCastPlayer2D::update_collision_rotation(){

}

void MoonCastPlayer2D::move_and_slide(){
    float delta = get_fixed_process_delta_time();

	Vector2 p_motion;

	bool colliding = false;
	ERR_FAIL_COND(not is_inside_tree());

	Physics2DDirectSpaceState *direct_space = Physics2DServer::get_singleton()->space_get_direct_state(get_world_2d()->get_space());
	ERR_FAIL_COND(not direct_space);
	const int max_shapes = 32;
	Vector2 sr[max_shapes * 2];
	int res_shapes;

	Set<RID> exclude;
	exclude.insert(get_rid());


	//recover first
	int recover_attempts=4;
	float margin = 0.08f;

	bool collided=false;

//	print_line("motion: "+p_motion+" margin: "+rtos(margin));

	//print_line("margin: "+rtos(margin));
	do {
		//motion recover
		for(int i = 0; i < get_shape_count(); i++) {

			if (direct_space->collide_shape(get_shape(i)->get_rid(), get_global_transform() * get_shape_transform(i), Vector2(), margin, sr, max_shapes, res_shapes, exclude, get_layer_mask())){
				collided=true;
			}
		}

		if (not collided) {break;}

		Vector2 recover_motion;

		for(int i = 0; i < res_shapes; i++) {

			Vector2 a = sr[i * 2 + 0];
			Vector2 b = sr[i * 2 + 1];

			recover_motion += (b - a) * 0.2;
		}

		if (recover_motion == Vector2()) {
			collided = false;
			break;
		}

		Transform2D gt = get_global_transform();
		gt.elements[2] += recover_motion;
		set_global_transform(gt);

		recover_attempts--;

	} while (recover_attempts);


	//move second
	float safe = 1.0;
	float unsafe = 1.0;
	int best_shape = -1;

	for(int i = 0; i < get_shape_count(); i++) {
		float lsafe,lunsafe;
		bool valid = direct_space->cast_motion(get_shape(i)->get_rid(), get_global_transform() * get_shape_transform(i), p_motion, 0,lsafe,lunsafe,exclude,get_layer_mask());

		if (not valid) {
			safe = 0;
			unsafe = 0;
			best_shape = i; //sadly it's the best
			break;
		}

		if (lsafe == 1.0) { continue;}

		if (lsafe < safe) {
			safe = lsafe;
			unsafe = lunsafe;
			best_shape = i;
		}
	}


	//print_line("best shape: "+itos(best_shape)+" motion "+p_motion);

	if (safe <= 1) {

		//it collided, let's get the rest info in unsafe advance
		Transform2D ugt = get_global_transform();
		ugt.elements[2] += p_motion * unsafe;

		Physics2DDirectSpaceState::ShapeRestInfo rest_info;

		bool c2 = direct_space->rest_info(get_shape(best_shape)->get_rid(), ugt * get_shape_transform(best_shape), Vector2(), margin, &rest_info, exclude, get_layer_mask());

		if (c2) {
			//should not happen, but floating point precision is so weird..
			colliding=false;
		} else {

			colliding=true;
			//collision=rest_info.point;
			physics->set_collision_angle(rest_info.normal.angle_to(Vector2(0, -1)));

			//collider=rest_info.collider_id;
			//collider_vel=rest_info.linear_velocity;
			//collider_shape=rest_info.shape;
			//collider_metadata=rest_info.metadata;
		}

	}

	Vector2 motion = p_motion * safe;

	Transform2D gt = get_global_transform(); gt.elements[2] += motion; set_global_transform(gt);

	//return p_motion-motion;
}

void MoonCastPlayer2D::physics_process(){

	animation_set = false;
	MOONCAST_SIGNAL(_pre_physics, physics.ptr());
	MOONCAST_SIGNAL(_pre_physics_2D, this);

	//set input to 0

	if (physics->get_can_be_moving() and controls.is_valid()){
		float left_strength = controls->get_direction_left() and Input::get_singleton()->is_action_pressed(controls->get_direction_left()) ? -1.0f : 0.0f;
		float right_strength = controls->get_direction_right() and Input::get_singleton()->is_action_pressed(controls->get_direction_right()) ? 1.0f : 0.0f;

		state.input_direction = Vector2((left_strength + right_strength) / 2.0f, 0.0f);
	}


	bool skip_builtin_states = false;

	if (state_abilities.size() > 0){
		for (int i = 0; i < state_abilities.size(); i++){
			if (state_abilities.get(i) != nullptr){
				if (state_abilities[i]->_custom_state_2D(this)){
					skip_builtin_states = true;
					break;
				}
			}
		}
	}

	if (not skip_builtin_states){
		if (physics->get_is_grounded()){
			bool still_grounded = physics->process_ground(state);

			if (still_grounded){
				emit_signal("ground_state", physics);
				emit_signal("ground_state_2d", this);
			}
		} else {
			bool still_in_air = physics->process_air(state);

			if (still_in_air){
				emit_signal("air_state", physics);
				emit_signal("air_state_2d", this);
			}
		}
	}

	emit_signal("post_physics", physics);
	emit_signal("post_physics_2d", this);

	move_and_slide();

	update_animations();

	update_collision_rotation();
}

MoonCastPlayer2D::MoonCastPlayer2D(): PhysicsBody2D(Physics2DServer::BODY_MODE_KINEMATIC){

}
