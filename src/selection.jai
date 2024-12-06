#import "GetRect";

get_selected :: () -> *Entity {
    return selected;
}

try_select_entity :: () -> bool {
    for *entities {
        quad := get_entity_quad(it);

        if is_inside_quad(pointer_world_pos, quad) {
            if selected == it {
                selected = null;
            } else {
                selected = it;
            }

            return true;
        }
    }

    return false;
}

delete_selected :: () {
    if selected == null return;
    despawn_entity(selected);
    selected = null;
}

draw_selection_gizmo :: () {
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

            new_positional_gizmo(*gizmo.vector2, selected.pos, right);
            draw_positional_gizmo(gizmo.vector2);
        case Tool.Rotate;
            if gizmo_kind != GizmoKind.Theta {
                gizmo.theta = .{};
                gizmo_kind = GizmoKind.Theta;
            }

            new_rotational_gizmo(*gizmo.theta, selected.pos, right);
            draw_rotational_gizmo(*gizmo.theta);
    }
}

switch_global_local :: () {
    is_global_ = !is_global_;
}

is_global :: () -> bool {
    return is_global_;
}

try_grab_selected_gizmo :: () -> bool {
    if selected == null return false;
    
    if gizmo_kind == {
        case GizmoKind.Vector2; return try_begin_gizmo_grab(*gizmo.vector2);
        case GizmoKind.Theta; return try_begin_gizmo_grab(*gizmo.theta);
    }
    
    return false;
}

try_drag_selected_gizmo :: () {
    if selected == null return;
    
    if gizmo_kind == {
        case GizmoKind.Vector2; try_drag_gizmo(*gizmo.vector2);
        case GizmoKind.Theta; try_drag_gizmo(*gizmo.theta);
    }
}

release_selected_gizmo :: () {
    if selected == null return;

    if gizmo_kind == {
        case GizmoKind.Vector2; release_gizmo(*gizmo.vector2);
        case GizmoKind.Theta; release_gizmo(*gizmo.theta);
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