# Blursed-ECS
A rudimentary entity-component system framework for GameMaker. This is an architectural pattern where game objects are represented as entities with attached components.

ECS is designed as an alternative (or supplement) to Object-Oriented style inheritance. Instead of deriving behavior from parents, Entities gain behavior from their attached components. An Entity can contain any number of any Components, or none at all. This approach can be more flexible than inheritance, and resolves issues where some objects need behavior from multiple parents.

However, I am wholly unqualified to explain ECS in detail. I learned about it like, last week, and wrote this code by accident. Instead, consult [Entity Component System FAQ](https://github.com/SanderMertens/ecs-faq) or [Game Programming Patterns - Component](https://gameprogrammingpatterns.com/component.html).

This codebase is currently in development, and is almost entirely untested. Using this ECS will be less performant than native GameMaker inheritance. **I do not currently recommend this system for production code.**

# Setup
* Download the latest release `*.yymps`.
* Import the `Blursed ECS` folder. The `Blursed ECS - Example` is optional, if desired.
* Call `ECS_initialize()` once at the start of the game to initialze the system.

# Use
* To create an Entity, create an object and set `ECS_ENTITY` as its parent.
* Add a Component to the Entity with `add_component(component)`. A Component uses the "namespace" `COMPONENT.<name>`.

**NOTE:** Entities must call `event_inherited()` in the Create, Step, and Draw events in order to use Components. Alternatively, `ECS_init_entity()` may be called manually in the Create event, along with `ECS_step()` and `ECS_draw()` in their corresponding events. This method can work for non `ECS_ENTITY` objects as well, if necessary.

# Components
Implement a Component using the following structure. The macros hide the boilerplate. This code should be placed in a script in global scope, so the Component can be defined when the game compiles.

The `INIT` function will be called when a Component is added to an Entity. The `STEP` function will be called in the Step event of the Entity. The `DRAW` function will be called in the Draw event of the Entity.
```javascript
COMPONENT_NAME template
COMPONENT_START
	//Called by component_add().
	INIT = function()
	{
		
	}
	
	//Called by ECS_step().
	STEP = function()
	{
		
	}
	
	//Called by ECS_draw().
	DRAW = function()
	{
		
	}
COMPONENT_END
```

# Example
This example Component, when added to an Entity, will result in "Hello world!" printed once per instance in the console, and "Hello world!" drawn at the position of every instance of the Entity.

```javascript
//Script
COMPONENT_NAME example
COMPONENT_START
	INIT = function()
	{
		my_string = "Hello world!";
		is_activated = false;
	}
	
	STEP = function()
	{
		if (!is_activated)
		{
			show_debug_message(my_string);
			is_activated = true;
		}
	}
	
	DRAW = function()
	{
		draw_text(x, y, my_string);
	}
COMPONENT_END
```
```javascript
//Create Event
add_component(COMPONENT.example);
```
# Planned Features
I am considering developing this further. The following features are planned.
* Dynamically removing Components.
* Cleanup event support. (Necessary for removing Components).
* Checking for attached Components.
* Accessing all instances with a specific Component.
* Performance testing and optimizations, if possible.
