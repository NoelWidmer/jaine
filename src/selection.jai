Selection :: struct {
    entity: *Entity;
    gizmo: Gizmo;
}

try_select_entity_under_pointer :: (vp: *Viewport, cam: *Camera, world: *World, history: *History) -> bool {
    for *world.entities {
        quad := get_entity_quad(it);

        if is_inside_quad(vp.pointer_world_pos, quad) {
            select_entity(cam, history, it);
            return true;
        }
    }

    deselect_entity(cam, history);
    return false;
}

select_entity :: (cam: * Camera, history: *History, entity: *Entity) {
    if cam.selection.entity == entity return;

    // record history
    {
        event : HistoricalEvent;

        if cam.selection.entity == null
            then set(*event, SelectedHistoryEvent.{ entity.id });
            else set(*event, SelectionModifiedHistoryEvent.{ cam.selection.entity.id, entity.id });

        record(history, event);
    }

    cam.selection.entity = entity;
}

SelectedHistoryEvent :: struct {
    selected: u64;
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

SelectionModifiedHistoryEvent :: struct {
    prev_selected: u64;
    selected: u64;
}

// TOOD: the camera context should be part of the history record.
undo :: (cam: *Camera, event: SelectionModifiedHistoryEvent, undo: bool, world: *World) {
    id := ifx undo 
        then event.prev_selected 
        else event.selected;

    cam.selection.entity = get_entity(world, id);
    assert(cam.selection.entity != null, "could not modify selection to select entity with id %", id);  
}

deselect_entity :: (cam: *Camera, history: *History) {
    if cam.selection.entity == null return;
    
    // record history
    {
        event : HistoricalEvent;
        set(*event, DeselectedHistoryEvent.{ cam.selection.entity.id });
        record(history, event);
    }

    cam.selection.entity = null;
}

DeselectedHistoryEvent :: struct {
    selected: u64;
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

delete_selected :: (cam: *Camera, world: *World) {
    if cam.selection.entity == null return;
    // TODO history
    remove_entity(cam.selection.entity, world);
    cam.selection.entity = null;
}

try_grab_selected_gizmo :: (vp: *Viewport, cam: *Camera) {
    if cam.selection.entity == null return;
    
    if cam.tool == {
        case Tool.Move; try_begin_gizmo_grab(vp, *cam.selection.gizmo.vector2);
        case Tool.Rotate; try_begin_gizmo_grab(vp, *cam.selection.gizmo.theta, cam.selection.entity.pos);
    }
}

try_drag_selected_gizmo :: (vp: *Viewport, cam: *Camera) {
    if cam.selection.entity == null return;
    
    if cam.tool == {
        case Tool.Move; try_drag_gizmo(vp, cam, *cam.selection.gizmo.vector2);
        case Tool.Rotate; try_drag_gizmo(vp, cam, *cam.selection.gizmo.theta);
    }
}

release_selected_gizmo :: (cam: *Camera, history: *History) {
    if cam.selection.entity == null return;

    if cam.tool == {
        case Tool.Move; release_gizmo(cam, history, *cam.selection.gizmo.vector2);
        case Tool.Rotate; release_gizmo(cam, history, *cam.selection.gizmo.theta);
    }
}

draw_selection_gizmo :: (vp: *Viewport, cam: *Camera) {
    if cam.selection.entity == null return;
    
    Simp.set_shader_for_color();

    right := ifx cam.is_global
        then Vector2.{ 1, 0 }
        else get_entity_right(cam.selection.entity); 
    
    if cam.tool == {
        case Tool.Move; draw_positional_gizmo(cam, *cam.selection.gizmo.vector2, cam.selection.entity.pos, right);
        case Tool.Rotate; draw_rotational_gizmo(vp, cam, *cam.selection.gizmo.theta, cam.selection.entity.pos, right);
    }
}
