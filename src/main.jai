#import "Basic"; //()(MEMORY_DEBUGGER=true);
#import "Math";
#import "Window_Creation";
#import "Input";

#load "PositionalGizmo.jai";
#load "RotationalGizmo.jai";
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
#load "CircularStack.jai";

HistoricalEvent :: struct {
    index: u32;
}

main :: () {
    create_window();
    load_res();

    circular_stack := new_circular_stack(HistoricalEvent);

    for 0..105 {
        print("%\n", it);
        push(*circular_stack, .{ index = xx it });
    }
    
    for 0..30 {
        pop(*circular_stack);
    }

    last := peek(*circular_stack);

    if last == null {
        print("null");
    } else {
        print("%\n", <<last);
    }

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
