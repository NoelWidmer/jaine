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

#load "PositionHandle2.jai";
#load "draw.jai";
#load "world.jai";
#load "window.jai";
#load "pointer.jai";

main :: () {   
    { // aquire sdl version.
        sdl_version : SDL_version;
        SDL_GetVersion(*sdl_version);
        print("Using SDL %.%.%\n", sdl_version.major, sdl_version.minor, sdl_version.patch);
    }

    create_window();

    time_prev = seconds_since_init();

    while !quit { // main game loop
        pre_render();
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

quit :: () {
    quit = true;
}

handle_keyboard_event :: (ev: Event) {
    if ev.repeat return;

    key := ev.key_code;

    if key == .F11 {
        if ev.key_pressed {
            toggle_fullscreen();
            invalidate_pointer_screen_position();
        }
    } else if key == .MOUSE_BUTTON_LEFT {
        on_mouse_left(ev);
    } else if key == .MOUSE_BUTTON_RIGHT {
        on_mouse_right(ev);
    } else if key == .DELETE {
        on_delete(ev);
    }
}

#scope_file

quit : bool;

frame_count : int;
time_prev : float64;
time_delta : float;

pre_render :: () {
    reset_temporary_storage();    
    pre_render_window();
    maybe_drag();
    invalidate_viewport();
}

is_right_mouse_pressed := false;
min_drag_distance :: 10;
is_drag := false;
drag_start_pos : Vector2;

maybe_drag :: () {
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
    move_camera(-pointer_delta);
}

entities : [..]Entity;
selected : s64 = -1;

entity_size :: Vector2.{ 20, 20 };
entity_size_half :: Vector2.{ 10, 10 };

Entity :: struct {
    pos: Vector2;
}

on_mouse_left :: (ev: Event) {
    if ev.key_pressed then return;
    if !try_select_entity() then spawn_entity();
}

try_select_entity :: () -> bool {
    for entities {
        if overlaps_aabb(it, pointer_world_pos) {
            if selected == it_index {
                selected = -1;
            } else {
                selected = it_index;
            }

            return true;
        }
    }

    return false;
}

spawn_entity :: () {
    entity : Entity = .{
        pos = pointer_world_pos
    };

    array_add(*entities, entity);
}

on_delete :: (ev: Event) {
    if ev.key_pressed || selected == -1 then return;
    array_unordered_remove_by_index(*entities, selected);
    selected = -1;
}

on_mouse_right :: (ev: Event) {
    if ev.key_pressed {
        is_right_mouse_pressed = true;
        drag_start_pos = pointer_screen_pos;
    } else { // key released
        is_right_mouse_pressed = false;
        if is_drag {
            is_drag = false;
        } // else show context menu
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
    { // clear
        background_color :: Vector4.{201 / 255.0, 17 / 255.0, 69 / 255.0, 1};
        Simp.clear_render_target(background_color.x, background_color.y, background_color.z, background_color.w);
    }

    Simp.set_shader_for_color();

    for entities {
        draw_rect(it.pos, entity_size, .{ 1, 1, 1, 1 });
    }

    // consider_drawing_handle
    {
        if selected == -1 return;

        entity := entities[selected];
        handle : PositionHandle2 = .{ entity.pos };
        draw_handle(handle);
    }
}
