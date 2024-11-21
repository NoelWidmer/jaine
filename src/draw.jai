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

draw_tri :: (origin: Vector2, size: Vector2, dir: Vector2, color: Vector4) {
    screen_origin := world_to_screen_pos(origin);
    cross_dir : Vector2 = .{ dir.y, -dir.x };

    v1 := screen_origin + cross_dir * size.x * .5;
    v2 := screen_origin + dir * size.y;
    v3 := v1 - cross_dir * size.x;
    
    Simp.immediate_triangle(
        .{ v1.x, v1.y, 0 }, 
        .{ v2.x, v2.y, 0 },
        .{ v3.x, v3.y, 0 }, 
        color, color, color);
}