Simp :: #import "Simp";

draw_world_rect :: (pos: Vector2, size: Vector2, color := Vector4.{ 1, 1, 1, 1 }) {
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

draw_world_quad :: (quad: Quad, color: Vector4) {
    Simp.immediate_quad(
        world_to_screen_pos(quad.v1), 
        world_to_screen_pos(quad.v2), 
        world_to_screen_pos(quad.v3), 
        world_to_screen_pos(quad.v4),
        color);
}

draw_world_quad_with_uv :: (quad: Quad, uv: Quad, color := Vector4.{ 1, 1, 1, 1 }) {
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

draw_world_tri :: (triangle: Tri, color: Vector4) {
    screen_v1 := world_to_screen_pos(triangle.v1);
    screen_v2 := world_to_screen_pos(triangle.v2);
    screen_v3 := world_to_screen_pos(triangle.v3);

    Simp.immediate_triangle(
        .{ screen_v1.x, screen_v1.y, 0 }, 
        .{ screen_v2.x, screen_v2.y, 0 },
        .{ screen_v3.x, screen_v3.y, 0 }, 
        color, color, color);
}

draw_world_line :: (from: Vector2, to: Vector2, thickness: float, color: Vector4) {
    v := to - from;
    draw_world_vector(from, v, thickness, color);
}

draw_world_vector :: (from: Vector2, v: Vector2, thickness: float, color: Vector4) {
    half_thickness := thickness * .5;

    dir := normalize(v);
    right := rotate_dir_90_deg_cw(dir);
    half_right := right * half_thickness;

    v1 := from - half_right;
    v2 := from + half_right;

    draw_world_quad(.{
        v1, 
        v2, 
        v2 + v, 
        v1 + v 
    }, color);
}

draw_partial_circle_world_outline :: (center: Vector2, start_dir: Vector2, radius: float, degrees: float, segments: u8, thickness: float, color: Vector4) {
        if segments == 0 return;

        degrees_per_segment := degrees / segments;

        last_inner := center + start_dir * radius;
        last_outer := last_inner + start_dir * thickness;

        for 1..segments {
            angle := degrees_per_segment * it;
            dir := rotate_by_deg(start_dir, -angle);

            inner := center + dir * radius;
            outer := inner + dir * thickness;

            draw_world_quad(.{ last_inner, inner, outer, last_outer }, color);

            last_inner = inner;
            last_outer = outer;
        }
}
