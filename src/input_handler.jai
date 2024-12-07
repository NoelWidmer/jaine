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
            try_select_entity();
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
            // show context menu once we have one
        }
    }
}

on_history :: (ev: Event) {
    if ctrl {
        if ev.key_pressed then return;
        
        event := ifx shift
            then redo(*history)
            else undo(*history);

        if event == null return;

        positional := isa(event, PositionalHistoryEvent);
        if positional {
            undo(positional, !shift);
            return;
        }
        
        rotational := isa(event, RotationalHistoryEvent);
        if rotational {
            undo(rotational, !shift);
            return;
        }
    }
}

PositionalHistoryEvent :: struct {
    entity_id: u64;
    delta: Vector2;
}

undo :: (event: PositionalHistoryEvent, undo: bool) {
    entity := get_entity(event.entity_id);
    assert(entity != null, "could not modify history for entity with id %", event.entity_id);
    entity.pos += ifx undo then -event.delta else event.delta;
}

RotationalHistoryEvent :: struct {
    entity_id: u64;
    delta: float;
}

undo :: (event: RotationalHistoryEvent, undo: bool) {
    entity := get_entity(event.entity_id);
    assert(entity != null, "could not modify history for entity with id %", event.entity_id);
    entity.theta += ifx undo then -event.delta else event.delta;
}

on_shift :: (ev: Event) {
    shift = ifx ev.key_pressed then true else false;
}

on_ctrl :: (ev: Event) {
    ctrl = ifx ev.key_pressed then true else false;
}

on_a :: (ev: Event) {
    if shift && ev.key_pressed then add_entity();
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

            if length(drag_vec) > min_drag_distance {
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

            if length(drag_vec) > min_drag_distance {
                is_left_grab = true;
                drag_left();
            }
        }
    }
}

left_pressed_world_pos : Vector2;
shift : bool;
ctrl : bool;

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
    move_camera(-pointer_delta);
}

drag_left :: () {
    try_drag_selected_gizmo();
}