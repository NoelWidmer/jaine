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

delete_selected_entity :: (ev: Event) {
    if ev.key_pressed || selected == -1 then return;
    despawn_entity(selected);
    selected = -1;
}

draw_selection_gizmo :: () {
    if selected == -1 return;

    entity := entities[selected];    
    
    if get_selected_tool() == {
        case Tool.Move;
            g := new_vector2_gizmo(entity.pos, .{ 1, 0 });
            gizmo_kind = GizmoKind.Vector2;
            gizmo.vector2 = g;
            draw_vector2_gizmo(g);
        case Tool.Rotate;
            g := ThetaGizmo.{ entity.pos };
            gizmo_kind = GizmoKind.Theta;
            gizmo.theta = g;
            draw_theta_gizmo(g);
    }
}

get_selected_gizmo_mode :: () -> GizmoMode {
    if selected == -1 return GizmoMode.None;
    
    if gizmo_kind == {
        case GizmoKind.Vector2; return get_gizmo_mode(gizmo.vector2);
        case GizmoKind.Theta; return get_gizmo_mode(gizmo.theta);
    }

    return GizmoMode.None;
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