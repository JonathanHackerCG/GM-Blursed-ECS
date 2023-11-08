#region Cursed Macros - DEFINE
#macro ECS_DEFINE if (!variable_global_exists("__ECS_definitions"))\
							{ global.__ECS_definitions = ds_priority_create(); }\
							ds_priority_add(global.__ECS_definitions, function() {
//Feather ignore GM1051
#macro ECS_DEFINE_END }, 0 );
#endregion

#macro COMPONENT global.__ECS_components
#region Component(name); constructor
/// @func Component(name):
/// @desc Constructor that creates a new Component.
/// @arg	{String} name
/// @returns {Struct.Component}
function Component(_name, _INIT = undefined, _STEP = undefined, _DRAW = undefined) constructor
{
	static _ids = 0;
	#region get_id();
	_id = ++_ids;
	/// @func get_id();
	/// @desc Returns the ID of the Component.
	/// @returns {Real}
	static get_id = function()
	{
		return _id;
	}
	#endregion
	
	INIT = _INIT;
	STEP = _STEP;
	DRAW = _DRAW;
	
	#region Error checking.
	if (!variable_global_exists("__ECS_components"))
	{
		show_error("Blursed ECS - Potentially attempting to define a Component before calling ECS_initialize().\nPlease guarantee a safe definition call, or use ECS_DEFINE and ECS_DEFINE_END.", true);
		exit;
	}
	if (variable_struct_exists(COMPONENT, _name))
	{
		show_error("Blursed ECS - A component already exists with the name '" + _name + "'.", false);
		exit;
	}
	#endregion
	
	//Registering the new Component.
	variable_struct_set(COMPONENT, _name, self);
}
#endregion
#region define_component(name);
/// @func define_component(name):
/// @desc Define a new Component.
/// @arg	{String} name
/// @arg	{Function} INIT
/// @arg	{Function} STEP
/// @arg	{Function} DRAW
/// @returns {Struct.Component}
function define_component(_name, _INIT = undefined, _STEP = undefined, _DRAW = undefined)
{
	return new Component(_name, _INIT, _STEP, _DRAW);
}
#endregion

#region ECS_initialize();
/// @func ECS_initialize():
/// @desc Called once at start of the game to initialize the ECS.
function ECS_initialize()
{
	if (!variable_global_exists("__ECS_components"))
	{
		COMPONENT = {};
	}
	
	//Defining components.
	if (variable_global_exists("__ECS_definitions"))
	{
		do
		{
			ds_priority_delete_max(global.__ECS_definitions)();
		} until (ds_priority_empty(global.__ECS_definitions));
		ds_priority_destroy(global.__ECS_definitions);
	}
}
#endregion

#region ECS_init_entity();
/// @func ECS_init_entity():
/// @desc Called once by an entity to provide required ECS variables.
/// Also called automatically by component_add if necessary.
function ECS_init_entity()
{
	_ECS_initialized = true;
	_ECS_step = []; _ECS_step_num = 0;
	_ECS_draw = []; _ECS_draw_num = 0;
}
#endregion
#region ECS_step();
/// @func ECS_step():
/// @desc Calls the STEP component functions. Should be called in an update event like Step.
function ECS_step()
{
	if (_ECS_step_num > 0)
	{
		for (var i = 0; i < _ECS_step_num; i++)
		{
			_ECS_step[i]();
		}
	}
}
#endregion
#region ECS_draw();
/// @func ECS_draw():
/// @desc Calls the DRAW component functions. Should be called in a draw event like Draw.
function ECS_draw()
{
	if (_ECS_draw_num > 0)
	{
		for (var i = 0; i < _ECS_draw_num; i++)
		{
			_ECS_draw[i]();
		}
	}
}
#endregion

#region component_add(component);
/// @func component_add(component):
/// @desc Adds a component to an entity.
/// @arg	{Function} component Use syntax "COMPONENT.name".
function component_add(_component)
{
	if (!variable_instance_exists(id, "_ECS_initialized"))
	{
		ECS_init_entity();
	}
	if (is_callable(_component.INIT))
	{
		method(id, _component.INIT)();
	}
	if (is_callable(_component.STEP))
	{
		array_push(_ECS_step, method(id, _component.STEP));
		_ECS_step_num++;
	}
	if (is_callable(_component.DRAW))
	{
		array_push(_ECS_draw, method(id, _component.DRAW));
		_ECS_draw_num++;
	}
}
#endregion