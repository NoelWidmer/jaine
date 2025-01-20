on_mouse_left :: (vp: *Viewport, cam: *Camera, world: *World, history: *History, ev: Event) {
    if ev.key_pressed {
        vp.is_left_mouse_pressed = true;
        vp.left_pressed_screen_pos = vp.pointer_screen_pos;
        vp.left_pressed_world_pos = screen_to_world_pos(cam, vp.left_pressed_screen_pos);
        try_grab_selected_gizmo(vp, cam);
    } else {
        vp.is_left_mouse_pressed = false;
        release_selected_gizmo(cam, history);

        if vp.is_left_grab {
            vp.is_left_grab = false;
        } else {
            try_select_entity_under_pointer(vp, cam, world, history);
        }
    }
}

on_mouse_right :: (vp: *Viewport, cam: *Camera, ev: Event) {
    if ev.key_pressed {
        vp.is_right_mouse_pressed = true;
        vp.right_pressed_screen_pos = vp.pointer_screen_pos;
        vp.right_pressed_world_pos = screen_to_world_pos(cam, vp.right_pressed_screen_pos);
    } else {
        vp.is_right_mouse_pressed = false;

        if vp.is_right_grab {
            vp.is_right_grab = false;
        } else {
            // show context menu once we have one
        }
    }
}

on_history :: (vp: *Viewport, cam: *Camera, world: *World, history: *History, ev: Event) {
    if vp.ctrl {
        if ev.key_pressed then return;
        
        event := ifx vp.shift
            then redo(history)
            else undo(history);

        if event == null return;

        positional := isa(event, PositionalHistoryEvent);
        if positional {
            undo(positional, !vp.shift, world);
            return;
        }
        
        rotational := isa(event, RotationalHistoryEvent);
        if rotational {
            undo(rotational, !vp.shift, world);
            return;
        }
        
        selectional := isa(event, SelectedHistoryEvent);
        if selectional {
            undo(cam, selectional, !vp.shift, world);
            return;
        }
        
        selection_modified := isa(event, SelectionModifiedHistoryEvent);
        if selection_modified {
            undo(cam, selection_modified, !vp.shift, world);
            return;
        }
        
        deselectional := isa(event, DeselectedHistoryEvent);
        if deselectional {
            undo(cam, deselectional, !vp.shift, world);
            return;
        }
    }
}

PositionalHistoryEvent :: struct {
    entity_id: u64;
    delta: Vector2;
}

undo :: (event: PositionalHistoryEvent, undo: bool, world: *World) {
    entity := get_entity(world, event.entity_id);
    assert(entity != null, "could not modify history for entity with id %", event.entity_id);
    entity.pos += ifx undo then -event.delta else event.delta;
}

RotationalHistoryEvent :: struct {
    entity_id: u64;
    delta: float;
}

undo :: (event: RotationalHistoryEvent, undo: bool, world: *World) {
    entity := get_entity(world, event.entity_id);
    assert(entity != null, "could not modify history for entity with id %", event.entity_id);
    entity.theta += ifx undo then -event.delta else event.delta;
}

on_shift :: (vp: *Viewport, ev: Event) {
    vp.shift = ifx ev.key_pressed then true else false;
}

on_ctrl :: (vp: *Viewport, ev: Event) {
    vp.ctrl = ifx ev.key_pressed then true else false;
}

on_a :: (vp: *Viewport, cam: *Camera, world: *World, history: *History, ev: Event) {
    if vp.shift && ev.key_pressed then add_entity(vp, cam, world, history);
}

on_tool :: (cam: *Camera, ev: Event) {
    if !ev.key_pressed then switch_tool(cam);
}

on_global_local :: (cam: *Camera, ev: Event) {
    if !ev.key_pressed then cam.is_global = !cam.is_global;
}

on_delete :: (cam: *Camera, world: *World, ev: Event) {
    if !ev.key_pressed delete_selected(cam, world);    
}

update_input :: (vp: *Viewport, cam: *Camera) {
    if vp.is_right_mouse_pressed {
        if vp.is_right_grab {
            drag_right(vp, cam);
        } else {
            drag_vec := vp.pointer_screen_pos - vp.right_pressed_screen_pos;

            if length(drag_vec) > min_drag_distance {
                vp.is_right_grab = true;
                drag_right(vp, cam);
            }
        }
    }
    
    if vp.is_left_mouse_pressed {
        if vp.is_left_grab {
            drag_left(vp, cam);
        } else {
            drag_vec := vp.pointer_screen_pos - vp.left_pressed_screen_pos;

            if length(drag_vec) > min_drag_distance {
                vp.is_left_grab = true;
                drag_left(vp, cam);
            }
        }
    }
}

#scope_file

min_drag_distance :: 10;

drag_right :: (vp: *Viewport, cam: *Camera) {
    move_camera(cam, -vp.pointer_delta);
}

drag_left :: (vp: *Viewport, cam: *Camera) {
    try_drag_selected_gizmo(vp, cam);
}