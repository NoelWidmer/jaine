CircularStack :: struct(T: Type) {
    items: [50]T;
    next_index: u32;
    count: u32;
}

new_circular_stack :: ($T: Type) -> CircularStack(T) {
    items: [50]T;

    return .{
        items,
        0,
        0
    };
}

push :: (stack: *CircularStack($T), event: T) {
    stack.items[stack.next_index] = event;

    if stack.count < stack.items.count then stack.count += 1;

    next_index := stack.next_index + 1;
    stack.next_index = ifx next_index == stack.items.count 
        then 0 
        else next_index;
}

pop :: (stack: *CircularStack($T)) -> *T {
    if stack.count == 0 return null;
    stack.count -= 1;

    current_index := get_current_index(stack);
    stack.next_index = current_index;

    return *stack.items[current_index];
}

peek :: (stack: *CircularStack($T)) -> *T {
    if stack.count == 0 return null;
    current_index := get_current_index(stack);
    return *stack.items[current_index];
}

peek_at :: (stack: *CircularStack($T), index: u32) -> *T {
    if stack.count <= index return null;

    current_index := get_current_index(stack);
    target_index: u32;

    if index > current_index {
        target_index = stack.items.count - index + current_index;
    } else {
        target_index = current_index - index;
    }

    return *stack.items[target_index];
}

#scope_file

get_current_index :: (stack: *CircularStack($T)) -> u32 {
    next_index := stack.next_index;

    return ifx next_index == 0 
        then stack.items.count - 1 
        else next_index - 1;
}

/*
// test
#run {
    stack := new_circular_stack(s64);
    
    assert(stack.count == 0);
    assert(stack.next_index == 0);
    assert(stack.items.count == 50);
    assert(peek(*stack) == null);

    for 1..30 {
        push(*stack, xx it);
        
        assert(stack.count == it);
        assert(stack.next_index == it);
    }

    assert(stack.items.count == 50);
    assert(<<peek(*stack) == 30);

    for 31..60 {
        push(*stack, xx it);
        
        assert(stack.count == it);
        assert(stack.next_index == it);
    }

    assert(stack.count == 50);
    assert(stack.next_index == 10);
    assert(stack.items.count == 50);
    assert(<<peek(*stack) == 60);
    
    for 60..31 {
        pop(*stack);
    }
}*/