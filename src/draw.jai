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