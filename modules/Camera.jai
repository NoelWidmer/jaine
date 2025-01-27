#import "Simp";

#import "Selection";
#import "Viewport";
#import "Math";
#import "World";
#import "History";

Camera :: struct {
    render_target : *Viewport;
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
        null,
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

update_cam :: (vp: *Viewport, cam: *Camera, history: *History, world: *World) {
    if vp.right_mouse_button.is_grab {        
        move_camera(cam, -vp.pointer.screen_delta);
    }

    cam.bottom_left_world_pos = cam.world_pos - vp.world_size * .5;
    update_selection(*cam.selection, vp, cam, history, world);
}

render :: (cam: *Camera, world: *World) {
    set_render_target(cam.render_target.window);
    
    // paint over previous frame with background color
    {
        background_color :: struct { 
            r :: .1; 
            g :: .1; 
            b :: .2;
        };

        clear_render_target(background_color.r, background_color.g, background_color.b, 1);
    }
    
    draw_world(cam, world);
    draw_selection(cam.render_target, cam);

    swap_buffers(cam.render_target.window);
}

switch_tool :: (cam: *Camera) {
    tool_type_info :: type_info(Tool);    
    first_tool :: #run tool_type_info.values[0];
    last_tool :: #run tool_type_info.values[tool_type_info.values.count - 1];

    if cam.tool == last_tool
      then cam.tool = first_tool;
      else cam.tool += 1;

    if cam.tool == {
        case Tool.Move; cam.selection.gizmo.vector2 = .{};
        case Tool.Rotate; cam.selection.gizmo.theta = .{};
    }
}
