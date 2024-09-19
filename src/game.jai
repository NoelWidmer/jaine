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
Simp :: #import "Simp";

#scope_module

window_width := 1280; 
window_height := 720;

game_width := 640;
game_height := 360;

SceneType :: enum u8 {
    NONE;
    SPLASH;
    TITLE;
    GAME;
}

frame_count : int = 0;
time_prev : float64;
time_delta : float;

SavedGame :: struct {
    version: u32;
    res_width: u32;
    res_height: u32;
    sfx_volume: u32;
    music_volume: u32;
    fullscreen: u32;
    current_level: s32;
}

should_quit_game := false;

#scope_file

prev_window_info : Saved_Window_Info;

window : Window_Type;

pixel_surf : Simp.Texture;

SAVE_VERSION :: 1;
save_game_file : string;
save_game_path : string;

current_scene := SceneType.NONE;

#scope_module

game_set_scene :: (scene: SceneType) {
    if current_scene == {
        case .TITLE; scene_title_exit();
        case .GAME; scene_game_exit();
        case .SPLASH; scene_splash_exit();
    }
    
    if scene == {
        case .TITLE; scene_title_enter();
        case .GAME; scene_game_enter();
        case .SPLASH; scene_splash_enter();
    }

    current_scene = scene;
}

game_toggle_fullscreen :: (fullscreen: bool) {
    fullscreen_success, window_width, window_height := toggle_fullscreen(window, fullscreen, *prev_window_info);
}

game_save :: () {
    data := SavedGame.{
        SAVE_VERSION,
        1280,
        720,
        0,
        0,
        0,
        -1,
    };

    options_save(*data);
    map_save(*data);

    make_directory_if_it_does_not_exist(save_game_path, false);

    fp, success := file_open(save_game_file, true, false, false);
    if success {
        success = file_write(*fp, *data, size_of(SavedGame));
        file_close(*fp);
    }
}

//#run disable_runtime_console();

main :: () {
    // sdl version
    {
        sdl_version : SDL_version;
        SDL_GetVersion(*sdl_version);
        print("Using SDL %.%.%\n", sdl_version.major, sdl_version.minor, sdl_version.patch);
    }

    // save game path
    {
        save_game_path = sprint("%/nw_lab", get_path_os_saved_games());
        replace_chars(save_game_path, "\\", #char "/");
        save_game_file = sprint("%/saved_game.dat", save_game_path);
    }

    // load game
    {
        data : SavedGame;

        fp, success := file_open(save_game_file, false, false, false);
        if success {
            // Read out version first
            version : u32 = 0;
            success = file_read(*fp, xx *version, xx size_of(type_of(version)));
            if (success) {
                file_seek(fp, 0, .START);

                if version == SAVE_VERSION {
                    success, bytes_read := file_read(*fp, xx *data, size_of(SavedGame));

                    if (success) {
                        options_load(*data);
                        map_load(*data);
                    }
                }
                else {
                    // TODO Saved game version conversion
                }

                file_close(*fp);
            }
        }
    }

    window = create_window(window_name="Noël's Lab", width=window_width, height=window_height, background_color_rgb = .[12 / 255.0, 7 / 255.0, 40 / 255.0]);

    if (options_get_fullscreen()) {
        game_toggle_fullscreen(true);
    }
    
    Simp.set_render_target(window);

    // init
    {        
        pixel_surf = Simp.texture_create_render_target(game_width, game_height, .RGBA8, .Render_Target);

        //audio_init();
        gamepad_init();

        //init(sound_player, xx window, true, true);
        
        assets_init();
        map_init();

        scene_title_init();
    }

    game_set_scene(.SPLASH);
    
    time_prev = seconds_since_init();

    //audio_update();

    while !should_quit_game {
        reset_temporary_storage();
        
        update_window_events();
        gamepad_update();

        //audio_update();

        // @Incomplete: Handle resizes in the actual scene drawing, which we currently don't.
        for get_window_resizes() {
            Simp.update_window(it.window);
            if it.window == window {
                should_reinit := (it.width != window_width) || (it.height != window_height);
                
                window_width  = it.width;
                window_height = it.height;
            }
        }
        
        for event : events_this_frame {
            if event.type == {
                case .QUIT; {
                    should_quit_game = true;
                    break;
                }
                case .KEYBOARD; {
                    input_handle_keyboard_event(event);
                }   
            }
        }        

        input_handle_gamepad();

        // delta time
        {
            time_current := seconds_since_init();
            time_delta = xx (time_current - time_prev);
            time_prev = time_current; 
        }

        if current_scene == {
            case .GAME; scene_game_update();
            case .TITLE; scene_title_update();
            case .SPLASH; scene_splash_update();
        }

        render();
        
        input_frame_end();
        Simp.swap_buffers(window);
        frame_count += 1;
    }
}

#scope_file

render :: () {
    border_color :: Vector4.{8 / 255.0, 8 / 255.0, 8 / 255.0, 1};

    // render surf
    {
        Simp.set_render_target(*pixel_surf);
        Simp.clear_render_target(pal[0].x, pal[0].y, pal[0].z, pal[0].w);

        if current_scene == {
            case .GAME; scene_game_render();
            case .TITLE; scene_title_render();
            case .SPLASH; scene_splash_render();
        }

        // Draw border, necessary for curvature effect
        draw_sprite(.FADE_SOLID, .{0, 0, 1, game_height}, border_color);
        draw_sprite(.FADE_SOLID, .{game_width - 1, 0, 1, game_height}, border_color);
        draw_sprite(.FADE_SOLID, .{0, 0, game_width, 1}, border_color);
        draw_sprite(.FADE_SOLID, .{0, game_height - 1, game_width, 1}, border_color);

        Simp.immediate_flush();
    }

    Simp.set_render_target(window);
    Simp.clear_render_target(border_color.x, border_color.y, border_color.z, border_color.w);

    // Calculate render width / height and offsets based on 16:9 aspect requirement
    render_width := window_width;
    render_height := window_height;
    x_offset := 0;
    y_offset := 0;

    target_ratio :: 16.0 / 9.0;
    actual_ratio := cast(float)window_width / cast(float)window_height;

    if actual_ratio < target_ratio {
        // Too tall, bars on top and bottom
        render_height = cast(s32)(cast(float)window_width * (9.0 / 16.0));
        y_offset = (window_height - render_height) / 2;
    }
    else if actual_ratio > target_ratio {
        // Too wide, bars on left and right
        render_width = cast(s32)(cast(float)window_height * (16.0 / 9.0));
        x_offset = (window_width - render_width) / 2;
    }

    // present
    {
        // setup
        {
            Simp.immediate_flush();
            immediate_set_shader(*shader_present);

            texture_size_loc := glGetUniformLocation(shader_present.gl_handle, "texture0Size");
            glUniform2f(texture_size_loc, xx game_width, xx game_height);

            screen_native_size_loc := glGetUniformLocation(shader_present.gl_handle, "screenNativeSize");
            glUniform2f(screen_native_size_loc, xx render_width, xx render_height);

            set_projection();
            immediate_set_texture(*pixel_surf);

            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
        }

        Simp.immediate_begin();

        top := render_height + y_offset;
        right := render_width + x_offset;

        Simp.immediate_quad(
            Vector2.{xx x_offset, xx top}, 
            Vector2.{xx right, xx top}, 
            Vector2.{xx right, xx y_offset}, 
            Vector2.{xx x_offset, xx y_offset});

        Simp.immediate_flush();
    }
}
