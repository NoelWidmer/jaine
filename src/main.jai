#import "Basic"; //()(MEMORY_DEBUGGER=true);
#import "Viewport";
#import "Camera";
#import "World";
#import "History";
#import "Input";
#import "Simp";

main :: () {
    vp := new_viewport();

    cam := new_camera();
    cam.render_target = *vp;

    world := new_world();
    history := new_history(HistoricalEvent);

    last_time = seconds_since_init();

    while !vp.quit {
        reset_temporary_storage();   
         
        update_window_events();

        for get_window_resizes() {
            update_window(it.window);            
            if it.window == vp.window then on_viewport_size_changed(*vp, it.width, it.height);
        }

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
