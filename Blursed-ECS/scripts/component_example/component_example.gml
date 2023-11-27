new Component("SayHello")
.add_event("INIT",	function()
{
	my_message = "Hello!";
	is_activated = false;
})
.add_event("STEP", function()
{
	if (!is_activated)
	{
		show_debug_message(my_message);
		is_activated = true;
	}
});

new Component("DestroyPressK")
.add_event("STEP", function()
{
	if (keyboard_check_pressed(ord("K")))
	{
		instance_destroy(id, true);
	}
})
.add_event("CLEAN_UP", function() //CLEAN
{
	show_debug_message("Cleaned Up!");
});

new Component("SpaceToggleA")
.add_event("STEP", function()
{
	if (keyboard_check_pressed(vk_space))
	{
		show_debug_message("Called ToggleA");
		component_add(COMPONENT.SpaceToggleB);
		component_remove(COMPONENT.SpaceToggleA);
	}
});

new Component("SpaceToggleB")
.add_event("STEP", function()
{
	if (keyboard_check_pressed(vk_space))
	{
		show_debug_message("Called ToggleB");
		component_remove(COMPONENT.SpaceToggleB);
		component_add(COMPONENT.SpaceToggleA);
	}
});

new Component("ListComponents")
.add_event("DRAW", function()
{
	var _size = components_count();
	var _components = components_list();
	var _output = "Components:\n";
	for (var i = 0; i < _size; i++)
	{
		var _component = _components[i];
		_output += "-" + _component.get_name() + "\n";
	}
	draw_text(x, y, _output);
});