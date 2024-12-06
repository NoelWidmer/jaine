window : Window_Type;

create_window :: () {
    window_width : s32 = 1920 / 2;
    window_height : s32 = 1080 / 2;

    window = create_window(
        window_name = "Jaine", 
        width = window_width, 
        height = window_height);

    on_window_size_changed_internal(window_width, window_height);
    Simp.set_render_target(window);
}

update_window :: () {
    update_window_events();

    for get_window_resizes() {
        Simp.update_window(it.window);
        
        if it.window == window {
            on_window_size_changed_internal(it.width, it.height);
        }
    }
    
    invalidate_pointer_screen_position();
        
    for events_this_frame {
        type := it.type;

        if type == {
            case .QUIT; quit();
            case .KEYBOARD;
            {
                if it.repeat return;                
                key := it.key_code;
                
                if key == .F11 {
                    if it.key_pressed {
                        toggle_fullscreen();
                        invalidate_pointer_screen_position();
                    }
                } else if key == .MOUSE_BUTTON_LEFT {
                    on_mouse_left(it);
                } else if key == .MOUSE_BUTTON_RIGHT {
                    on_mouse_right(it);
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

toggle_fullscreen :: () {
    new_state := !is_fullscreen;    
    success, width, height := toggle_fullscreen(window, new_state, *prev_window_info);

    if success {
        is_fullscreen = new_state;
        on_window_size_changed_internal(width, height);
    }
}

#scope_file

Vector32s :: struct {
    x : s32;
    y : s32;
}

is_fullscreen : bool;
viewport_pixel_size : Vector32s;
prev_window_info : Saved_Window_Info;

on_window_size_changed_internal :: (width: s32, height: s32) {
    viewport_pixel_size = .{ width, height };
    on_window_size_changed(width, height);
}