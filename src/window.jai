Window :: struct {
    type : Window_Type;
    is_fullscreen : bool;
    prev_info : Saved_Window_Info;
    screen_size : Vector32s;
    world_size: Vector2;
}

create_window :: () -> Window {
    window_width : s32 = 1920 / 2;
    window_height : s32 = 1080 / 2;

    window: Window;
    window.type = create_window(
        window_name = "Jaine", 
        width = window_width, 
        height = window_height);
        
    on_window_size_changed(*window, window_width, window_height);

    return window;
}

update_window :: (window: *Window, cam: *Camera) {
    update_window_events();

    for get_window_resizes() {
        Simp.update_window(it.window);
        
        if it.window == window.type then on_window_size_changed(window, it.width, it.height);
    }
    
    invalidate_pointer_screen_pos(window, cam);
        
    for events_this_frame {
        type := it.type;

        if type == {
            case .QUIT; quit();
            case .KEYBOARD;
            {
                if it.repeat return;        

                key := it.key_code;
                
                if key == .F11 {
                    if it.key_pressed && toggle_fullscreen(window) then invalidate_pointer_screen_pos(window, cam);
                } else if key == .MOUSE_BUTTON_LEFT {
                    on_mouse_left(cam, it);
                } else if key == .MOUSE_BUTTON_RIGHT {
                    on_mouse_right(cam, it);
                } else if key == xx #char "A" {
                    on_a(it);
                } else if key == xx #char "T" {
                    on_tool(it);
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

toggle_fullscreen :: (window: *Window) -> bool {
    new_state := !window.is_fullscreen;    
    success, width, height := toggle_fullscreen(window.type, new_state, *window.prev_info);

    if success {
        window.is_fullscreen = new_state;
        on_window_size_changed(window, width, height);
    }

    return success;
}

on_window_size_changed :: (window: *Window, width: s32, height: s32) {
    window.screen_size = .{ width, height };
    window.world_size = .{ xx width, xx height };
}