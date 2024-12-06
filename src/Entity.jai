#import "GetRect";

entities : [..]Entity;

Entity :: struct {
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

spawn_entity :: () {
    entity : Entity = .{
        pos = pointer_world_pos
    };

    array_add(*entities, entity);
}

despawn_entity :: (index: s64) {
    array_unordered_remove_by_index(*entities, index);
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