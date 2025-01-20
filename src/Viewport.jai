Viewport :: struct {
    window : Window_Type;

    is_fullscreen : bool;
    prev_info : Saved_Window_Info;

    screen_size : Vector32s;
    world_size: Vector2;

    last_pointer_screen_pos : Vector2;
    last_pointer_world_pos : Vector2;

    pointer_screen_pos : Vector2;
    pointer_world_pos : Vector2;

    has_pointer_moved: bool;
    pointer_delta : Vector2;
}

create_viewport :: () -> Viewport {
    vp_width : s32 = 1920 / 2;
    vp_height : s32 = 1080 / 2;

    vp: Viewport;
    vp.window = create_window(
        window_name = "Jaine", 
        width = vp_width, 
        height = vp_height);
        
    on_viewport_size_changed(*vp, vp_width, vp_height);

    return vp;
}

update_viewport :: (vp: *Viewport, cam: *Camera) {
    update_window_events();

    for get_window_resizes() {
        Simp.update_window(it.window);
        
        if it.window == vp.window then on_viewport_size_changed(vp, it.width, it.height);
    }
    
    invalidate_pointer_screen_pos(vp, cam);
        
    for events_this_frame {
        type := it.type;

        if type == {
            case .QUIT; quit();
            case .KEYBOARD;
            {
                if it.repeat return;        

                key := it.key_code;
                
                if key == .F11 {
                    if it.key_pressed && toggle_fullscreen(vp) then invalidate_pointer_screen_pos(vp, cam);
                } else if key == .MOUSE_BUTTON_LEFT {
                    on_mouse_left(vp, cam, it);
                } else if key == .MOUSE_BUTTON_RIGHT {
                    on_mouse_right(vp, cam, it);
                } else if key == xx #char "A" {
                    on_a(vp, it);
                } else if key == xx #char "T" {
                    on_tool(cam, it);
                } else if key == xx #char "X" {
                    on_global_local(it);
                } else if key == xx #char "Z" {
                    on_history(it);
                } else if key == .DELETE {
                    on_delete(it);
                } else if key == .SHIFT {
                    on_shift(it);
                } else if key == .CTRL {
                    on_ctrl(it);
                }
            }
        }            
    }
}

#scope_file

Vector32s :: struct {
    x : s32;
    y : s32;
}

toggle_fullscreen :: (vp: *Viewport) -> bool {
    new_state := !vp.is_fullscreen;    
    success, width, height := toggle_fullscreen(vp.window, new_state, *vp.prev_info);

    if success {
        vp.is_fullscreen = new_state;
        on_viewport_size_changed(vp, width, height);
    }

    return success;
}

on_viewport_size_changed :: (vp: *Viewport, width: s32, height: s32) {
    vp.screen_size = .{ width, height };
    vp.world_size = .{ xx width, xx height };
}

invalidate_pointer_screen_pos :: (vp: *Viewport, cam: *Camera) {
    if !input_application_has_focus then return;
    
    x, y, success := get_mouse_pointer_position(vp.window, true);

    if success {
        vp.last_pointer_screen_pos = vp.pointer_screen_pos;
        vp.pointer_screen_pos = Vector2.{ xx x, xx y };

        if vp.pointer_screen_pos == vp.last_pointer_screen_pos {
            vp.has_pointer_moved = false;
        } else {
            vp.has_pointer_moved = true;
            vp.pointer_delta = vp.pointer_screen_pos - vp.last_pointer_screen_pos;

            // TODO: pointer world position also depends on camera position. so this is not going to work properly.
            vp.last_pointer_world_pos = vp.pointer_world_pos;
            vp.pointer_world_pos = screen_to_world_pos(cam, vp.pointer_screen_pos);
        }
    }
}