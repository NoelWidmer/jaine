on_mouse_left :: (ev: Event) {
    if ev.key_pressed then return;
    if !try_select_entity() then spawn_entity();
}

on_mouse_right :: (ev: Event) {
    if ev.key_pressed {
        is_right_mouse_pressed = true;
        drag_start_pos = pointer_screen_pos;
    } else { // key released
        is_right_mouse_pressed = false;
        if is_drag {
            is_drag = false;
        } // else show context menu
    }
}

maybe_drag :: () {
    if !is_right_mouse_pressed then return;

    if is_drag {
        drag();
    } else {
        drag_vec := pointer_screen_pos - drag_start_pos;

        if length(drag_vec) >= min_drag_distance {
            is_drag = true;
            drag();
        }
    }
}

#scope_file

is_right_mouse_pressed := false;
is_drag := false;
drag_start_pos : Vector2;
min_drag_distance :: 10;

drag :: () {
    move_camera(-pointer_delta);
}