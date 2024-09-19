#scope_file

reveal: float = ---;
done: bool = ---;

#scope_module

scene_splash_enter :: () {
    reveal = 0;
    done = false;
}

scene_splash_update :: () {
    if done then return;

    reveal += time_delta * 0.65;

    if reveal > 1 {
        reveal = 1; 
        done = true;

        game_set_scene(.TITLE);
    }
}

scene_splash_render :: () {    
    Simp.set_shader_for_images(*logo);
    Simp.immediate_begin(); 

    size : float = xx (game_height * 0.75);
    half_size = size * .5;

    x0 := (game_width / 2) - half_size;
    x1 := x0 + size;

    y0 := (game_height / 2) + half_size;
    y1 := y0 - size;
    
    Simp.immediate_quad(x0, y0, x1, y1, Vector4.{1, 1, 1, 1});
}

scene_splash_exit :: () {
    //audio_play_music("res/music_build.ogg", 0.5);
}
