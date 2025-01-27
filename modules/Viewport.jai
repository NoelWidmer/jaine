#import "Window_Creation";
#import "Camera";
#import "World";
#import "History";
#import "Math";
#import "Input";
#import "Simp";
#import "input_handler";

quit : bool;

Viewport :: struct {
    window : Window_Type;

    is_fullscreen : bool;
    prev_info : Saved_Window_Info;

    screen_size : Vector32s;
    world_size: Vector2;

    pointer : MousePointerState;
    left_mouse_button : MouseButtonState;
    right_mouse_button : MouseButtonState;

    shift : bool;
    ctrl : bool;
}

MouseButtonState :: struct {
    pressed : bool;
    pressed_this_frame : bool;
    pressed_screen_pos : Vector2;
    pressed_world_pos : Vector2;
    is_grab : bool;
    released_this_frame : bool;
}

MousePointerState :: struct {
    last_screen_pos : Vector2;

    screen_pos : Vector2;
    pointer_world_pos : Vector2;

    screen_delta : Vector2;
}

new_viewport :: () -> Viewport {
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

update_viewport :: (vp: *Viewport, cam: *Camera, world: *World, history: *History) {
    update_window_events();

    for get_window_resizes() {
        update_window(it.window);
        
        if it.window == vp.window then on_viewport_size_changed(vp, it.width, it.height);
    }

    vp.left_mouse_button.pressed_this_frame = false;
    vp.left_mouse_button.released_this_frame = false;

    vp.right_mouse_button.pressed_this_frame = false;    
    vp.right_mouse_button.released_this_frame = false;
    
    invalidate_pointer_screen_pos(vp, cam);
        
    for events_this_frame {
        type := it.type;

        if type == {
            case .QUIT; quit = true;
            case .KEYBOARD;
            {
                if it.repeat return;        

                key := it.key_code;
                
                if key == .F11 {
                    if it.key_pressed && toggle_fullscreen(vp) then invalidate_pointer_screen_pos(vp, cam);
                } else if key == .ESCAPE {
                    quit = true;
                } else if key == .MOUSE_BUTTON_LEFT {
                    on_mouse_left(vp, cam, world, history, it);
                } else if key == .MOUSE_BUTTON_RIGHT {
                    on_mouse_right(vp, cam, it);
                } else if key == xx #char "A" {
                    on_a(vp, cam, world, history, it);
                } else if key == xx #char "T" {
                    on_tool(cam, it);
                } else if key == xx #char "X" {
                    on_global_local(cam, it);
                } else if key == xx #char "Z" {
                    on_history(vp, cam, world, history, it);
                } else if key == .DELETE {
                    on_delete(cam, world, history, it);
                } else if key == .SHIFT {
                    on_shift(vp, it);
                } else if key == .CTRL {
                    on_ctrl(vp, it);
                }
            }
        }            
    }
    
    consider_begin_grab(*vp.left_mouse_button, vp);
    consider_begin_grab(*vp.right_mouse_button, vp);
}

#scope_file

min_drag_distance :: 10;

Vector32s :: struct {
    x : s32;
    y : s32;
}

consider_begin_grab :: (sate: *MouseButtonState, vp: *Viewport) {
    if sate.pressed && !sate.is_grab {
        drag_vec := vp.pointer.screen_pos - sate.pressed_screen_pos;
        if length(drag_vec) > min_drag_distance then sate.is_grab = true;
    }
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
    
    // TODO here we need to consider zoom once we add that.
    vp.world_size = .{ xx width, xx height };
}

invalidate_pointer_screen_pos :: (vp: *Viewport, cam: *Camera) {
    if !input_application_has_focus then return;
    
    x, y, success := get_mouse_pointer_position(vp.window, true);

    if success {
        vp.pointer.last_screen_pos = vp.pointer.screen_pos;
        vp.pointer.screen_pos = Vector2.{ xx x, xx y };

        if vp.pointer.screen_pos == vp.pointer.last_screen_pos {
            vp.pointer.screen_delta = .{ 0, 0 };
        } else {
            vp.pointer.screen_delta = vp.pointer.screen_pos - vp.pointer.last_screen_pos;
            vp.pointer.pointer_world_pos = screen_to_world_pos(cam, vp.pointer.screen_pos);
        }
    }
}