#include "mooncast_ability.hpp"

void MoonCastAbility::_bind_methods(){
#define LOCAL_BINDING_CLASS MoonCastAbility

    BIND_SETTER_AND_GETTER(active);

    BIND_EDITOR_PROPERTY(BOOL, active);

#undef LOCAL_BINDING_CLASS
};
