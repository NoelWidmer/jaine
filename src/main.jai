#import "Basic"; //()(MEMORY_DEBUGGER=true);
#import "Hash_Table";
#import "Math";
#import "Random";
#import "Sound_Player";
#import "Wav_File";
#import "stb_vorbis";
#import "Window_Creation";
#import "Windows";
#import "File";
#import "String";
#import "Thread";
#import "Input";
#import "System";
#import "SDL";
#import "GetRect";
Simp :: #import "Simp";

#scope_module

main :: () {
    // aquire sdl version.
    {
        sdl_version : SDL_version;
        SDL_GetVersion(*sdl_version);
        print("Using SDL %.%.%\n", sdl_version.major, sdl_version.minor, sdl_version.patch);
    }

    window = create_window(
        window_name = "Lab", 
        width = window_width, 
        height = window_height, 
        background_color_rgb = .[background_color.x, background_color.y, background_color.z]);
    
    Simp.set_render_target(window);
    
    // setup time
    {
        time_prev = seconds_since_init();
        time_delta = 0;
    }

    while !quit {
        reset_temporary_storage();
        update_window_events();

        // @Incomplete: Handle resizes in the actual scene drawing, which we currently don't.
        for get_window_resizes() {
            Simp.update_window(it.window);
            
            /*if it.window == window {
                if it.width != window_width || it.height != window_height
                { } // TODO
            }*/
        }

        invalidate_pointer_position();
        
        for events_this_frame {
            type := it.type;

            if type == {
                case .QUIT; quit = true;
                case .KEYBOARD;  handle_keyboard_event(it); 
            }            
        }

        render();        
        Simp.swap_buffers(window);
        
        // update time
        {
            time_current := seconds_since_init();
            time_delta = xx (time_current - time_prev);
            time_prev = time_current; 
        }

        frame_count += 1;
    }
}

#scope_file

quit := false;

window : Window_Type;
prev_window_info : Saved_Window_Info;
is_active_window : bool;

is_fullscreen := false;
window_width : s32 = 1920 / 2;
window_height : s32 = 1080 / 2;

background_color :: Vector4.{201 / 255.0, 17 / 255.0, 69 / 255.0, 1};

frame_count : int = 0;
time_prev : float64;
time_delta : float;

current_pointer_position : Vector2;
last_pointer_position : Vector2;
pointer_position_delta : Vector2;

handle_keyboard_event :: (ev: Event) {
    if ev.repeat return;

    key := ev.key_code;

    if key == .F11 {
        if ev.key_pressed then toggle_fullscreen();
    } else if key == .MOUSE_BUTTON_LEFT {
        if !ev.key_pressed then spawn_entity();
    }
}

toggle_fullscreen :: () {
    new_state := !is_fullscreen;
    success, window_width, window_height := toggle_fullscreen(window, new_state, *prev_window_info);
    if success then is_fullscreen = new_state;
}

invalidate_pointer_position :: () {
    if input_application_has_focus {
        x, y, success := get_mouse_pointer_position(window, true);

        if success {
            last_pointer_position = current_pointer_position;
            current_pointer_position = Vector2.{ xx x, xx y };
            pointer_position_delta = current_pointer_position - last_pointer_position;

            //if pointer_position_delta.x > 0 || pointer_position_delta.y > 0 then print("%: %x/%y\n", frame_count, pointer_position_delta.x, pointer_position_delta.y);
        }
    }
}

Entity :: struct {
    pos: Vector2;
}

entities : [..]Entity;

spawn_entity :: () {
    entity : Entity = .{
        pos = current_pointer_position
    };

    array_add(*entities, entity);
}

render :: () {
    Simp.clear_render_target(background_color.x, background_color.y, background_color.z, background_color.w);
    Simp.set_shader_for_color();
    //print("%", input_application_has_focus);

    //color : Vector4 = .{ 1, 1, 1, 1 };

    for entities {
        p := it.pos;
        Simp.immediate_quad(p + .{ -10, -10 }, p + .{ +10, -10 }, p + .{ +10, +10 }, p + .{ -10, +10 });
    }
}
