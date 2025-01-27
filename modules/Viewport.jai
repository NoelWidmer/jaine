#import "Window_Creation";
#import "Camera";
#import "World";
#import "History";
#import "Math";
#import "Input";
#import "Selection";
#import "Tagged_Union";

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

    quit: bool;
}

MouseButtonState :: struct {
    pressed : bool;
    pressed_this_frame : bool;
    pressed_screen_pos : Vector2;
    pressed_world_pos : Vector2;
    is_drag : bool;
    released_this_frame : bool;
}

MousePointerState :: struct {
    last_screen_pos : Vector2;

    screen_pos : Vector2;
    world_pos : Vector2;

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
    vp.left_mouse_button.pressed_this_frame = false;
    vp.left_mouse_button.released_this_frame = false;

    vp.right_mouse_button.pressed_this_frame = false;    
    vp.right_mouse_button.released_this_frame = false;
    
    invalidate_pointer(vp, cam);
        
    for events_this_frame {
        type := it.type;

        if type == {
            case .QUIT; vp.quit = true;
            case .KEYBOARD;
            {
                if it.repeat return;
                key := it.key_code;
                
                if key == .F11 {
                    if it.key_pressed && toggle_fullscreen(vp) then invalidate_pointer(vp, cam);
                } else if key == .ESCAPE {
                    vp.quit = true;
                } else if key == .MOUSE_BUTTON_LEFT {
                    on_mouse_button(*vp.left_mouse_button, vp, cam, it);
                } else if key == .MOUSE_BUTTON_RIGHT {
                    on_mouse_button(*vp.right_mouse_button, vp, cam, it);
                } else if key == xx #char "A" {
                    if it.key_pressed && vp.shift then add_entity(vp, *cam.selection, world, history);
                } else if key == xx #char "T" {
                    if it.key_pressed then switch_tool(cam);
                } else if key == xx #char "X" {
                    if it.key_pressed then cam.is_global = !cam.is_global;
                } else if key == xx #char "Z" {
                    if it.key_pressed then on_history(vp, cam, world, history);
                } else if key == .DELETE {
                    if it.key_pressed then delete_selected(cam, world, history);
                } else if key == .SHIFT {
                    vp.shift = ifx it.key_pressed then true else false;
                } else if key == .CTRL {
                    vp.ctrl = ifx it.key_pressed then true else false;
                }
            }
        }            
    }
    
    consider_begin_drag(*vp.left_mouse_button, vp);
    consider_begin_drag(*vp.right_mouse_button, vp);
}

on_viewport_size_changed :: (vp: *Viewport, width: s32, height: s32) {
    vp.screen_size = .{ width, height };
    
    // TODO here we need to consider zoom once we add that.
    vp.world_size = .{ xx width, xx height };
}

#scope_file

Vector32s :: struct {
    x : s32;
    y : s32;
}

on_mouse_button :: (state: *MouseButtonState, vp: *Viewport, cam: *Camera, ev: Event) {
    if ev.key_pressed {
        state.pressed = true;
        state.pressed_this_frame = true;

        state.pressed_screen_pos = vp.pointer.screen_pos;
        state.pressed_world_pos = screen_to_world_pos(cam, vp.pointer.screen_pos);
    } else {
        state.released_this_frame = true;
        state.pressed = false;
        state.is_drag = false;
    }
}

add_entity :: (vp: *Viewport, selection: *Selection, world: *World, history: *History) {
    entity := add_entity(world);
    entity.pos = vp.pointer.world_pos;
        
    // history
    {
        event : HistoricalEvent;
        set(*event, AddedHistoryEvent.{ entity.id });
        record(history, event);
    }

    select_entity(selection, history, entity);
}

consider_begin_drag :: (sate: *MouseButtonState, vp: *Viewport) {
    min_drag_distance :: 10;

    if sate.pressed && !sate.is_drag {
        drag_vec := vp.pointer.screen_pos - sate.pressed_screen_pos;
        if length(drag_vec) > min_drag_distance then sate.is_drag = true;
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

invalidate_pointer :: (vp: *Viewport, cam: *Camera) {
    if !input_application_has_focus then return;
    
    x, y, success := get_mouse_pointer_position(vp.window, true);
    if !success then return;

    vp.pointer.last_screen_pos = vp.pointer.screen_pos;
    vp.pointer.screen_pos = Vector2.{ xx x, xx y };

    if vp.pointer.screen_pos == vp.pointer.last_screen_pos {
        vp.pointer.screen_delta = .{ 0, 0 };
    } else {
        vp.pointer.screen_delta = vp.pointer.screen_pos - vp.pointer.last_screen_pos;
        vp.pointer.world_pos = screen_to_world_pos(cam, vp.pointer.screen_pos);
    }
}