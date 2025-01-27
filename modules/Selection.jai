#import "Basic";
#import "Camera";
#import "Entity";
#import "Gizmo";
#import "History";
#import "Viewport";
#import "World";
#import "Simp";
#import "Tagged_Union";
#import "Bucket_Array";
#import "Mathe";

Selection :: struct {
    entity: *Entity;
    gizmo: Gizmo;
}

update_selection :: (vp: *Viewport, cam: *Camera, history: *History, world: *World) {
    // update gizmo
    if cam.selection.entity != null {
        if cam.tool == {
            case Tool.Move; update_gizmo(*cam.selection.gizmo.vector2, vp, cam, history);
            case Tool.Rotate; update_gizmo(*cam.selection.gizmo.theta, vp, cam, history, cam.selection.entity.pos);
        }
    }    
    
    // update selection
    if vp.left_mouse_button.pressed_this_frame {
        is_gizmo_interaction := false;

        if cam.tool == {
            case Tool.Move; is_gizmo_interaction = cam.selection.gizmo.vector2.mode != PositionalGizmoMode.None;
            case Tool.Rotate; is_gizmo_interaction = cam.selection.gizmo.theta.grabbed;
        }

        if !is_gizmo_interaction then try_select_entity_under_pointer(vp, *cam.selection, world, history);
    }
}

select_entity :: (selection: *Selection, history: *History, entity: *Entity) {
    if selection.entity == entity return;

    // record history
    {
        event : HistoricalEvent;

        if selection.entity == null
            then set(*event, SelectedHistoryEvent.{ entity.id });
            else set(*event, SelectionModifiedHistoryEvent.{ selection.entity.id, entity.id });

        record(history, event);
    }

    selection.entity = entity;
}

// TOOD: the camera context should be part of the history record.
undo :: (cam: *Camera, event: SelectedHistoryEvent, undo: bool, world: *World) {
    if undo {
        cam.selection.entity = null;
    } else {
        cam.selection.entity = get_entity(world, event.selected);
        assert(cam.selection.entity != null, "could not redo select to select entity with id %", event.selected);
    }    
}

// TOOD: the camera context should be part of the history record.
undo :: (cam: *Camera, event: SelectionModifiedHistoryEvent, undo: bool, world: *World) {
    id := ifx undo 
        then event.prev_selected 
        else event.selected;

    cam.selection.entity = get_entity(world, id);
    assert(cam.selection.entity != null, "could not modify selection to select entity with id %", id);  
}

deselect_entity :: (selection: *Selection, history: *History) {
    if selection.entity == null return;
    
    // record history
    {
        event : HistoricalEvent;
        set(*event, DeselectedHistoryEvent.{ selection.entity.id });
        record(history, event);
    }

    selection.entity = null;
}

// TOOD: the camera context should be part of the history record.
undo :: (cam: *Camera, event: DeselectedHistoryEvent, undo: bool, world: *World) {
    if undo {
        cam.selection.entity = get_entity(world, event.selected);
        assert(cam.selection.entity != null, "could not undo deselect to select entity with id %", event.selected);
    } else {
        cam.selection.entity = null;
    }   
}

delete_selected :: (cam: *Camera, world: *World, history: *History) {
    if cam.selection.entity == null return;
    removed := remove_entity(cam.selection.entity, world);
    cam.selection.entity = null;    
            
    // history
    {
        event : HistoricalEvent;
        set(*event, RemovedHistoryEvent.{ removed.id });
        record(history, event);
    }
}

draw_selection :: (vp: *Viewport, cam: *Camera) {
    if cam.selection.entity == null return;
    
    set_shader_for_color();

    right := ifx cam.is_global
        then .{ 1, 0 }
        else get_entity_right(cam.selection.entity); 
    
    if cam.tool == {
        case Tool.Move; draw_positional_gizmo(cam, *cam.selection.gizmo.vector2, cam.selection.entity.pos, right);
        case Tool.Rotate; draw_rotational_gizmo(vp, cam, *cam.selection.gizmo.theta, cam.selection.entity.pos, right);
    }
}

#scope_file

try_select_entity_under_pointer :: (vp: *Viewport, selection: *Selection, world: *World, history: *History) -> bool {
    for *world.entities {
        quad := get_entity_quad(it);

        if is_inside_quad(vp.pointer.world_pos, quad) {
            select_entity(selection, history, it);
            return true;
        }
    }

    deselect_entity(selection, history);
    return false;
}