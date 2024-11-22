#import "GetRect";

try_select_entity :: () -> bool {
    for entities {
        rect := get_entity_rect(it);

        if is_inside(pointer_world_pos.x, pointer_world_pos.y, rect) {
            if selected == it_index {
                selected = -1;
            } else {
                selected = it_index;
                invalidate_handle();
            }

            return true;
        }
    }

    return false;
}

delete_selected_entity :: (ev: Event) {
    if ev.key_pressed || selected == -1 then return;
    despawn_entity(selected);
    selected = -1;
}

draw_selection_handle :: () {
    if selected == -1 return;

    invalidate_handle();
    draw_handle(handle);
}

maybe_interact_with_selection_handle :: () {
    if selected == -1 return;
    // TODO
}

#scope_file

selected : s64 = -1;
handle : PositionHandle2;

invalidate_handle :: () {
    entity := entities[selected];
    handle = new_handle(entity.pos, .{ 1, 0 });
}
