//Example Component
ECS_DEFINE
define_component("SayHello",
function()
{
	my_message = "Hello!";
	is_activated = false;
},
function()
{
	if (!is_activated)
	{
		show_debug_message(my_message);
		is_activated = true;
	}
});
ECS_DEFINE_END

ECS_DEFINE
define_component("DestroyPressK",,
function() //STEP
{
	if (keyboard_check_pressed(ord("K")))
	{
		instance_destroy(id, true);
	}
},,
function() //CLEAN
{
	show_debug_message("Cleaned Up!");
});
ECS_DEFINE_END

ECS_DEFINE
define_component("ListComponents",,,
function() //DRAW
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
ECS_DEFINE_END