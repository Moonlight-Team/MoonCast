#ifndef MOONCAST_MACROS_H
#define MOONCAST_MACROS_H

//got tired of writing all this out, so templating code we go

#include "core/types/ustring.h"

#define VAR_SETGET_DEFINITION(var_type, variable)\
private:\
    var_type variable;\
public:\
    var_type get_##variable(){return variable;};\
    void set_##variable(var_type new_value){variable = new_value;};

#define VAR_SETGET_DECLARATION(var_type, variable)\
private:\
    var_type variable;\
public:\
    var_type get_##variable(); void set_##variable(var_type new_value);


#define dec_setgets(var_type, variable)\
public:\
    var_type get_##variable();\
    void set_##variable(var_type new_value);

//define LOCAL_BINDING_CLASS in the file before this macro, see other code for examples
#define BIND_SETTER_AND_GETTER(var_name)\
    ObjectTypeDB::bind_method(_MD("get_" #var_name), &LOCAL_BINDING_CLASS::get_##var_name);\
    ObjectTypeDB::bind_method(_MD("set_" #var_name, #var_name), &LOCAL_BINDING_CLASS::set_##var_name);

#define BIND_EDITOR_PROPERTY(var_type, var_name) ObjectTypeDB::add_property(get_type_static(), PropertyInfo(Variant::var_type, #var_name), "set_" #var_name, "get_" #var_name)

#define BIND_EDITOR_OBJ_PROPERTY(var_type, var_name) ObjectTypeDB::add_property(get_type_static(), PropertyInfo(Variant::OBJECT, #var_name, PROPERTY_HINT_RESOURCE_TYPE, #var_type), "set_" #var_name, "get_" #var_name)

#define BIND_STORED_PROPERTY(var_type, var_name) ObjectTypeDB::add_property(get_type_static(), PropertyInfo(Variant::var_type, #var_name, PROPERTY_HINT_NONE, "", PROPERTY_USAGE_NOEDITOR), "set_" #var_name, "get_" #var_name)


#define MC_STATE_FLAG_DEF(name)\
    bool get_is_##name();\
    void set_is_##name(bool new_##name);\
    bool get_can_be_##name();\
    void set_can_be_##name(bool new_##name);

#define MC_CORE_SETGET_DEF(name)\
    bool get_is_##name(){return core->get_is_##name();};\
    void set_is_##name(bool new_##name){\
		core->set_is_##name(new_##name);\
	};\
    bool get_can_be_##name(){return core->get_can_be_##name();};\
    void set_can_be_##name(bool new_##name){\
		core->set_can_be_##name(new_##name);\
	};

#endif
