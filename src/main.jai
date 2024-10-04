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

quit := false;

main :: () {
    // aquire sdl version.
    {
        sdl_version : SDL_version;
        SDL_GetVersion(*sdl_version);
        print("Using SDL %.%.%\n", sdl_version.major, sdl_version.minor, sdl_version.patch);
    }
    
    // load state.
    {
        #if OS == .WINDOWS {
            persistence_path = sprint("%/tea", get_path_os_saved_games());
        }

        replace_chars(persistence_path, "\\", #char "/");
        print("persistent path: %\n", persistence_path);

        persistence_file_path = sprint("%/persistent_state.dat", persistence_path);

        if try_load_persisted_state() {
            print("% / %", persisted_state.window_width, persisted_state.window_height);
            window = create_window(persisted_state.window_width, persisted_state.window_height);

            if persisted_state.fullscreen {
                success, window_width, window_height := toggle_fullscreen(window, true, *prev_window_info);
                if success then loaded_state.fullscreen = true;
            } else {
                SetWindowLongW(window, GWL_STYLE, persisted_state.window_style);
                SetWindowLongW(window, GWL_EXSTYLE, persisted_state.window_ex_style);
            }
        } else {
            window = create_window(1920 / 2, 1080 / 2);
        }
    }
    
    Simp.set_render_target(window);
    
    /*theme = default_theme_procs[0]();
    set_default_theme(theme);*/
    
    time_prev = seconds_since_init();

    while !quit {
        reset_temporary_storage();        
        update_window_events();

        // @Incomplete: Handle resizes in the actual scene drawing, which we currently don't.
        for get_window_resizes() {
            Simp.update_window(it.window);
            
            if it.window == window {
                window_resized := it.width != loaded_state.window_width || it.height != loaded_state.window_height;

                if(window_resized) {
                    if !loaded_state.fullscreen {
                        loaded_state.window_width = it.width;
                        loaded_state.window_height = it.height;
                    }
                }
            }
        }
        
        for events_this_frame {
            type := it.type;

            //getrect_handle_event(it);

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

SAVE_VERSION : u32 : 1;

loaded_state : LoadedState;
LoadedState :: struct {
    fullscreen: bool;

    window_width: s32;
    window_height: s32;
}

persisted_state : PersistentState;
PersistentState :: struct {
    version: u32;

    fullscreen: bool; // TODO remember which monitor the window was on.

    window_width: s32;
    window_height: s32;

    window_style: s32;
    window_ex_style: s32;
}

window : Window_Type;
prev_window_info : Saved_Window_Info;

background_color :: Vector4.{201 / 255.0, 17 / 255.0, 69 / 255.0, 1};

frame_count : int = 0;
time_prev : float64;
time_delta : float;

//theme : Overall_Theme;

persistence_path : string;
persistence_file_path : string;

create_window :: (width: s32, height: s32) -> HWND {
    loaded_state.fullscreen = false;

    loaded_state.window_width = width;
    loaded_state.window_height = height;

    return create_window(
        window_name = "Tea", 
        width = width, 
        height = height, 
        background_color_rgb = .[background_color.x, background_color.y, background_color.z]);
}

try_load_persisted_state :: () -> bool {
    file, success := file_open(persistence_file_path, false, false, false);

    if success {
        version : u32 = 0;
        success = file_read(*file, xx *version, xx size_of(type_of(version)));

        if (success) {
            file_seek(file, 0, .START);

            if version == SAVE_VERSION {
                success, bytes_read := file_read(*file, cast(*void) *persisted_state, size_of(PersistentState));
                file_close(*file);

                if (success) {
                    return true;
                } else {
                    print("ERROR: unable to read persisted state.\n");
                }
            }
            else {
                print("WARNING: we currently don't convert persited state versions and use the default state instead.\n");
            }
        }
        else
        {
            print("ERROR: unable to read persisted state.\n");
        }
    }

    return false;
}

consider_persist_loaded_state :: () {
    print("persisting state: %\n", loaded_state);

    make_directory_if_it_does_not_exist(persistence_path, false);
    file, success := file_open(persistence_file_path, true, false, false);

    if success {
        // sync persisted state.
        {
            persisted_state.version = SAVE_VERSION;
            persisted_state.fullscreen = loaded_state.fullscreen;

            persisted_state.window_width = loaded_state.window_width;
            persisted_state.window_height = loaded_state.window_height;

            persisted_state.window_style = GetWindowLongW(window, GWL_STYLE);
            persisted_state.window_ex_style = GetWindowLongW(window, GWL_EXSTYLE);
        }

        success = file_write(*file, cast(*void) *persisted_state, xx size_of(PersistentState));
        file_close(*file);

        if !success {
            print("ERROR: unable to persist state.\n");
        }
    }
}

handle_keyboard_event :: (ev: Event) {
    if ev.repeat return;

    key := ev.key_code;

    if key == .F11 && ev.key_pressed then toggle_fullscreen();
    else if key == .CTRL && ev.key_pressed then consider_persist_loaded_state();
}

toggle_fullscreen :: () {
    new_state := !loaded_state.fullscreen;
    success, window_width, window_height := toggle_fullscreen(window, new_state, *prev_window_info);
    if success then loaded_state.fullscreen = new_state;
}

render :: () {
    Simp.clear_render_target(background_color.x, background_color.y, background_color.z, background_color.w);

    /*k := window_height * .1;
    r := get_rect(k*.5, 2.1*k, 3*k, k);

    for 0..10 {
        button(r, "test", *theme.button_theme);
        r.y -= k;
    }*/
}
