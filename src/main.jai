#import "Basic"; //()(MEMORY_DEBUGGER=true);
#import "Math";
#import "Window_Creation";
#import "Input";
#import "Tagged_Union";

#load "Gizmos/gizmo.jai";
#load "Gizmos/PositionalGizmo.jai";
#load "Gizmos/RotationalGizmo.jai";

#load "draw.jai";
#load "camera.jai";
#load "window.jai";
#load "pointer.jai";
#load "Entity.jai";
#load "selection.jai";
#load "input_handler.jai";
#load "math.jai";
#load "tool.jai";
#load "res.jai";
#load "CircularStack.jai";
#load "history.jai";

main :: () {
    create_window();
    load_res();

    history = begin_history(HistoricalEvent);
    last_time = seconds_since_init();

    while !quit {
        reset_temporary_storage();   
         
        update_window();
        update_input();
        update_viewport();

        // render
        {
            {
                background_color :: Vector3.{ .1, .1, .2 };
                Simp.clear_render_target(background_color.x, background_color.y, background_color.z, 1);
            }

            draw_entities();    
            draw_selection_gizmo();
        }

        Simp.swap_buffers(window);
        
        // update time
        {
            current_time := seconds_since_init();
            delta_time = xx (current_time - last_time);
            last_time = current_time; 
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
last_time : float64;
delta_time : float;
