PositionHandle2 :: struct {
    pos: Vector2;
}

draw_handle :: (handle: PositionHandle2) { // TODO direction parameter. for now this is axis-aligned.
    pos := handle.pos;

    // xy
    {
        pos_xy : Vector2 = .{ pos.x + .5 + handle_arrow_height * .5, pos.y + .5 + handle_arrow_height * .5 };
        draw_rect(pos_xy, .{ handle_arrow_height, handle_arrow_height }, .{ 0, 0, 1, .25 });
    }

    // x
    {
        color : Vector4 = .{ 1, 0, 0, 1 };
        
        draw_rect(
            .{ pos.x + handle_length * .5, pos.y }, 
            .{ handle_length, 1 }, 
            color);
        
        draw_tri(
            .{ pos.x + handle_length, pos.y }, 
            .{ handle_arrow_width, handle_arrow_height }, 
            .{ 1, 0 }, 
            color);
    }
    
    // y
    {
        color : Vector4 = .{ 0, 1, 0, 1 };

        draw_rect(
            .{ pos.x, pos.y + handle_length * .5 }, 
            .{ 1, handle_length }, 
            color);

        draw_tri(
            .{ pos.x, pos.y + handle_length }, 
            .{ handle_arrow_width, handle_arrow_height }, 
            .{ 0, 1 }, 
            color);
    }
}

#scope_file

handle_length :: 100;
handle_arrow_height :: 20;
handle_arrow_width :: handle_arrow_height * .75;