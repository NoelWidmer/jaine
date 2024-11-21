window : Window_Type;

create_window :: () {
    window_width : s32 = 1920 / 2;
    window_height : s32 = 1080 / 2;

    window = create_window(
        window_name = "Lab", 
        width = window_width, 
        height = window_height/*, 
        background_color_rgb = .[background_color.x, background_color.y, background_color.z]*/);

    on_window_size_changed(window_width, window_height);
    Simp.set_render_target(window);
}

pre_render_window :: () {
    update_window_events();

    for get_window_resizes() {
        Simp.update_window(it.window);
        
        if it.window == window {
            on_window_size_changed(it.width, it.height);
        }
    }
    
    invalidate_pointer_screen_position();
        
    for events_this_frame {
        type := it.type;

        if type == {
            case .QUIT; quit();
            case .KEYBOARD;  handle_keyboard_event(it); 
        }            
    }
}

toggle_fullscreen :: () {
    new_state := !is_fullscreen;    
    success, width, height := toggle_fullscreen(window, new_state, *prev_window_info);

    if success {
        is_fullscreen = new_state;
        on_window_size_changed(width, height);
    }
}

#scope_file

is_fullscreen : bool;
prev_window_info : Saved_Window_Info;