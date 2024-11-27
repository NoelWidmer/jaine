#import "Basic"; //()(MEMORY_DEBUGGER=true);
#import "Math";
#import "Window_Creation";
#import "Input";

#load "Vector2Gizmo.jai";
#load "ThetaGizmo.jai";
#load "draw.jai";
#load "camera.jai";
#load "window.jai";
#load "pointer.jai";
#load "Entity.jai";
#load "selection.jai";
#load "input_handler.jai";
#load "math.jai";
#load "tool.jai";
#load "gizmo.jai";
#load "res.jai";

main :: () {
    create_window();
    load_res();

    time_prev = seconds_since_init();

    while !quit {
        reset_temporary_storage();    
        update_window();
        update_input();
        invalidate_viewport_world_pos();

        // render
        {
            { // clear
                background_color :: Vector4.{ .1, .1, .2, 1};
                Simp.clear_render_target(background_color.x, background_color.y, background_color.z, background_color.w);
            }

            draw_entities();    
            draw_selection_gizmo();
        }

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

#scope_file

quit : bool;

frame_count : int;
time_prev : float64;
time_delta : float;
