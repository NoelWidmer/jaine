#import "Hash_Table";

Entity :: struct {
    locator: Bucket_Locator;
    id: u64;

    pos: Vector2;
    theta: float;
}

get_entity :: (world: *World, id: u64) -> *Entity {
    entity, success := table_find(*world.entity_by_id, id);
    return ifx success then entity else null;
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