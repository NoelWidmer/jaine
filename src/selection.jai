#import "GetRect";

get_selected :: () -> *Entity {
    return selected;
}

try_select_entity_under_pointer :: () -> bool {
    for *entities {
        quad := get_entity_quad(it);

        if is_inside_quad(pointer_world_pos, quad) {
            select_entity(it);
            return true;
        }
    }

    deselect_entity();
    return false;
}

select_entity :: (entity: *Entity) {
    if selected == entity return;

    // record history
    {
        event : HistoricalEvent;

        if selected == null
            then set(*event, SelectedHistoryEvent.{ entity.id });
            else set(*event, SelectionModifiedHistoryEvent.{ selected.id, entity.id });

        record(*history, event);
    }

    selected = entity;
}

SelectedHistoryEvent :: struct {
    selected: u64;
}

undo :: (event: SelectedHistoryEvent, undo: bool) {
    if undo {
        selected = null;
    } else {
        selected = get_entity(event.selected);
        assert(selected != null, "could not redo select to select entity with id %", event.selected);
    }    
}

SelectionModifiedHistoryEvent :: struct {
    prev_selected: u64;
    selected: u64;
}

undo :: (event: SelectionModifiedHistoryEvent, undo: bool) {
    id := ifx undo 
        then event.prev_selected 
        else event.selected;

    selected = get_entity(id);
    assert(selected != null, "could not modify selection to select entity with id %", id);  
}

deselect_entity :: () {
    if selected == null return;
    
    // record history
    {
        event : HistoricalEvent;
        set(*event, DeselectedHistoryEvent.{ selected.id });
        record(*history, event);
    }

    selected = null;
}

DeselectedHistoryEvent :: struct {
    selected: u64;
}

undo :: (event: DeselectedHistoryEvent, undo: bool) {
    if undo {
        selected = get_entity(event.selected);
        assert(selected != null, "could not undo deselect to select entity with id %", event.selected);
    } else {
        selected = null;
    }   
}

delete_selected :: () {
    if selected == null return;
    // TODO history
    remove_entity(selected);
    selected = null;
}

switch_global_local :: () {
    is_global_ = !is_global_;
}

is_global :: () -> bool {
    return is_global_;
}

try_grab_selected_gizmo :: () {
    if selected == null return;
    
    if gizmo_kind == {
        case GizmoKind.Vector2; try_begin_gizmo_grab(*gizmo.vector2);
        case GizmoKind.Theta; try_begin_gizmo_grab(*gizmo.theta, selected.pos);
    }
}

try_drag_selected_gizmo :: (cam: *Camera) {
    if selected == null return;
    
    if gizmo_kind == {
        case GizmoKind.Vector2; try_drag_gizmo(*gizmo.vector2);
        case GizmoKind.Theta; try_drag_gizmo(cam, *gizmo.theta);
    }
}

release_selected_gizmo :: () {
    if selected == null return;

    if gizmo_kind == {
        case GizmoKind.Vector2; release_gizmo(*gizmo.vector2);
        case GizmoKind.Theta; release_gizmo(*gizmo.theta);
    }
}

draw_selection_gizmo :: (cam: *Camera) {
    if selected == null return;
    
    Simp.set_shader_for_color();

    right := ifx is_global() 
        then Vector2.{ 1, 0 }
        else get_entity_right(selected); 
    
    if get_selected_tool() == {
        case Tool.Move;
            if gizmo_kind != GizmoKind.Vector2 {
                gizmo.vector2 = .{};
                gizmo_kind = GizmoKind.Vector2;
            }

            draw_positional_gizmo(cam, *gizmo.vector2, selected.pos, right);
        case Tool.Rotate;
            if gizmo_kind != GizmoKind.Theta {
                gizmo.theta = .{};
                gizmo_kind = GizmoKind.Theta;
            }

            draw_rotational_gizmo(cam, *gizmo.theta, selected.pos, right);
    }
}

#scope_file

selected : *Entity;

is_global_ := true;

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