on_mouse_left :: (ev: Event) {
    if ev.key_pressed {
        is_left_mouse_pressed = true;
        left_pressed_screen_pos = pointer_screen_pos;
        left_pressed_world_pos = screen_to_world_pos(left_pressed_screen_pos);
        try_grab_selected_gizmo();
    } else {
        is_left_mouse_pressed = false;
        release_selected_gizmo();

        if is_left_grab {
            is_left_grab = false;
        } else {
            if !try_select_entity() then spawn_entity();
        }
    }
}

on_mouse_right :: (ev: Event) {
    if ev.key_pressed {
        is_right_mouse_pressed = true;
        right_pressed_screen_pos = pointer_screen_pos;
        right_pressed_world_pos = screen_to_world_pos(right_pressed_screen_pos);
    } else {
        is_right_mouse_pressed = false;

        if is_right_grab {
            is_right_grab = false;
        } else {
            // context menu
        }
    }
}

on_tool :: (ev: Event) {
    if !ev.key_pressed then switch_tool();
}

on_global_local :: (ev: Event) {
    if !ev.key_pressed then switch_global_local();
}

on_delete :: (ev: Event) {
    if !ev.key_pressed delete_selected();    
}

update_input :: () {
    if is_right_mouse_pressed {
        if is_right_grab {
            drag_right();
        } else {
            drag_vec := pointer_screen_pos - right_pressed_screen_pos;

            if length(drag_vec) >= min_drag_distance {
                is_right_grab = true;
                drag_right();
            }
        }
    }
    
    if is_left_mouse_pressed {
        if is_left_grab {
            drag_left();
        } else {
            drag_vec := pointer_screen_pos - left_pressed_screen_pos;

            if length(drag_vec) >= min_drag_distance {
                is_left_grab = true;
                drag_left();
            }
        }
    }
}

left_pressed_world_pos : Vector2;

#scope_file

left_pressed_screen_pos : Vector2;
is_left_mouse_pressed : bool;
is_left_grab : bool;

right_pressed_screen_pos : Vector2;
right_pressed_world_pos : Vector2;
is_right_mouse_pressed : bool;
is_right_grab : bool;

min_drag_distance :: 10;

drag_right :: () {
    drag_camera(-pointer_delta);
}

drag_left :: () {
    try_drag_selected_gizmo();
}