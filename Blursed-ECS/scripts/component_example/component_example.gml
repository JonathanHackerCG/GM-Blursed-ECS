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