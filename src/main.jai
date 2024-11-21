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

    on_window_size_changed();
    Simp.set_render_target(window);
    
    // setup time
    {
        time_prev = seconds_since_init();
        time_delta = 0;
    }

    while !quit {
        reset_temporary_storage();
        update_window_events();

        for get_window_resizes() {
            Simp.update_window(it.window);
            
            if it.window == window {
                window_width = it.width;
                window_height = it.height;
                on_window_size_changed();
            }
        }

        invalidate_pointer_screen_position();
        
        for events_this_frame {
            type := it.type;

            if type == {
                case .QUIT; quit = true;
                case .KEYBOARD;  handle_keyboard_event(it); 
            }            
        }

        consider_drag();

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

is_fullscreen := false;
window_width : s32 = 1920 / 2;
window_height : s32 = 1080 / 2;

screen_size : Vector2;
screen_bottom_left : Vector2;

cam_pos : Vector2;

on_window_size_changed :: () {
    screen_size = .{ xx window_width, xx window_height };
    invalidate_bottom_left();
}

background_color :: Vector4.{201 / 255.0, 17 / 255.0, 69 / 255.0, 1};

frame_count : int = 0;
time_prev : float64;
time_delta : float;

pointer_world_pos : Vector2;
pointer_screen_pos : Vector2;
last_pointer_screen_pos : Vector2;
pointer_screen_delta : Vector2;

handle_keyboard_event :: (ev: Event) {
    if ev.repeat return;

    key := ev.key_code;

    if key == .F11 {
        if ev.key_pressed then toggle_fullscreen();
    } else if key == .MOUSE_BUTTON_LEFT {
        if !ev.key_pressed then spawn_entity();
    } else if key == .MOUSE_BUTTON_RIGHT {
        on_mouse_right(ev);
    }
}

toggle_fullscreen :: () {
    new_state := !is_fullscreen;
    success, window_width, window_height := toggle_fullscreen(window, new_state, *prev_window_info);
    if success then is_fullscreen = new_state;
}

invalidate_pointer_screen_position :: () {
    if input_application_has_focus {
        x, y, success := get_mouse_pointer_position(window, true);

        if success {
            last_pointer_screen_pos = pointer_screen_pos;
            pointer_screen_pos = Vector2.{ xx x, xx y };
            pointer_screen_delta = pointer_screen_pos - last_pointer_screen_pos;

            pointer_world_pos = pointer_screen_pos + screen_bottom_left;

            //if pointer_screen_delta.x > 0 || pointer_screen_delta.y > 0 then print("%: %x/%y\n", frame_count, pointer_screen_delta.x, pointer_screen_delta.y);
        }
    }
}

entity_size :: Vector2.{ 20, 20 };
entity_size_half :: Vector2.{ 10, 10 };

Entity :: struct {
    pos: Vector2;
}

entities : [..]Entity;

spawn_entity :: () {
    entity : Entity = .{
        pos = pointer_world_pos
    };

    array_add(*entities, entity);
}

min_drag_distance :: 10;
is_right_mouse_pressed := false;
drag_start_pos : Vector2;
is_drag := false;

on_mouse_right :: (ev: Event) {
    if ev.key_pressed {
        is_right_mouse_pressed = true;
        drag_start_pos = pointer_screen_pos;
    } else { // key released
        is_right_mouse_pressed = false;
        if is_drag {
             is_drag = false;
        } else {
             despawn_entity();
        }
    }
}

consider_drag :: () {
    if !is_right_mouse_pressed then return;

    if is_drag {
        drag();
    } else {
        drag_vec := pointer_screen_pos - drag_start_pos;

        if length(drag_vec) >= min_drag_distance {
            is_drag = true;
            drag();
        }
    }
}

drag :: () {
    cam_pos = cam_pos - pointer_screen_delta;
    invalidate_bottom_left();
}

invalidate_bottom_left :: () {
    screen_bottom_left = cam_pos - screen_size * .5;
    print("%\n", screen_bottom_left);
}

despawn_entity :: () {
    despawned_count := 0;

    for 0..entities.count - 1 {
        entity_index := it - despawned_count;
        entity := entities[entity_index];

        if overlaps_aabb(entity, pointer_world_pos) {
            array_unordered_remove_by_index(*entities, entity_index);
            despawned_count += 1;
        }
    }
}

overlaps_aabb :: (entity: Entity, point: Vector2) -> bool {
    pos := entity.pos;

    bottom_left := pos - entity_size_half;
    if point.x < bottom_left.x || point.y < bottom_left.y {
        return false;
    }
    
    top_right := pos + entity_size_half;
    return point.x < top_right.x && point.y < top_right.y;
}

render :: () {
    Simp.clear_render_target(background_color.x, background_color.y, background_color.z, background_color.w);
    Simp.set_shader_for_color();

    for entities {
        screen_size : Vector2 = .{ xx window_width, xx window_height };
        screen_bottom_left := cam_pos - screen_size * .5;

        pos := it.pos - screen_bottom_left;

        Simp.immediate_quad(
            pos + .{ -entity_size_half.x, -entity_size_half.y }, 
            pos + .{ entity_size_half.x, -entity_size_half.y }, 
            pos + .{ entity_size_half.x, entity_size_half.y }, 
            pos + .{ -entity_size_half.x, entity_size_half.y });
    }
}
