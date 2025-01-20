Camera :: struct {
    world_pos : Vector2;
    bottom_left_world_pos : Vector2;
    tool: Tool;
    selection : Selection;
    is_global : bool;
}

Tool :: enum u8 {
  Move;
  Rotate;
}

new_camera :: () -> Camera {
    return .{
        .{},
        .{},
        Tool.Move, 
        .{ null, .{} },
        true
    };
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

switch_tool :: (cam: *Camera) {
    tool_type_info :: type_info(Tool);
    first_tool :: #run tool_type_info.values[0];
    last_tool :: #run tool_type_info.values[tool_type_info.values.count - 1];

    if cam.tool == last_tool
      then cam.tool = first_tool;
      else cam.tool += 1;
}
