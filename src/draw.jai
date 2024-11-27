Simp :: #import "Simp";

draw_rect :: (pos: Vector2, size: Vector2, color: Vector4) {
    screen_pos := world_to_screen_pos(pos);

    half_size_x := size.x * .5;
    half_size_y := size.y * .5;

    Simp.immediate_quad(
        screen_pos + .{ -half_size_x, -half_size_y }, 
        screen_pos + .{ half_size_x, -half_size_y }, 
        screen_pos + .{ half_size_x, half_size_y }, 
        screen_pos + .{ -half_size_x, half_size_y },
        color);
}

draw_quad_raw :: (quad: Quad, color: Vector4) {
    Simp.immediate_quad(
        world_to_screen_pos(quad.v1), 
        world_to_screen_pos(quad.v2), 
        world_to_screen_pos(quad.v3), 
        world_to_screen_pos(quad.v4),
        color);
}

draw_quad_uv_raw :: (quad: Quad, uv: Quad, color: Vector4) {
    Simp.immediate_quad(
        world_to_screen_pos(quad.v1), 
        world_to_screen_pos(quad.v2), 
        world_to_screen_pos(quad.v3), 
        world_to_screen_pos(quad.v4),
        color,
        uv.v1,
        uv.v2,
        uv.v3,
        uv.v4);
}

draw_tri_raw :: (triangle: Tri, color: Vector4) {
    screen_v1 := world_to_screen_pos(triangle.v1);
    screen_v2 := world_to_screen_pos(triangle.v2);
    screen_v3 := world_to_screen_pos(triangle.v3);

    Simp.immediate_triangle(
        .{ screen_v1.x, screen_v1.y, 0 }, 
        .{ screen_v2.x, screen_v2.y, 0 },
        .{ screen_v3.x, screen_v3.y, 0 }, 
        color, color, color);
}

draw_line :: (from: Vector2, to: Vector2, thickness: float, color: Vector4) {
    v := to - from;
    draw_vector(from, v, thickness, color);
}

draw_vector :: (from: Vector2, v: Vector2, thickness: float, color: Vector4) {
    half_thickness := thickness * .5;

    dir := normalize(v);
    right := rotate_dir_90_deg_cw(dir);
    half_right := right * half_thickness;

    draw_quad_raw(.{ 
        from - half_right, 
        from + half_right, 
        v2 + v, 
        v1 + v 
    }, color);
}

draw_partial_circle_outline :: (center: Vector2, start_dir: Vector2, radius: float, degrees: float, segments: u8, thickness: float, color: Vector4) {
        if segments == 0 then segments = 1;

        degrees_per_segment := degrees / segments;

        last_inner := center + start_dir * radius;
        last_outer := last_inner + start_dir * thickness;

        for 1..segments {
            angle := degrees_per_segment * it;
            dir := rotate(start_dir, -angle);

            inner := center + dir * radius;
            outer := inner + dir * thickness;

            draw_circle_segment(last_inner, last_outer, inner, outer, color);

            last_inner = inner;
            last_outer = outer;
        }
}

#scope_file

draw_circle_segment :: (inner_a: Vector2, outer_a: Vector2, inner_b: Vector2, outer_b: Vector2, color: Vector4) {
    draw_tri_raw(.{ inner_a, inner_b, outer_a }, color);
    draw_tri_raw(.{ inner_b, outer_b, outer_a }, color);
}