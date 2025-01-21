#import "Basic";
#import "CircularStack";
#import "Tagged_Union";
#import "Math";

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