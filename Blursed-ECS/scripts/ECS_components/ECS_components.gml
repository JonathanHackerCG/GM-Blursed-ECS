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
/// @arg	{Function} INIT
/// @arg	{Function} STEP
/// @arg	{Function} DRAW
/// @arg	{Function} CLEAN
/// @returns {Struct.Component}
function Component(_name, _INIT = undefined, _STEP = undefined, _DRAW = undefined, _CLEAN = undefined) constructor
{
	#region Error Checking
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
	
	#region get_id();
	static _ids = 0;
	_id = _ids++;
	/// @func get_id():
	/// @desc Returns the ID of the Component.
	/// @returns {Real}
	static get_id = function()
	{
		return _id;
	}
	#endregion
	#region get_name();
	self._name = _name;
	/// @func get_name():
	/// @desc Returns the name of the Component.
	/// @returns {String}
	static get_name = function()
	{
		return _name;
	}
	#endregion
	#region Events
	INIT  = _INIT;
	STEP  = _STEP;
	DRAW  = _DRAW;
	CLEAN = _CLEAN;
	#endregion
	
	//Registering the new Component.
	variable_struct_set(COMPONENT, _name, self);
	array_push(COMPONENT.LIST, self);
}
#endregion
#region define_component(name);
/// @func define_component(name):
/// @desc Define a new Component.
/// @arg	{String} name
/// @arg	{Function} INIT	 Called when component is added.
/// @arg	{Function} STEP  Called in Step event.
/// @arg	{Function} DRAW  Called in Draw event.
/// @arg	{Function} CLEAN Called in Clean Up event, or when component is removed.
/// @returns {Struct.Component}
function define_component(_name, _INIT = undefined, _STEP = undefined, _DRAW = undefined, _CLEAN = undefined)
{
	return new Component(_name, _INIT, _STEP, _DRAW, _CLEAN);
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
		COMPONENT.LIST = [];
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
	static _init_event_variables = function(_name)
	{
		variable_instance_set(id, "_ECS_" + _name + "_main", []);
		variable_instance_set(id, "_ECS_" + _name + "_copy", []);
		variable_instance_set(id, "_ECS_" + _name + "_init", false);
		variable_instance_set(id, "_ECS_" + _name + "_num", 0);
	}
	_ECS_initialized = true;
	_ECS_components = [];
	method(id, _init_event_variables)("step");
	method(id, _init_event_variables)("draw");
	method(id, _init_event_variables)("clean");
}
#endregion
#region ECS_step();
/// @func ECS_step():
/// @desc Calls the STEP component functions. Should be called in an update event like Step.
function ECS_step()
{
	var _size = _ECS_step_num;
	if (_ECS_step_init)
	{
		array_copy(_ECS_step_copy, 0, _ECS_step_main, 0, _size);
		_ECS_step_init = false;
	}
	
	if (_size > 0)
	{
		for (var i = 0; i < _size; i++)
		{
			_ECS_step_copy[i]._method();
		}
	}
}
#endregion
#region ECS_draw();
/// @func ECS_draw():
/// @desc Calls the DRAW component functions. Should be called in a draw event like Draw.
function ECS_draw()
{
	var _size = _ECS_draw_num;
	if (_ECS_draw_init)
	{
		array_copy(_ECS_draw_copy, 0, _ECS_draw_main, 0, _size);
		_ECS_draw_init = false;
	}
	
	if (_size > 0)
	{
		for (var i = 0; i < _size; i++)
		{
			_ECS_draw_copy[i]._method();
		}
	}
}
#endregion
#region ECS_clean();
/// @func ECS_clean():
/// @desc Calls the CLEAN component functions. Should be called in the Clean Up event.
function ECS_clean()
{
	var _size = _ECS_clean_num;
	if (_ECS_clean_init)
	{
		array_copy(_ECS_clean_copy, 0, _ECS_clean_main, 0, _size);
		_ECS_clean_init = false;
	}
	
	if (_size > 0)
	{
		for (var i = 0; i < _size; i++)
		{
			_ECS_clean_copy[i]._method();
		}
	}
}
#endregion

#region component_add(component);
/// @func component_add(component):
/// @desc Attaches a Component to an Entity.
/// @arg	{Struct.Component} component Syntax: COMPONENT.<name>
function component_add(_component)
{
	if (!variable_instance_exists(id, "_ECS_initialized"))
	{
		ECS_init_entity();
	}
	if (component_attached(_component)) { exit; }
	var _component_id = _component.get_id();
	
	if (is_callable(_component.INIT))
	{
		method(id, _component.INIT)();
	}
	if (is_callable(_component.STEP))
	{
		array_push(_ECS_step_main, {
			_id : _component_id,
			_method : method(id, _component.STEP)
		});
		_ECS_step_num++; _ECS_step_init = true;
	}
	if (is_callable(_component.DRAW))
	{
		array_push(_ECS_draw_main, {
			_id : _component_id,
			_method : method(id, _component.DRAW)
		});
		_ECS_draw_num++; _ECS_draw_init = true;
	}
	if (is_callable(_component.CLEAN))
	{
		array_push(_ECS_clean_main, {
			_id : _component_id,
			_method : method(id, _component.CLEAN)
		});
		_ECS_clean_num++; _ECS_clean_init = true;
	}
	array_push(_ECS_components, _component.get_id());
}
#endregion
#region component_attached(component);
/// @func component_attached(component):
/// @desc Returns true/false if an Entity has a Component.
/// @arg	{Struct.Component} component Syntax: COMPONENT.<name>
function component_attached(_component)
{
	return array_contains(_ECS_components, _component.get_id());
}
#endregion
#region component_remove(component);
/// @func component_remove(component):
/// @desc Removes a Component from an Entity.
/// @arg	{Struct.Component} component Syntax: COMPONENT.<name>
function component_remove(_component)
{
	if (!component_attached(_component)) { exit; }
	
	var _index = -1;
	var _component_id = _component.get_id();
	if (is_callable(_component.STEP))
	{
		for (var i = 0; i < _ECS_step_num; i++)
		{
			if (_ECS_step_main[i]._id == _component_id)
			{
				array_delete(_ECS_step_main, i, 1);
				_ECS_step_num--; _ECS_step_init = true;
				break;
			}
		}
	}
	if (is_callable(_component.DRAW))
	{
		for (var i = 0; i < _ECS_draw_num; i++)
		{
			if (_ECS_draw_main[i]._id == _component_id)
			{
				array_delete(_ECS_draw_main, i, 1);
				_ECS_draw_num--; _ECS_draw_init = true;
				break;
			}
		}
	}
	if (is_callable(_component.CLEAN))
	{
		for (var i = 0; i < _ECS_clean_num; i++)
		{
			if (_ECS_clean_main[i]._id == _component_id)
			{
				array_delete(_ECS_clean_main, i, 1);
				_ECS_clean_num--; _ECS_clean_init = true;
				break;
			}
		}
	}
	_index = array_get_index(_ECS_components, _component.get_id());
	array_delete(_ECS_components, _index, 1);
}
#endregion

#region components_count();
/// @func components_count():
/// @desc Returns the number of attached Components.
/// @returns {Real}
function components_count()
{
	return array_length(_ECS_components);
}
#endregion
#region components_list();
/// @func components_list();
/// @desc Returns an array of all attached Components as structs.
/// This function is primarily for debugging purposes.
/// @returns {Array}
function components_list()
{
	var _size = components_count();
	var _output = [];
	for (var i = 0; i < _size; i++)
	{
		var _id = _ECS_components[i];
		array_push(_output, COMPONENT.LIST[_id]);
	}
	return _output;
}
#endregion