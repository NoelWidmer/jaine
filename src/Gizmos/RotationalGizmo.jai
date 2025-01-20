RotationalGizmo :: struct {
    grabbed: bool;
    pending: float;
}

draw_rotational_gizmo :: (vp: *Viewport, cam: *Camera, gizmo: *RotationalGizmo, center: Vector2, dir_x: Vector2) {
    dir_y := rotate_dir_90_deg_ccw(dir_x);

    if gizmo.grabbed {
        center_to_grab_dir := normalize(left_pressed_world_pos - center);

        // partial circle
        {
            center_to_pointer_dir := normalize(vp.pointer_world_pos - center);
            left := rotate_dir_90_deg_ccw(center_to_grab_dir);
            degrees := angle(center_to_grab_dir, center_to_pointer_dir);
            if dot(left, center_to_pointer_dir) > 0 then degrees = -degrees;
            segments := cast(u8) (abs(degrees) / 7);
            draw_partial_circle_world_outline(cam, center, center_to_grab_dir, outer_radius, degrees, segments, 1, color_gizmo_interactive);
        }

        // to grab point
        draw_world_vector(cam, center, center_to_grab_dir * outer_radius, 1, color_gizmo_blue);

        // to pointer
        draw_world_line(cam, center, vp.pointer_world_pos, 1, color_gizmo_interactive);
    } else {
        draw_partial_circle_world_outline(cam, center, dir_y, inner_radius, 90, 12, gizmo_interaction_size * .5, color_gizmo_blue);
    }

    draw_gizmo_axis(cam, center, dir_y, dir_x);
}

try_begin_gizmo_grab :: (vp: *Viewport, gizmo: *RotationalGizmo, center: Vector2) -> bool {
    dist := distance(vp.pointer_world_pos, center);

    if dist > outer_radius return false;

    if dist > inner_radius {
        gizmo.grabbed = true;
        return true;
    }

    return false;
}

try_drag_gizmo :: (vp: *Viewport, cam: *Camera, gizmo: *RotationalGizmo) {
    if !gizmo.grabbed || !vp.has_pointer_moved return;

    selected_screen_pos := world_to_screen_pos(cam, cam.selection.entity.pos);

    from := normalize(vp.last_pointer_screen_pos - selected_screen_pos);
    to := normalize(vp.pointer_screen_pos - selected_screen_pos);
    theta := angle(from, to);

    if theta == 0 return;

    up := rotate_dir_90_deg_ccw(from);
    up_dot := dot(up, to);

    delta_theta : float;

    if up_dot > 0 
        then delta_theta = theta;
        else delta_theta = -theta;

    gizmo.pending += delta_theta;
    cam.selection.entity.theta += delta_theta;
}

release_gizmo :: (cam: *Camera, history: *History, gizmo: *RotationalGizmo) {
    gizmo.grabbed = false;

    if gizmo.pending != 0 {
        event : HistoricalEvent;
        set(*event, RotationalHistoryEvent.{ cam.selection.entity.id, gizmo.pending });
        record(history, event);

        gizmo.pending = 0;
    }
}

#scope_file

outer_radius :: gizmo_length;
inner_radius :: outer_radius - gizmo_interaction_size * .5;
