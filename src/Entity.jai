#import "GetRect";
#import "Bucket_Array";

entities : Bucket_Array(Entity, 128);

Entity :: struct {
    locator: Bucket_Locator;
    pos: Vector2;
    theta: float;
}

get_entity_size :: () -> Vector2 {
    return .{ xx (strawberry.width * 2), xx (strawberry.height * 2) };
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

    size := get_entity_size();
    size_half := size * .5;

    up_offset := up_dir * size.y;

    v1 := entity.pos - up_dir * size_half.y - right_dir * size_half.x;
    v2 := v1 + right_dir * size.x;
    v3 := v2 + up_offset;
    v4 := v1 + up_offset;

    return .{ v1, v2, v3, v4 };
}

spawn_entity :: () -> *Entity {
    locator, entity := bucket_array_add(*entities, .{
        pos = pointer_world_pos
    });

    entity.locator = locator;
    return entity;
}

despawn_entity :: (entity: *Entity) {
    bucket_array_remove(*entities, entity.locator);
}

draw_entities :: () {
    color :: Vector4.{ 1, 1, 1, 1 };
    
    Simp.set_shader_for_images(*strawberry);

    for entities {
        if it.theta == 0 {
            size := get_entity_size();
            draw_world_rect(it.pos, size);
        } else {
                uv :: Quad.{
                    .{ 0, 0 },
                    .{ 1, 0 },
                    .{ 1, 1 },
                    .{ 0, 1 }
                };

                quad := get_entity_quad(it);
                draw_world_quad_with_uv(quad, uv);
            }
    }
}