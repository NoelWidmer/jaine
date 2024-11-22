PositionHandle2 :: struct {
    pos: Vector2;
    tri_x: Tri;
    tri_y: Tri;
    quad_xy: Quad;
}

new_handle :: (pos: Vector2, dir_x: Vector2) -> PositionHandle2 {
    dir_y := rotate_dir_90_deg_ccw(dir_x);

    tri_x : Tri = ---;
    {
        base := pos + dir_x * handle_length;
        offset := dir_y * handle_arrow_half_width;

        tri_x = .{
            base + dir_x * handle_arrow_height,
            base + offset,
            base - offset,
        };
    }

    tri_y : Tri = ---;
    {
        base := pos + dir_y * handle_length;
        offset := dir_x * handle_arrow_half_width;

        tri_y = .{
            base + dir_y * handle_arrow_height,
            base + offset,
            base - offset,
        };
    }

    quad_xy : Quad = ---;
    {
        v1_offset := handle_half_length - handle_arrow_half_height;
        v1 := pos + dir_x * v1_offset + dir_y * v1_offset;

        v2 := Vector2.{ v1.x + handle_arrow_height, v1.y };

        v3_v4_offset := dir_y * handle_arrow_height;

        quad_xy = .{ 
            v1, 
            v2, 
            v2 + v3_v4_offset, 
            v1 + v3_v4_offset
        };
    }

    return .{
        pos,
        tri_x,
        tri_y,
        quad_xy
    };
}

draw_handle :: (handle: PositionHandle2) {
    pos := handle.pos;

    // x
    {
        color : Vector4 = .{ 1, 0, 0, 1 };
        
        draw_rect(
            .{ pos.x - .25 + handle_half_length, pos.y }, 
            .{ handle_length + .5, 1 }, 
            color);
        
        draw_tri_raw(handle.tri_x, color);
    }
    
    // y
    {
        color : Vector4 = .{ 0, 1, 0, 1 };

        draw_rect(
            .{ pos.x, pos.y + .25 + handle_half_length }, 
            .{ 1, handle_length - .5 }, 
            color);
            
        draw_tri_raw(handle.tri_y, color);
    }

    // xy
    draw_quad_raw(handle.quad_xy, .{ 0, 0, 1, .25 });
}

overlaps_asd :: (handle: PositionHandle2) -> bool {
    return is_inside_quad(pointer_world_pos, handle.quad_xy);
}

#scope_file

handle_length :: 100;
handle_arrow_height :: 20;

handle_half_length :: handle_length * .5;
handle_arrow_half_height :: handle_arrow_height * .5;
handle_arrow_width :: handle_arrow_height * .75;
handle_arrow_half_width :: handle_arrow_width * .5;
