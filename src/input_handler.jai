on_mouse_left :: (ev: Event) {
    if ev.key_pressed {
        is_left_mouse_pressed = true;
        left_drag_start_pos = pointer_screen_pos;
        handle_mode = overlaps_handle();
    } else {
        is_left_mouse_pressed = false;
        handle_mode = false;

        if is_left_drag {
            is_left_drag = false;
        } else {
            if !try_select_entity() then spawn_entity();
        }
    }
}

on_mouse_right :: (ev: Event) {
    if ev.key_pressed {
        is_right_mouse_pressed = true;
        right_drag_start_pos = pointer_screen_pos;
    } else {
        is_right_mouse_pressed = false;

        if is_right_drag {
            is_right_drag = false;
        } else {
            // context menu
        }
    }
}

maybe_drag :: () {
    if is_right_mouse_pressed {
        if is_right_drag {
            drag_right();
        } else {
            drag_vec := pointer_screen_pos - right_drag_start_pos;

            if length(drag_vec) >= min_drag_distance {
                is_right_drag = true;
                drag_right();
            }
        }
    }
    
    if is_left_mouse_pressed {
        if is_left_drag {
            drag_left();
        } else {
            drag_vec := pointer_screen_pos - left_drag_start_pos;

            if length(drag_vec) >= min_drag_distance {
                is_left_drag = true;
                drag_left();
            }
        }
    }
}

#scope_file

is_left_mouse_pressed : bool;
is_left_drag : bool;
left_drag_start_pos : Vector2;

is_right_mouse_pressed : bool;
is_right_drag : bool;
right_drag_start_pos : Vector2;

min_drag_distance :: 10;

handle_mode : bool;

drag_right :: () {
    move_camera(-pointer_delta);
}

drag_left :: () {
    if handle_mode {
        selected := get_selected();
        selected.pos += pointer_delta;
    }
}