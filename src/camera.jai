world_to_screen_pos :: (cam: *Camera, world_pos: Vector2) -> Vector2 {
    return world_pos - cam.bottom_left_world_pos;
}

screen_to_world_pos :: (cam: *Camera, screen_pos: Vector2) -> Vector2 {
    return screen_pos + cam.bottom_left_world_pos;
}

move_camera :: (cam: *Camera, delta_pos: Vector2) {
    cam.world_pos += delta_pos;
}

on_window_size_changed :: (width: s32, height: s32) {
    viewport_world_size = .{ xx width, xx height };
}

update_cam :: (cam: *Camera) {
    cam.bottom_left_world_pos = cam.world_pos - viewport_world_size * .5;
}

Camera :: struct {
    world_pos : Vector2;
    bottom_left_world_pos : Vector2;
}

#scope_file

viewport_world_size : Vector2;