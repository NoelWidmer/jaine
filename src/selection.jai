Selection :: struct {
    entity: *Entity;
    gizmo: Gizmo;
}

try_select_entity_under_pointer :: (vp: *Viewport, cam: *Camera) -> bool {
    for *entities {
        quad := get_entity_quad(it);

        if is_inside_quad(vp.pointer_world_pos, quad) {
            select_entity(cam, it);
            return true;
        }
    }

    deselect_entity(cam);
    return false;
}

select_entity :: (cam: * Camera, entity: *Entity) {
    if cam.selection.entity == entity return;

    // record history
    {
        event : HistoricalEvent;

        if cam.selection.entity == null
            then set(*event, SelectedHistoryEvent.{ entity.id });
            else set(*event, SelectionModifiedHistoryEvent.{ cam.selection.entity.id, entity.id });

        record(*history, event);
    }

    cam.selection.entity = entity;
}

SelectedHistoryEvent :: struct {
    selected: u64;
}

// TOOD: the camera context should be part of the history record.
undo :: (cam: *Camera, event: SelectedHistoryEvent, undo: bool) {
    if undo {
        cam.selection.entity = null;
    } else {
        cam.selection.entity = get_entity(event.selected);
        assert(cam.selection.entity != null, "could not redo select to select entity with id %", event.selected);
    }    
}

SelectionModifiedHistoryEvent :: struct {
    prev_selected: u64;
    selected: u64;
}

// TOOD: the camera context should be part of the history record.
undo :: (cam: *Camera, event: SelectionModifiedHistoryEvent, undo: bool) {
    id := ifx undo 
        then event.prev_selected 
        else event.selected;

    cam.selection.entity = get_entity(id);
    assert(cam.selection.entity != null, "could not modify selection to select entity with id %", id);  
}

deselect_entity :: (cam: *Camera) {
    if cam.selection.entity == null return;
    
    // record history
    {
        event : HistoricalEvent;
        set(*event, DeselectedHistoryEvent.{ cam.selection.entity.id });
        record(*history, event);
    }

    cam.selection.entity = null;
}

DeselectedHistoryEvent :: struct {
    selected: u64;
}

// TOOD: the camera context should be part of the history record.
undo :: (cam: *Camera, event: DeselectedHistoryEvent, undo: bool) {
    if undo {
        cam.selection.entity = get_entity(event.selected);
        assert(cam.selection.entity != null, "could not undo deselect to select entity with id %", event.selected);
    } else {
        cam.selection.entity = null;
    }   
}

delete_selected :: (cam: *Camera) {
    if cam.selection.entity == null return;
    // TODO history
    remove_entity(cam.selection.entity);
    cam.selection.entity = null;
}

try_grab_selected_gizmo :: (vp: *Viewport, cam: *Camera) {
    if cam.selection.entity == null return;
    
    if gizmo_kind == {
        case GizmoKind.Vector2; try_begin_gizmo_grab(vp, *cam.selection.gizmo.vector2);
        case GizmoKind.Theta; try_begin_gizmo_grab(vp, *cam.selection.gizmo.theta, cam.selection.entity.pos);
    }
}

try_drag_selected_gizmo :: (vp: *Viewport, cam: *Camera) {
    if cam.selection.entity == null return;
    
    if gizmo_kind == {
        case GizmoKind.Vector2; try_drag_gizmo(vp, cam, *cam.selection.gizmo.vector2);
        case GizmoKind.Theta; try_drag_gizmo(vp, cam, *cam.selection.gizmo.theta);
    }
}

release_selected_gizmo :: (cam: *Camera) {
    if cam.selection.entity == null return;

    if gizmo_kind == {
        case GizmoKind.Vector2; release_gizmo(cam, *cam.selection.gizmo.vector2);
        case GizmoKind.Theta; release_gizmo(cam, *cam.selection.gizmo.theta);
    }
}

draw_selection_gizmo :: (vp: *Viewport, cam: *Camera) {
    if cam.selection.entity == null return;
    
    Simp.set_shader_for_color();

    right := ifx cam.is_global
        then Vector2.{ 1, 0 }
        else get_entity_right(cam.selection.entity); 
    
    if cam.tool == {
        case Tool.Move;
            if gizmo_kind != GizmoKind.Vector2 {
                cam.selection.gizmo.vector2 = .{};
                gizmo_kind = GizmoKind.Vector2;
            }

            draw_positional_gizmo(cam, *cam.selection.gizmo.vector2, cam.selection.entity.pos, right);
        case Tool.Rotate;
            if gizmo_kind != GizmoKind.Theta {
                cam.selection.gizmo.theta = .{};
                gizmo_kind = GizmoKind.Theta;
            }

            draw_rotational_gizmo(vp, cam, *cam.selection.gizmo.theta, cam.selection.entity.pos, right);
    }
}

#scope_file

gizmo_kind : GizmoKind;

GizmoKind :: enum u8 {
  Vector2;
  Theta;
}