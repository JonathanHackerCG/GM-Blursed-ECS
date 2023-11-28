# Blursed-ECS
Blursed-ECS is a rudimentary entity-component system framework for GameMaker. This is an architectural pattern where game objects are represented as entities with attached components.

ECS is designed as an alternative (or supplement) to Object-Oriented style inheritance. Instead of deriving behavior from parents, Entities gain behavior from their attached Components. An Entity can contain any number of any Components, or none at all. This approach can be more flexible than inheritance, and resolves issues where some objects need behavior from multiple parents.

However, I am wholly unqualified to explain ECS in detail. For more details, please consult [Entity Component System FAQ](https://github.com/SanderMertens/ecs-faq) or [Game Programming Patterns - Component](https://gameprogrammingpatterns.com/component.html).

This codebase is currently in a testing phase. Using this ECS will be less performant than native GameMaker inheritance. **I do not currently recommend this system for production code.**

# Setup
* Download the latest release `*.yymps`.
* Import the `Blursed ECS` folder. The `Blursed ECS - Example` is optional, if desired.

# Use
* To create an Entity, create an object and set `ECS_ENTITY` as its parent.
* Add a Component to the Entity with `add_component(component)`. A Component uses the "namespace" `COMPONENT.<name>`.

**NOTE:** Entities inheriting from `ECS_ENTITY` must call `event_inherited()` in the Create, Step, Draw, and Clean Up events in order to use Components. Alternatively, you may use `ECS_call_events()` to specifically call the Component events in the corresponding GML events. This approach does not require `ECS_ENTITY`.

# Components
A Component is a struct containing a list of events and associated functions.
* The `INIT`, `STEP`, `DRAW`, and `CLEAN_UP` events are supported by default by `ECS_ENTITY`.
* The `INIT` event is special, and will also be called when using `component_add()`.
* The `CLEAN_UP` event is special, and will also be called when using `component_remove()`.

You can create a Component with the `Component(name)` constructor. For each Component, use `add_event()` to add functions to the Component's events. Components are stored globally in a `COMPONENT` singleton.

# Functions (Components)
* `Component.get_id()` Returns a unique numerical ID for this Component. Only useful internally.
* `Component.get_name()` Returns the name of this Component as a string.
* `Component.add_event(event, function)` Adds a function as an event for this Component.
* `Component.get_event(event)` Returns an associated function by event name for this Component.

# Functions (Entities)
* `ECS_init_entity()` Initialize an Entity to provide required ECS variables. Called automatically by `component_add()`.
* `ECS_call_events(event)` Calls a specified event (string) for all Components attached to this Entity. Example: `ECS_call_events("DRAW")` should be put in the draw event.
* `component_add(component, [call_INIT])` Adds a Component by `COMPONENT.<name>`. By default, also calls the `INIT` event for that Component.
* `component_attached(component)` Returns true if a Component is attached.
* `component_remove(component, [call_CLEAN_UP])` Removes a Component by `COMPONENT.<name>`. By default, also calls the `CLEAN_UP` event for that Component.
* `component_call_event(component, event)` Manually calls a specific event for a Component. Much slower than `ECS_call_events()`.
* `components_count()` Returns the number of Components attached to an Entity.
* `components_list()` Returns an Array of all attached Components (as structs). Only intended for debugging purposes.

# Example
This example Component. This Component will result in "Hello world!" printed once per instance of that Entity in the console.

```javascript
//Script
with (new Component("HelloWorld"))
{
	add_event("INIT", function()
	{
    		my_string = "Hello world!";
    		is_activated = false;
	});

	add_event("STEP", function()
	{
		if (!is_activated)
		{
			show_debug_message(my_string);
			is_activated = true;
		}
	});
}
```
```javascript
//Create Event
add_component(COMPONENT.HelloWorld);
```
# Planned Features
The following features are being considered for future development:
* Enforcing the order that Components are executed.
* Accessing all instances with a specific Component.
* Optional reference by string name instead of COMPONENT.name.
* Performance testing and optimizations, if possible.
