#import "Basic";
#import "test";

// here we create an option data structure with the polymorphic type T.
// in c# you would use generics and write it like this: "struct Option<T> { }".
Option :: struct (T: Type) {
    value: T; // this is our potentially absent value.

    #insert -> string { // here we compute and insert code at compile time using the #insert directive.
        if is_pointer(T) {
            // which for example allows us to omit a member when it is not needed. 
            // this saves us x bytes per instance of this option (because the cpu uses an x byte alignment). x is very often 8 bytes.
            return "";
        }
        
        return "is_some: bool;";
    };
}

is_pointer :: ($T: Type) -> bool {
    // here we use introspection which in c# is known as reflection.
    // introspection (just like every other kind of code in jai) can run at compile time or at runtime.
    // whether we run at compile or run time is defined by the calling site.
    // in this file we only use introspection at compile time.
    // that means this code has zero cost at runtime (because it is never executed at runtime). 
    // which is awesome compared to the slow nature of reflection in .NET.
    return type_info(T).type == Type_Info_Tag.POINTER;
}

Some :: inline (value: $T) -> Option(T) { // $T is a polymophic function parameter. it's type is resolved at compile time.
    option : Option(T) = ---; // not initialized memory (because we don't want to waste time and initialize is_some to false when it really should be true).
    option.value = value;
        
    #if #run is_pointer(T) == false { // the #if directive is basically a regular if but it is evaluated at compile time.
        // we must be careful to only access is_some when that member actually exists (which is not the case for options containing pointers).
        // also: the #code directive transforms the next statement into an abstract syntax tree which can then be manipulated or inserted (as we do here).
        #insert #code option.is_some = true;
    }

    return option;
}

None :: inline ($T: Type) -> Option(T) { // jai is a language that gives the programmer full control. when we mark this function with inline it is guaranteed to be inlined.
    option : Option(T) = ---; // not initialized memory (because in this case there is no need to initialize the value of an option containing something else than a pointer).

    #if #run is_pointer(T) {
        #insert #code option.value = null; // this is how we mark an option as empty if it could contain a pointer.
    } else {
        #insert #code option.is_some = false; // this is how we mark an option as empty if it could contain anything but a pointer.
    }

    return option;
}

is_some :: inline (option: Option($T)) -> bool {
    #if #run is_pointer(T) {
        #insert #code return option.value != null;
    } else {
        #insert #code return option.is_some;
    }
}

// now we are done with all the compile time tricks for the option struct.
// any additional functions can simply call is_some(option) instead of 
// doing compile time hand stands to figure out whether the option actually contains a value.
// let's do an example:

is_none :: inline (option: Option($T)) -> bool {
    return !is_some(option);
}

// ok maybe one more example which is a bit more complicated.
// this function maps the content of an option to a value of any type and returns it as a new option.
// none will not be mapped.

map :: inline (option: Option($T), mapper: (T)->$R) -> Option(R) {
    if is_some(option) {
        mapped_value := mapper(option.value);
        return Some(mapped_value);
    }

    return None(R);
}

#run test("ensure case 1", () => {
    print("test 1 is running now\n");
});

#run test("ensure case 2", () => {
    print("test 2 is running now\n");
});