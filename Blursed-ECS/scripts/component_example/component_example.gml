//Example Component
ECS_DEFINE
define_component("example1",
function()
{
	my_string = "Hello world 1!";
	is_activated = false;
},
function()
{
	if (!is_activated)
	{
		show_debug_message(my_string);
		is_activated = true;
	}
},
function()
{
	draw_text(x, y, my_string);
});
ECS_DEFINE_END

ECS_DEFINE
define_component("example2",
function()
{
	my_string = "Hello world 2!";
	is_activated = false;
},
function()
{
	if (!is_activated)
	{
		show_debug_message(my_string);
		is_activated = true;
	}
},
function()
{
	draw_text(x, y, my_string);
});
ECS_DEFINE_END