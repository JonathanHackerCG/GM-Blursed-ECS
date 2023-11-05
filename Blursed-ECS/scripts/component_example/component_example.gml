//Example Component
ECS_DEFINE
define_component("example",
function()
{
	my_string = "Hello world!";
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