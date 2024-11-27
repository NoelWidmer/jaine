world_to_screen_pos :: (world_pos: Vector2) -> Vector2 {
    return world_pos - viewport_bottom_left_world_pos;
}

screen_to_world_pos :: (screen_pos: Vector2) -> Vector2 {
    return screen_pos + viewport_bottom_left_world_pos;
}

move_camera :: (delta_pos: Vector2) {
    cam_world_pos += delta_pos;
}

on_window_size_changed :: (width: s32, height: s32) {
    viewport_world_size = .{ xx width, xx height };
}

invalidate_viewport_world_pos :: () {
    viewport_bottom_left_world_pos = cam_world_pos - viewport_world_size * .5;
}

#scope_file

viewport_world_size : Vector2;
viewport_bottom_left_world_pos : Vector2;
cam_world_pos : Vector2;