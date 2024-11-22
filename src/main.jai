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

#load "PositionHandle2.jai";
#load "draw.jai";
#load "camera.jai";
#load "window.jai";
#load "pointer.jai";
#load "Entity.jai";
#load "selection.jai";
#load "input_handler.jai";
#load "math.jai";

main :: () {   
    { // aquire sdl version.
        sdl_version : SDL_version;
        SDL_GetVersion(*sdl_version);
        print("Using SDL %.%.%\n", sdl_version.major, sdl_version.minor, sdl_version.patch);
    }

    create_window();

    time_prev = seconds_since_init();

    while !quit { // main game loop
        reset_temporary_storage();    
        pre_render_window();
        maybe_drag();
        invalidate_viewport();

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

#scope_file

quit : bool;

frame_count : int;
time_prev : float64;
time_delta : float;

render :: () {
    { // clear
        background_color :: Vector4.{ .1, .1, .2, 1};
        Simp.clear_render_target(background_color.x, background_color.y, background_color.z, background_color.w);
    }

    Simp.set_shader_for_color();

    draw_entities();
    draw_selection_handle();
}
