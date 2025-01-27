#import "Basic";
#import "Tagged_Union";
#import "Camera";
#import "Viewport";
#import "World";
#import "History";
#import "Math";
#import "Input";
#import "Selection";

on_mouse_left :: (vp: *Viewport, cam: *Camera, world: *World, history: *History, ev: Event) {
    if ev.key_pressed {
        vp.left_mouse_button.pressed = true;
        vp.left_mouse_button.pressed_this_frame = true;

        vp.left_mouse_button.pressed_screen_pos = vp.pointer.screen_pos;
        vp.left_mouse_button.pressed_world_pos = screen_to_world_pos(cam, vp.pointer.screen_pos);
    } else {
        vp.left_mouse_button.released_this_frame = true;
        vp.left_mouse_button.pressed = false;
        vp.left_mouse_button.is_grab = false;
    }
}

on_mouse_right :: (vp: *Viewport, cam: *Camera, ev: Event) {
    if ev.key_pressed {
        vp.right_mouse_button.pressed = true;
        vp.right_mouse_button.pressed_this_frame = true;

        vp.right_mouse_button.pressed_screen_pos = vp.pointer.screen_pos;
        vp.right_mouse_button.pressed_world_pos = screen_to_world_pos(cam, vp.pointer.screen_pos);
    } else {
        vp.right_mouse_button.released_this_frame = true;
        vp.right_mouse_button.pressed = false;
        vp.right_mouse_button.is_grab = false;
    }
}

on_history :: (vp: *Viewport, cam: *Camera, world: *World, history: *History, ev: Event) {
    if vp.ctrl {
        if ev.key_pressed then return;
        
        event := ifx vp.shift
            then redo(history)
            else undo(history);

        if event == null return;

        added := isa(event, AddedHistoryEvent);
        if added {
            undo(added, !vp.shift, world);
            return;
        }

        removed := isa(event, RemovedHistoryEvent);
        if removed {
            undo(removed, !vp.shift, world);
            return;
        }

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

undo :: (event: AddedHistoryEvent, undo: bool, world: *World) {
    if undo then remove_(world, event.entity_id); else add();
}

undo :: (event: RemovedHistoryEvent, undo: bool, world: *World) {
    if undo then add(); else remove_(world, event.entity_id);
}

add :: () {
    // TODO: this requires the entity state to be recorded in the history.
}

remove_ :: (world: *World, entity_id: u64) {
    remove_entity(world, entity_id);
}

undo :: (event: PositionalHistoryEvent, undo: bool, world: *World) {
    entity := get_entity(world, event.entity_id);
    assert(entity != null, "could not modify history for entity with id %", event.entity_id);
    entity.pos += ifx undo then -event.delta else event.delta;
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
    if vp.shift && ev.key_pressed {
        entity := add_entity(world);
        entity.pos = vp.pointer.pointer_world_pos;
            
        // history
        {
            event : HistoricalEvent;
            set(*event, AddedHistoryEvent.{ entity.id });
            record(history, event);
        }

        select_entity(cam, history, entity);
    }
}

on_tool :: (cam: *Camera, ev: Event) {
    if !ev.key_pressed then switch_tool(cam);
}

on_global_local :: (cam: *Camera, ev: Event) {
    if !ev.key_pressed then cam.is_global = !cam.is_global;
}

on_delete :: (cam: *Camera, world: *World, history: *History, ev: Event) {
    if !ev.key_pressed then delete_selected(cam, world, history);
}
