ThetaGizmo :: struct {
    pos: Vector2;
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

get_gizmo_mode :: (gizmo: ThetaGizmo) -> GizmoMode {
    dist := distance(pointer_world_pos, gizmo.pos);
    if dist > outer_radius then return GizmoMode.None;
    if dist > gizmo_length then return GizmoMode.Theta;
    return GizmoMode.None;
}

#scope_file

outer_radius :: gizmo_length + gizmo_interaction_size;

draw_segment :: (inner_a: Vector2, outer_a: Vector2, inner_b: Vector2, outer_b: Vector2) {
    color :: Vector4.{ 0, 0, 1, 1 };
    draw_tri_raw(.{ inner_a, inner_b, outer_a }, color);
    draw_tri_raw(.{ inner_b, outer_b, outer_a }, color);
}
