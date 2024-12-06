History :: struct(T: Type) {
    events : CircularStack(T);
    undone_events : CircularStack(T);
}

HistoricalEvent :: struct {
    index: s32;
}

begin_history :: () -> History {
    return .{
        new_circular_stack(HistoricalEvent),
        new_circular_stack(HistoricalEvent)
    }
}

record :: (history *History($T), event: T) {
    push(*history.events, event);
}

undo :: (history *History($T)) -> *T {
    event := pop(*history.events);
    if event == null then return null;

    push(*history.undone_events, event);
    return event;
}

redo :: () -> *HistoricalEvent {
    event := pop(*undo_history);
    if event == null then return null;

    record_history(event);
    return event;
}

#scope_file

/*
#run {
    init_history();


}*/