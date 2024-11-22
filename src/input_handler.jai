on_mouse_left :: (ev: Event) {
    if ev.key_pressed {
        is_left_mouse_pressed = true;
        left_drag_start_pos = pointer_screen_pos;
        gizmo_mode = get_selected_gizmo_mode();
        last_theta = 0;
    } else {
        is_left_mouse_pressed = false;
        gizmo_mode = GizmoMode.None;

        if is_left_drag {
            is_left_drag = false;
        } else {
            if !try_select_entity() then spawn_entity();
        }
    }
}

on_mouse_right :: (ev: Event) {
    if ev.key_pressed {
        is_right_mouse_pressed = true;
        right_drag_start_pos = pointer_screen_pos;
    } else {
        is_right_mouse_pressed = false;

        if is_right_drag {
            is_right_drag = false;
        } else {
            // context menu
        }
    }
}

switch_tool :: (ev: Event) {
    if !ev.key_pressed then switch_tool();
}

update_input :: () {
    if is_right_mouse_pressed {
        if is_right_drag {
            drag_right();
        } else {
            drag_vec := pointer_screen_pos - right_drag_start_pos;

            if length(drag_vec) >= min_drag_distance {
                is_right_drag = true;
                drag_right();
            }
        }
    }
    
    if is_left_mouse_pressed {
        if is_left_drag {
            drag_left();
        } else {
            drag_vec := pointer_screen_pos - left_drag_start_pos;

            if length(drag_vec) >= min_drag_distance {
                is_left_drag = true;
                drag_left();
            }
        }
    }
}

#scope_file

is_left_mouse_pressed : bool;
is_left_drag : bool;
left_drag_start_pos : Vector2;

is_right_mouse_pressed : bool;
is_right_drag : bool;
right_drag_start_pos : Vector2;

min_drag_distance :: 10;

gizmo_mode : GizmoMode;

drag_right :: () {
    move_camera(-pointer_delta);
}

last_theta : float;

drag_left :: () {
    if gizmo_mode != GizmoMode.None {
        selected := get_selected();

        world_pos := selected.pos;
        screen_pos := world_to_screen_pos(world_pos);

        if gizmo_mode == {
            case GizmoMode.X; selected.pos = .{ world_pos.x + pointer_delta.x, world_pos.y };
            case GizmoMode.Y; selected.pos = .{ world_pos.x, world_pos.y + pointer_delta.y };
            case GizmoMode.XY; selected.pos += pointer_delta;
            case GizmoMode.Theta; {
                from := normalize(left_drag_start_pos - screen_pos);
                to := normalize(pointer_screen_pos - screen_pos);
                theta := angle(from, to);

                up := rotate_dir_90_deg_ccw(from);
                up_dot := dot(up, to);

                signed_theta : float;

                if up_dot > 0 
                    then signed_theta = theta;
                    else signed_theta = -theta;

                diff := signed_theta - last_theta;
                selected.theta += diff;
                print("%\n", selected.theta);
                last_theta = signed_theta;
            }
        }        
    }
}