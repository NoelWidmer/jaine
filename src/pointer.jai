last_pointer_screen_pos : Vector2;
last_pointer_world_pos : Vector2;

pointer_screen_pos : Vector2;
pointer_world_pos : Vector2;

pointer_delta : Vector2;

invalidate_pointer_screen_position :: () {
    if input_application_has_focus {
        x, y, success := get_mouse_pointer_position(window, true);

        if success {
            last_pointer_screen_pos = pointer_screen_pos;
            last_pointer_world_pos = pointer_world_pos;

            pointer_screen_pos = Vector2.{ xx x, xx y };
            pointer_world_pos = screen_to_world_pos(pointer_screen_pos);

            pointer_delta = pointer_screen_pos - last_pointer_screen_pos;
        }
    }
}
