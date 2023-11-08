/// @desc obj_example: Create

show_debug_message("----------");
component_add(choose(COMPONENT.example1, COMPONENT.example2));
show_debug_message($"Has example1: {component_attached(COMPONENT.example1)}, Has example2: {component_attached(COMPONENT.example2)}");
component_add(choose(COMPONENT.example1, COMPONENT.example2));
show_debug_message($"Has example1: {component_attached(COMPONENT.example1)}, Has example2: {component_attached(COMPONENT.example2)}");