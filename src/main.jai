#import "Basic"; //()(MEMORY_DEBUGGER=true);

#import "Simp";

#import "input_handler";
#import "Selection";
#import "Camera";
#import "History";
#import "Viewport";
#import "World";
#import "res";

main :: () {
    load_res();

    vp := create_viewport();
    set_render_target(vp.window);

    cam := new_camera();
    world := new_world();
    history := new_history(HistoricalEvent);

    last_time = seconds_since_init();

    while !quit {
        reset_temporary_storage();   
         
        update_viewport(*vp, *cam, *world, *history);
        update_input(*vp, *cam);
        update_cam(*vp, *cam);

        // render frame
        {
            // paint over previous frame with background color
            {
                background_color :: struct { 
                    r :: .1; 
                    g :: .1; 
                    b :: .2;
                 };

                clear_render_target(background_color.r, background_color.g, background_color.b, 1);
            }

            draw_world(*cam, *world);
            draw_selection(*vp, *cam);
        }

        swap_buffers(vp.window);
        
        // update time
        {
            current_time := seconds_since_init();
            delta_time = xx (current_time - last_time);
            last_time = current_time; 
        }

        frame_count += 1;
    }
}

#scope_file

frame_count : int;
last_time : float64;
delta_time : float;
