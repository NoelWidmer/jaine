#import "GetRect";

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
    if cam.selected == entity return;

    // record history
    {
        event : HistoricalEvent;

        if cam.selected == null
            then set(*event, SelectedHistoryEvent.{ entity.id });
            else set(*event, SelectionModifiedHistoryEvent.{ cam.selected.id, entity.id });

        record(*history, event);
    }

    cam.selected = entity;
}

SelectedHistoryEvent :: struct {
    selected: u64;
}

// TOOD: the camera context should be part of the history record.
undo :: (cam: *Camera, event: SelectedHistoryEvent, undo: bool) {
    if undo {
        cam.selected = null;
    } else {
        cam.selected = get_entity(event.selected);
        assert(cam.selected != null, "could not redo select to select entity with id %", event.selected);
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

    cam.selected = get_entity(id);
    assert(cam.selected != null, "could not modify selection to select entity with id %", id);  
}

deselect_entity :: (cam: *Camera) {
    if cam.selected == null return;
    
    // record history
    {
        event : HistoricalEvent;
        set(*event, DeselectedHistoryEvent.{ cam.selected.id });
        record(*history, event);
    }

    cam.selected = null;
}

DeselectedHistoryEvent :: struct {
    selected: u64;
}

// TOOD: the camera context should be part of the history record.
undo :: (cam: *Camera, event: DeselectedHistoryEvent, undo: bool) {
    if undo {
        cam.selected = get_entity(event.selected);
        assert(cam.selected != null, "could not undo deselect to select entity with id %", event.selected);
    } else {
        cam.selected = null;
    }   
}

delete_selected :: (cam: *Camera) {
    if cam.selected == null return;
    // TODO history
    remove_entity(cam.selected);
    cam.selected = null;
}

try_grab_selected_gizmo :: (vp: *Viewport, cam: *Camera) {
    if cam.selected == null return;
    
    if gizmo_kind == {
        case GizmoKind.Vector2; try_begin_gizmo_grab(vp, *gizmo.vector2);
        case GizmoKind.Theta; try_begin_gizmo_grab(vp, *gizmo.theta, cam.selected.pos);
    }
}

try_drag_selected_gizmo :: (vp: *Viewport, cam: *Camera) {
    if cam.selected == null return;
    
    if gizmo_kind == {
        case GizmoKind.Vector2; try_drag_gizmo(vp, cam, *gizmo.vector2);
        case GizmoKind.Theta; try_drag_gizmo(vp, cam, *gizmo.theta);
    }
}

release_selected_gizmo :: (cam: *Camera) {
    if cam.selected == null return;

    if gizmo_kind == {
        case GizmoKind.Vector2; release_gizmo(cam, *gizmo.vector2);
        case GizmoKind.Theta; release_gizmo(cam, *gizmo.theta);
    }
}

draw_selection_gizmo :: (vp: *Viewport, cam: *Camera) {
    if cam.selected == null return;
    
    Simp.set_shader_for_color();

    right := ifx cam.is_global
        then Vector2.{ 1, 0 }
        else get_entity_right(cam.selected); 
    
    if cam.tool == {
        case Tool.Move;
            if gizmo_kind != GizmoKind.Vector2 {
                gizmo.vector2 = .{};
                gizmo_kind = GizmoKind.Vector2;
            }

            draw_positional_gizmo(cam, *gizmo.vector2, cam.selected.pos, right);
        case Tool.Rotate;
            if gizmo_kind != GizmoKind.Theta {
                gizmo.theta = .{};
                gizmo_kind = GizmoKind.Theta;
            }

            draw_rotational_gizmo(vp, cam, *gizmo.theta, cam.selected.pos, right);
    }
}

#scope_file

gizmo_kind : GizmoKind;
gizmo : Gizmo;

GizmoKind :: enum u8 {
  Vector2;
  Theta;
}

Gizmo :: union { 
  vector2: PositionalGizmo; 
  theta: RotationalGizmo;
}