#import "Bucket_Array";

World :: struct {
    entities : Bucket_Array(Entity, 128);
    entity_by_id : Table(u64, *Entity);
    next_id : u64;
}

new_world :: () -> World {
    return .{ };
}

add_entity :: (vp: *Viewport, cam: *Camera, world: *World) -> *Entity {
    locator, entity := bucket_array_add(*world.entities, .{
        id = world.next_id,
        pos = vp.pointer_world_pos
    });

    entity.locator = locator;
    table_add(*world.entity_by_id, world.next_id, entity);
    
    // record history
    
    world.next_id += 1;

    select_entity(cam, entity);
    return entity;
}

remove_entity :: (entity: *Entity, world: *World) {
    success, _ := table_remove(*world.entity_by_id, entity.id);
    assert(success, "could not remove an entity from the id lookup.");

    // record history
    bucket_array_remove(*world.entities, entity.locator);
}

draw_entities :: (cam: *Camera, world: *World) {
    color :: Vector4.{ 1, 1, 1, 1 };
    
    Simp.set_shader_for_images(*strawberry);

    for world.entities {
        if it.theta == 0 {
            size := get_entity_size();
            draw_world_rect(cam, it.pos, size);
        } else {
                uv :: Quad.{
                    .{ 0, 0 },
                    .{ 1, 0 },
                    .{ 1, 1 },
                    .{ 0, 1 }
                };

                quad := get_entity_quad(it);
                draw_world_quad_with_uv(cam, quad, uv);
            }
    }
}