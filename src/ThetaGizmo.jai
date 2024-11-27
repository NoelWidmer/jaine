ThetaGizmo :: struct {
    pos: Vector2;
    right: Vector2;
    up: Vector2;
    grabbed: bool;
}

new_theta_gizmo :: (gizmo: *ThetaGizmo, pos: Vector2, right: Vector2) {
    up := rotate_dir_90_deg_ccw(right);

    <<gizmo = .{ 
        pos, 
        right,
        up,
        gizmo.grabbed 
    };
}

draw_theta_gizmo :: (gizmo: ThetaGizmo) {
    center := gizmo.pos;

    // try cull
    {
        aabb := get_rect(pos.x - right * .5, pos.y - up * .5, outer_radius, outer_radius);
        // TODO: check if can be culled, then return
    }

    if gizmo.grabbed {
        center_to_grab_dir := normalize(left_pressed_world_pos - center);

        // partial circle
        {
            center_to_pointer_dir := normalize(pointer_world_pos - center);
            left := rotate_dir_90_deg_ccw(center_to_grab_dir);
            degrees := angle(center_to_grab_dir, center_to_pointer_dir);
            if dot(left, center_to_pointer_dir) > 0 then degrees = -degrees;
            segments := cast(u8) (abs(degrees) / 7);
            draw_partial_circle_outline(center, center_to_grab_dir, inner_radius, degrees, segments, 1, color_gizmo_interactive);
        }

        // to grab point
        draw_vector(center, center_to_grab_dir * outer_radius, 1, color_gizmo_blue);

        // to pointer
        draw_line(center, pointer_world_pos, 1, color_gizmo_interactive);
    } else {
        draw_partial_circle_outline(center, gizmo.up, inner_radius, 90, 12, gizmo_interaction_half_size, color_gizmo_blue);
    }

    draw_axis(center, gizmo.right, gizmo.up);
}

try_begin_gizmo_grab :: (gizmo: *ThetaGizmo) -> bool {
    dist := distance(pointer_world_pos, gizmo.pos);

    if dist > outer_radius return false;

    if dist > inner_radius {
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

outer_radius :: gizmo_length;
inner_radius :: outer_radius - gizmo_interaction_half_size;
