#ifndef MOONCAST_ABILITY_H
#define MOONCAST_ABILITY_H

#include "mc_physics.hpp"

class MoonCastPlayer2D;
class MoonCastPlayer3D;

class MoonCastAbility : public Node {
	GDCLASS(MoonCastAbility, Node);

	bool active;

private:

	void set_active(bool p_active);
	bool get_active();

protected:
	static void _bind_methods();

public:
	void _pre_physics(MoonCastPhysicsTable *p_state);
	void _pre_physics_2D(MoonCastPlayer2D *p_player);
	void _pre_physics_3D(MoonCastPlayer3D *p_player);

	void _post_physics(MoonCastPhysicsTable *p_state);
	void _post_physics_2D(MoonCastPlayer2D *p_player);
	void _post_physics_3D(MoonCastPlayer3D *p_player);

	void _hurt();
	void _jump();

	bool _custom_state(MoonCastPhysicsTable *p_state);
	bool _custom_state_2D(MoonCastPlayer2D *p_player);
	bool _custom_state_3D(MoonCastPlayer2D *p_player);

	void _air_contact();
	void _air_process();

	void _ground_contact();
	void _ground_process();

	void _wall_contact();

	void _setup_custom_state();
	void _custom_state_process();
};

#endif
