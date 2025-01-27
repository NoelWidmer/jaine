#import "Basic";
#import "CircularStack";
#import "Tagged_Union";
#import "Math";
#import "Viewport";
#import "Camera";
#import "World";
#import "Selection";

History :: struct(T: Type) {
    events : CircularStack(T);
    undone_events : CircularStack(T);
}

HistoricalEvent :: Tagged_Union(
    PositionalHistoryEvent, 
    RotationalHistoryEvent,
    SelectedHistoryEvent,
    SelectionModifiedHistoryEvent,
    DeselectedHistoryEvent);

AddedHistoryEvent :: struct {
    entity_id: u64;
}

RemovedHistoryEvent :: struct {
    entity_id: u64;
}

PositionalHistoryEvent :: struct {
    entity_id: u64;
    delta: Vector2;
}

RotationalHistoryEvent :: struct {
    entity_id: u64;
    delta: float;
}

SelectedHistoryEvent :: struct {
    selected: u64;
}

SelectionModifiedHistoryEvent :: struct {
    prev_selected: u64;
    selected: u64;
}

DeselectedHistoryEvent :: struct {
    selected: u64;
}

new_history :: ($T: Type) -> History(T) {
    return .{
        new_circular_stack(T),
        new_circular_stack(T)
    };
}

record :: (history: *History($T), event: T) {
    push(*history.events, event);
}

undo :: (history: *History($T)) -> *T {
    event := pop(*history.events);
    if event == null then return null;

    push(*history.undone_events, event);
    return event;
}

redo :: (history: *History($T)) -> *T {
    event := pop(*history.undone_events);
    if event == null then return null;

    record(history, event);
    return event;
}

on_history :: (vp: *Viewport, cam: *Camera, world: *World, history: *History) {
    if !vp.ctrl then return;
    
    event := ifx vp.shift
        then redo(history)
        else undo(history);

    if event == null return;

    added := isa(event, AddedHistoryEvent);
    if added {
        undo(added, !vp.shift, world);
        return;
    }

    removed := isa(event, RemovedHistoryEvent);
    if removed {
        undo(removed, !vp.shift, world);
        return;
    }

    positional := isa(event, PositionalHistoryEvent);
    if positional {
        undo(positional, !vp.shift, world);
        return;
    }
    
    rotational := isa(event, RotationalHistoryEvent);
    if rotational {
        undo(rotational, !vp.shift, world);
        return;
    }
    
    selectional := isa(event, SelectedHistoryEvent);
    if selectional {
        undo(cam, selectional, !vp.shift, world);
        return;
    }
    
    selection_modified := isa(event, SelectionModifiedHistoryEvent);
    if selection_modified {
        undo(cam, selection_modified, !vp.shift, world);
        return;
    }
    
    deselectional := isa(event, DeselectedHistoryEvent);
    if deselectional {
        undo(cam, deselectional, !vp.shift, world);
        return;
    }
}

undo :: (event: AddedHistoryEvent, undo: bool, world: *World) {
    if undo then remove_(world, event.entity_id); else add();
}

undo :: (event: RemovedHistoryEvent, undo: bool, world: *World) {
    if undo then add(); else remove_(world, event.entity_id);
}

add :: () {
    // TODO: this requires the entity state to be recorded in the history.
}

remove_ :: (world: *World, entity_id: u64) {
    remove_entity(world, entity_id);
}

undo :: (event: PositionalHistoryEvent, undo: bool, world: *World) {
    entity := get_entity(world, event.entity_id);
    assert(entity != null, "could not modify history for entity with id %", event.entity_id);
    entity.pos += ifx undo then -event.delta else event.delta;
}

undo :: (event: RotationalHistoryEvent, undo: bool, world: *World) {
    entity := get_entity(world, event.entity_id);
    assert(entity != null, "could not modify history for entity with id %", event.entity_id);
    entity.theta += ifx undo then -event.delta else event.delta;
}

#scope_file

TestEvent :: struct {
    name: string;
}

#run {
    history := new_history(TestEvent);
    assert(history.events.count == 0);
    assert(history.undone_events.count == 0);

    // record 1
    record(*history, .{ "1" });
    assert(peek(*history.events).name == "1");
    assert(history.undone_events.count == 0);

    // record 2
    record(*history, .{ "2" });
    assert(peek(*history.events).name == "2");
    assert(peek_at(*history.events, 1).name == "1");
    assert(history.undone_events.count == 0);

    // undo 2
    event2 := undo(*history);
    assert(event2.name == "2");
    assert(peek(*history.events).name == "1");
    assert(peek(*history.undone_events).name == "2");

    // undo 1
    event1 := undo(*history);
    assert(event1.name == "1");
    assert(history.events.count == 0);
    assert(peek(*history.undone_events).name == "1");
    assert(peek_at(*history.undone_events, 1).name == "2");

    // redo 1
    event01 := redo(*history);
    assert(event01.name == "1");
    assert(peek(*history.events).name == "1");
    assert(peek(*history.undone_events).name == "2");

    // redo 2
    event02 := redo(*history);
    assert(event02.name == "2");
    assert(peek(*history.events).name == "2");
    assert(peek_at(*history.events, 1).name == "1");
    assert(history.undone_events.count == 0);
}