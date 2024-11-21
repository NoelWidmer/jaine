world_to_screen_pos :: (world_pos: Vector2) -> Vector2 {
    return world_pos - viewport_bottom_left;
}

screen_to_world_pos :: (screen_pos: Vector2) -> Vector2 {
    return screen_pos + viewport_bottom_left;
}

move_camera :: (delta_pos: Vector2) {
    cam_pos += delta_pos;
}

on_window_size_changed :: (width: s32, height: s32) {
    viewport_size = .{ xx width, xx height };
}

invalidate_viewport :: () {
    viewport_bottom_left = cam_pos - viewport_size * .5;
}

#scope_file

viewport_size : Vector2;
viewport_bottom_left : Vector2;
cam_pos : Vector2;