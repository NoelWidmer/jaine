#import "Basic"; //()(MEMORY_DEBUGGER=true);

#import "input_handler";
#import "Selection";
#import "Camera";
#import "History";
#import "Viewport";
#import "World";

main :: () {
    vp := new_viewport();

    cam := new_camera();
    cam.render_target = *vp;

    world := new_world();
    history := new_history(HistoricalEvent);

    last_time = seconds_since_init();

    while !quit {
        reset_temporary_storage();   
         
        update_viewport(*vp, *cam, *world, *history);
        update_cam(*vp, *cam, *history, *world);

        render(*cam, *world);
        
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

last_time : float64;
delta_time : float;
frame_count : u64;
