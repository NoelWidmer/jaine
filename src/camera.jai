Camera :: struct {
    world_pos : Vector2;
    bottom_left_world_pos : Vector2;
}

world_to_screen_pos :: (cam: *Camera, world_pos: Vector2) -> Vector2 {
    return world_pos - cam.bottom_left_world_pos;
}

screen_to_world_pos :: (cam: *Camera, screen_pos: Vector2) -> Vector2 {
    return screen_pos + cam.bottom_left_world_pos;
}

move_camera :: (cam: *Camera, delta_pos: Vector2) {
    cam.world_pos += delta_pos;
}

update_cam :: (vp: *Viewport, cam: *Camera) {
    cam.bottom_left_world_pos = cam.world_pos - vp.world_size * .5;
}
