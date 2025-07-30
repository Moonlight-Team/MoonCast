#include "mooncast_ability.hpp"

void MoonCastAbility::_bind_methods(){
	ClassDB::bind_method(D_METHOD("get_active"), &MoonCastAbility::get_active);
	ClassDB::bind_method(D_METHOD("set_active", "active"), &MoonCastAbility::set_active);

	ADD_PROPERTY(PropertyInfo(Variant::BOOL, "active"), "set_active", "get_active");
};

bool MoonCastAbility::get_active(){
	return active;
}

void MoonCastAbility::set_active(bool new_active){
	active = new_active;
}
