Simp :: #import "Simp";

draw_rect :: (world_pos: Vector2, size: Vector2, color: Vector4) {
    screen_pos := world_to_screen_pos(world_pos);

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
    screen_v1 := world_to_screen_pos(quad.v1);
    screen_v2 := world_to_screen_pos(quad.v2);
    screen_v3 := world_to_screen_pos(quad.v3);
    screen_v4 := world_to_screen_pos(quad.v4);

    Simp.immediate_quad(
        screen_v1, 
        screen_v2, 
        screen_v3, 
        screen_v4,
        color);
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

draw_vector :: (from: Vector2, v: Vector2, thickness: float, color: Vector4) {
    half_thickness := thickness * .5;

    dir := normalize(v);
    right := rotate_dir_90_deg_cw(dir);

    v1 := from - right * half_thickness;
    v2 := v1 + right * thickness;
    v3 := v2 + v;
    v4 := v1 + v;

    draw_quad_raw(Quad.{ v1, v2, v3, v4 }, color);
}

draw_line :: (from: Vector2, to: Vector2, thickness: float, color: Vector4) {
    v := to - from;
    draw_vector(from, v, thickness, color);
}

draw_partial_circle :: (center: Vector2, start_dir: Vector2, radius: float, degrees: float, segments: u8, thickness: float, color: Vector4) {
        if segments == 0 then segments = 1;
        
        degrees_per_segment := degrees / segments;

        last_inner := center + start_dir * radius;
        last_outer := last_inner + start_dir * thickness;

        for 1..segments {
            angle := degrees_per_segment * it;
            dir := rotate_around_origin(start_dir, -angle);

            inner := center + dir * radius;
            outer := inner + dir * thickness;

            draw_segment(last_inner, last_outer, inner, outer, color);

            last_inner = inner;
            last_outer = outer;
        }
}

#scope_file

draw_segment :: (inner_a: Vector2, outer_a: Vector2, inner_b: Vector2, outer_b: Vector2, color: Vector4) {
    draw_tri_raw(.{ inner_a, inner_b, outer_a }, color);
    draw_tri_raw(.{ inner_b, outer_b, outer_a }, color);
}