gizmo_length :: 100;
gizmo_half_length :: gizmo_length * .5;
gizmo_interaction_size :: gizmo_length * .2;

gizmo_light :: .5;

draw_axis :: (pos: Vector2, right: Vector2, up: Vector2) {
    half_right := right * .5;
    half_up := up * .5;
    
    // x
    {
        v1 := pos - half_right - half_up;
        v2 := v1 + right * (gizmo_length + .5);
        v3 := v2 + up;
        v4 := v1 + up;

        draw_quad_raw(Quad.{ v1, v2, v3, v4 }, .{ 1, 0, 0, 1 });
    }

    // y
    {
        v1 := pos - half_right + half_up;
        v2 := v1 + right;
        v3 := v2 + up * (gizmo_length - .5);
        v4 := v3 - right;

        draw_quad_raw(Quad.{ v1, v2, v3, v4 }, .{ 0, 1, 0, 1 });
    }
}