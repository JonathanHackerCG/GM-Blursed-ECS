#region Cursed Macros - DEFINE
#macro _ECS_DEFINE if (!variable_global_exists("__ECS_definitions"))\
							{ global.__ECS_definitions = ds_priority_create(); }\
							ds_priority_add(global.__ECS_definitions, 
//Feather ignore GM1051
#macro _ECS_END_DEFINE );
#endregion
#region Cursed Macros - COMPONENT
#macro COMPONENT_NAME _ECS_DEFINE function() {\
	var _component = new Component();\
	COMPONENT.
#macro COMPONENT_START = _component;\
	with (_component) {
#macro COMPONENT_END } }, 0, _ECS_END_DEFINE
#endregion
#region Component(); constructor
function Component() constructor
{
	INIT = undefined;
	STEP = undefined;
	DRAW = undefined;
}
#endregion

#region ECS_initialize();
/// @func ECS_initialize():
/// @desc Called once at start of the game to initialize the ECS.
function ECS_initialize()
{
	//Creating the COMPONENT "namespace".
	if (!instance_exists(COMPONENT))
	{
		instance_create_depth(0, 0, 0, COMPONENT);
	}
	
	//Defining components.
	do
	{
		ds_priority_delete_max(global.__ECS_definitions)();
	} until (ds_priority_empty(global.__ECS_definitions));
	ds_priority_destroy(global.__ECS_definitions);
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