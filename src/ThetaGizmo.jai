ThetaGizmo :: struct {
    pos: Vector2;
    grabbed: bool;
}

new_theta_gizmo :: (gizmo: *ThetaGizmo, pos: Vector2) {
    <<gizmo = .{ 
        pos, 
        gizmo.grabbed 
    };
}

draw_theta_gizmo :: (gizmo: ThetaGizmo) {
    center := gizmo.pos;

    first_inner := Vector2.{ center.x, center.y + gizmo_length };
    first_outer := Vector2.{ center.x, first_inner.y + gizmo_interaction_size };

    last_inner := first_inner;
    last_outer := first_outer;

    segments :: 48;
    degrees_per_segment :: 360.0 / segments;
    original_dir :: Vector2.{ 0, 1 };

    for 1..segments - 1 {
        angle := degrees_per_segment * it;
        dir := rotate_around_origin(original_dir, angle);

        inner := center + dir * gizmo_length;
        outer := inner + dir * gizmo_interaction_size;

        draw_segment(last_inner, last_outer, inner, outer);

        last_inner = inner;
        last_outer = outer;
    }

    draw_segment(last_inner, last_outer, first_inner, first_outer);
}

try_begin_gizmo_grab :: (gizmo: *ThetaGizmo) -> bool {
    dist := distance(pointer_world_pos, gizmo.pos);

    if dist > outer_radius return false;

    if dist > gizmo_length {
        gizmo.grabbed = true;
        return true;
    }

    return false;
}

try_drag_gizmo :: (gizmo: *ThetaGizmo) {
    if !gizmo.grabbed return;
    if last_pointer_screen_pos == pointer_screen_pos return;

    selected := get_selected();
    selected_screen_pos := world_to_screen_pos(selected.pos);

    from := normalize(last_pointer_screen_pos - selected_screen_pos);
    to := normalize(pointer_screen_pos - selected_screen_pos);
    theta := angle(from, to);

    if theta == 0 return;

    up := rotate_dir_90_deg_ccw(from);
    up_dot := dot(up, to);

    signed_theta : float;

    if up_dot > 0 
        then signed_theta = theta;
        else signed_theta = -theta;

    selected.theta += signed_theta;
}

release_gizmo :: (gizmo: *ThetaGizmo) {
    gizmo.grabbed = false;
}

#scope_file

outer_radius :: gizmo_length + gizmo_interaction_size;

draw_segment :: (inner_a: Vector2, outer_a: Vector2, inner_b: Vector2, outer_b: Vector2) {
    color :: Vector4.{ 0, 0, 1, 1 };
    draw_tri_raw(.{ inner_a, inner_b, outer_a }, color);
    draw_tri_raw(.{ inner_b, outer_b, outer_a }, color);
}
