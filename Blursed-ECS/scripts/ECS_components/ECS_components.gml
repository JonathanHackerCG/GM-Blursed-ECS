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
function Component(_name) constructor
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
	_EVENTS = {};
	#region add_event(event, function);
	/// @func add_event(event, function):
	/// @arg	{String} event
	/// @arg	{Function} function
	/// @returns {Struct.Component}
	static add_event = function(_event, _function)
	{
		_EVENTS[$ _event] = method(self, _function);
		return self;
	}
	#endregion
	#region get_event(event);
	/// @func get_event(event):
	/// @arg	{String} event
	/// @returns {Function}
	static get_event = function(_event)
	{
		return _EVENTS[$ _event];
	}
	#endregion
	#endregion
	
	//Registering the new Component.
	variable_struct_set(COMPONENT, _name, self);
	array_push(COMPONENT.LIST, self);
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
	_ECS_events = {};
	_ECS_components = [];
}
#endregion
#region ECS_call_events(event);
/// @func ECS_call_events(event):
/// @desc Calls a specified event for all Components attached to this Entity.
/// @arg	{String} event
function ECS_call_events(_event)
{
	var _event_data = _ECS_events[$ _event];
	if (_event_data == undefined) { exit; }
	
	var _size = _event_data._count;
	if (_event_data._updated)
	{
		//Update cache of attached Component methods if any have been added/removed.
		_event_data._methods_cached = [];
		for (var i = 0; i < _size; i++)
		{
			array_push(_event_data._methods_cached, _event_data._methods[i]._method);
		}
		_event_data._updated = false;
	}
	
	if (_size > 0)
	{
		//Call every method for this event of the attached Component.
		var i = 0; repeat (_size)
		{
			_event_data._methods_cached[i]();
		i++; }
	}
}
#endregion

#region component_add(component, [call_INIT]);
/// @func component_add(component, [call_INIT]):
/// @desc Attaches a Component to an Entity.
/// Will also call the INIT event by default.
/// @arg	{Struct.Component} component Syntax: COMPONENT.<name>
/// @arg	{Bool} [call_INIT] Default: true
function component_add(_component, _call_INIT = true)
{
	//Initialize if not already initialized.
	if (!variable_instance_exists(id, "_ECS_events"))
	{
		ECS_init_entity();
	}
	if (component_attached(_component)) { exit; }
	var _component_id = _component.get_id();
	
	//Add all event methods to this Entity.
	var _events = struct_get_names(_component._EVENTS);
	var _size = array_length(_events);
	for (var i = 0; i < _size; i++)
	{
		var _event = _events[i];
		var _event_method = _component.get_event(_event);
		if (is_callable(_event_method))
		{
			//Define a new event if one did not exist.
			if (_ECS_events[$ _event] == undefined)
			{
				_ECS_events[$ _event] = {
					_methods : [],
					_methods_cached : [],
					_count : 0
				};
			}
			
			//Update data for this event.
			var _event_data = _ECS_events[$ _event];
			array_push(_event_data._methods, {
				_id : _component_id,
				_method : method(id, _event_method)
			});
			_event_data._count++;
			_event_data._updated = true;
		}
	}
	
	//Special call to the initialize event.
	if (_call_INIT)
	{
		component_call_event(_component, "INIT");
	}
	
	//Add Component ID to attached Components.
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
#region component_remove(component, [call_CLEAN_UP]);
/// @func component_remove(component, [call_CLEAN_UP]):
/// @desc Removes a Component from an Entity.
/// Will also call the CLEAN event by default.
/// @arg	{Struct.Component} component Syntax: COMPONENT.<name>
/// @arg	{Bool} [call_CLEAN_UP] Default: true
function component_remove(_component, _call_CLEAN_UP = true)
{
	if (!component_attached(_component)) { exit; }
	var _component_id = _component.get_id();
	
	//Remove all associated Component methods from the Entity.
	var _events = struct_get_names(_component._EVENTS);
	var _size = array_length(_events);
	for (var i = 0; i < _size; i++)
	{
		var _event = _events[i];
		var _event_data = _ECS_events[$ _event];
		for  (var j = 0; j < _event_data._count; j++)
		{
			if (_event_data._methods[j]._id == _component_id)
			{
				array_delete(_event_data._methods, j, 1);
				_event_data._count--;
				_event_data._updated = true;
				break;
			}
		}
	}
	
	if (_call_CLEAN_UP)
	{
		component_call_event(_component, "CLEAN_UP");
	}
	
	//Remove Component ID from attached Components.
	var _index = array_get_index(_ECS_components, _component.get_id());
	array_delete(_ECS_components, _index, 1);
}
#endregion
#region component_call_event(component, event);
/// @func component_call_event(component, event):
/// @desc Manually calls a specified event of a Component.
/// @arg	{Struct.Component} component
/// @arg	{String} event
function component_call_event(_component, _event)
{
	var _method_init = _component.get_event(_event);
	if (is_callable(_method_init))
	{
		method(id, _method_init)();
	}
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