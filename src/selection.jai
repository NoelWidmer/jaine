#import "GetRect";

get_selected :: () -> *Entity {
    if selected == -1 then return null;
    return *entities[selected];
}

try_select_entity :: () -> bool {
    for entities {
        rect := get_entity_rect(it);

        if is_inside(pointer_world_pos.x, pointer_world_pos.y, rect) {
            if selected == it_index {
                selected = -1;
            } else {
                selected = it_index;
            }

            return true;
        }
    }

    return false;
}

delete_selected :: () {
    if selected == -1 return;
    despawn_entity(selected);
    selected = -1;
}

draw_selection_gizmo :: () {
    if selected == -1 return;

    entity := entities[selected];    
    
    if get_selected_tool() == {
        case Tool.Move;
            if gizmo_kind != GizmoKind.Vector2 {
                gizmo.vector2 = .{};
                gizmo_kind = GizmoKind.Vector2;
            }

            new_vector2_gizmo(*gizmo.vector2, entity.pos, .{ 1, 0 });
            draw_vector2_gizmo(gizmo.vector2);
        case Tool.Rotate;
            if gizmo_kind != GizmoKind.Theta {
                gizmo.theta = .{};
                gizmo_kind = GizmoKind.Theta;
            }

            new_theta_gizmo(*gizmo.theta, entity.pos);
            draw_theta_gizmo(*gizmo.theta);
    }
}

try_grab_selected_gizmo :: () -> bool {
    if selected == -1 return false;
    
    if gizmo_kind == {
        case GizmoKind.Vector2; return try_begin_gizmo_grab(*gizmo.vector2);
        case GizmoKind.Theta; return try_begin_gizmo_grab(*gizmo.theta);
    }
    
    return false;
}

try_drag_selected_gizmo :: () {
    if selected == -1 return;
    
    if gizmo_kind == {
        case GizmoKind.Vector2; try_drag_gizmo(gizmo.vector2);
        case GizmoKind.Theta; try_drag_gizmo(*gizmo.theta);
    }
}

release_selected_gizmo :: () {
    if selected == -1 return;

    if gizmo_kind == {
        case GizmoKind.Vector2; release_gizmo(*gizmo.vector2);
        case GizmoKind.Theta; release_gizmo(*gizmo.theta);
    }
}

#scope_file

selected : s64 = -1;

gizmo_kind : GizmoKind;
gizmo : Gizmo;

GizmoKind :: enum u8 {
  Vector2;
  Theta;
}

Gizmo :: union { 
  vector2: Vector2Gizmo; 
  theta: ThetaGizmo;
}