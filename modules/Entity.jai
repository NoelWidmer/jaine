#import "Basic";
#import "Bucket_Array";
#import "Mathe";
#import "Hash_Table";
#import "Math";
#import "Simp";
#import "draw";
#import "Camera";

Entity :: struct {
    locator: Bucket_Locator;
    id: u64;

    pos: Vector2;
    theta: float;
}

get_entity_up :: (entity: Entity) -> Vector2 {
    global_up :: Vector2.{ 0, 1 };
    if entity.theta == 0 return global_up;
    return rotate_by_deg(global_up, entity.theta);
}

get_entity_right :: (entity: Entity) -> Vector2 {
    global_right :: Vector2.{ 1, 0 };
    if entity.theta == 0 return global_right;
    return rotate_by_deg(global_right, entity.theta);
}

get_entity_quad :: (entity: Entity) -> Quad {
    up_dir := get_entity_up(entity);
    right_dir := get_entity_right(entity);

    size := get_entity_size(entity);
    size_half := size * .5;

    up_offset := up_dir * size.y;

    v1 := entity.pos - up_dir * size_half.y - right_dir * size_half.x;
    v2 := v1 + right_dir * size.x;
    v3 := v2 + up_offset;
    v4 := v1 + up_offset;

    return .{ v1, v2, v3, v4 };
}

draw_entity :: (cam: *Camera, entity: Entity) {
    tex := get_texture();
    set_shader_for_images(*tex);

    if entity.theta == 0 {
        size := get_entity_size(entity);
        draw_world_rect(cam, entity.pos, size);
    } else {
        uv :: Quad.{
            .{ 0, 0 },
            .{ 1, 0 },
            .{ 1, 1 },
            .{ 0, 1 }
        };

        quad := get_entity_quad(entity);
        draw_world_quad_with_uv(cam, quad, uv);
    }
}

#scope_file

get_texture :: () -> Texture {
    t : Texture;
    texture_load_from_file(*t, "res/strawberry.png");
    return t;
}

get_entity_size :: (entity: Entity) -> Vector2 {
    tex := get_texture();
    return .{ xx (tex.width * 2), xx (tex.height * 2) };
}
