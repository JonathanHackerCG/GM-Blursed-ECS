//Example Component
ECS_DEFINE
define_component("example1",
function()
{
	my_string1 = "Hello world 1!";
	is_activated1 = false;
},
function()
{
	if (!is_activated1)
	{
		show_debug_message(my_string1);
		is_activated1 = true;
	}
},
function()
{
	draw_text(x, y, my_string1);
});
ECS_DEFINE_END

ECS_DEFINE
define_component("example2",
function()
{
	my_string2 = "\nHello world 2!";
	is_activated2 = false;
},
function()
{
	if (!is_activated2)
	{
		show_debug_message(my_string2);
		is_activated2 = true;
	}
},
function()
{
	draw_text(x, y, my_string2);
});
ECS_DEFINE_END