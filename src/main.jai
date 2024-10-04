#import "Basic"; //()(MEMORY_DEBUGGER=true);
#import "Hash_Table";
#import "Math";
#import "Random";
#import "Sound_Player";
#import "Wav_File";
#import "stb_vorbis";
#import "Window_Creation";
#import "File";
#import "String";
#import "Thread";
#import "Input";
#import "System";
#import "SDL";
#import "GetRect";
Simp :: #import "Simp";

#scope_file

window : Window_Type;

background_color :: Vector4.{201 / 255.0, 17 / 255.0, 69 / 255.0, 1};

window_width : s32 = 1920; 
window_height : s32 = 1080;

prev_window_info : Saved_Window_Info;

frame_count : int = 0;
time_prev : float64;
time_delta : float;

theme : Overall_Theme;

#scope_module

quit := false;

main :: () {
    // sdl version
    {
        sdl_version : SDL_version;
        SDL_GetVersion(*sdl_version);
        print("Using SDL %.%.%\n", sdl_version.major, sdl_version.minor, sdl_version.patch);
    }

    window = create_window(
        window_name="Tee", 
        width=window_width, 
        height=window_height, 
        background_color_rgb = .[background_color.x, background_color.y, background_color.z]);
    
    Simp.set_render_target(window);
    
    theme = default_theme_procs[0]();
    set_default_theme(theme);
    
    time_prev = seconds_since_init();

    while !quit {
        reset_temporary_storage();
        
        update_window_events();

        // @Incomplete: Handle resizes in the actual scene drawing, which we currently don't.
        for get_window_resizes() {
            Simp.update_window(it.window);
            
            if it.window == window {
                should_reinit := (it.width != window_width) || (it.height != window_height);
                
                window_width  = it.width;
                window_height = it.height;
            }
        }
        
        for events_this_frame {
            type := it.type;

            getrect_handle_event(it);

            if type == {
                case .QUIT; quit = true;
                case .KEYBOARD;  handle_keyboard_event(it); 
            }            
        }

        // delta time
        {
            time_current := seconds_since_init();
            time_delta = xx (time_current - time_prev);
            time_prev = time_current; 
        }

        render();
        
        Simp.swap_buffers(window);
        frame_count += 1;
    }
}

#scope_file

handle_keyboard_event :: (ev: Event) {
    if ev.repeat return;

    key := ev.key_code;

    if key == .F11 && ev.key_pressed then toggle_fullscreen();
}

is_fullscreen := false;

toggle_fullscreen :: () {
    new_state := !is_fullscreen;
    fullscreen_success, window_width, window_height := toggle_fullscreen(window, new_state, *prev_window_info);
    if fullscreen_success then is_fullscreen = new_state;
}

render :: () {
    Simp.clear_render_target(background_color.x, background_color.y, background_color.z, background_color.w);

    k := window_height * .1;
    r := get_rect(k*.5, 2.1*k, 3*k, k);

    for 0..10 {
        button(r, "test", *theme.button_theme);
        r.y -= k;
    }
}
