#import "Basic";

#import "functional";
#import "test";

main :: () {
    #if RUN_TESTS_AT_RUN_TIME {
        run_tests();
    } else {
        run_program();
    }
}

run_tests :: () {
    inner();

    inner :: () {
        if #compile_time {
            #insert #code print("inserted\n");
        }
    }
}

run_program :: () {
    print("\npointer tests:\n");
    pointer_none := None(*string);
    print_result(0, pointer_none);

    pointer_some := Some(*"test");
    print_result(1, pointer_some);

    print("\ninteger tests:\n");
    int_none := None(int);
    print_result(2, int_none);

    int_some := Some(42);
    print_result(3, int_some);

    print("\nmap tests:\n");
    int_none_mapped := map(int_none, v => v + 8);
    print_result(4, int_none_mapped);

    int_some_mapped := map(int_some, v => v + 8);
    print_result(5, int_some_mapped);
}

print_result :: (test_number: u8, option: Option($T)) {
    print("test %: option of % requires % bytes and", test_number, type_info(T).type, size_of(type_of(option)));

    if is_some(option) {
        print(" contains %\n", option.value);
    } else {
        print(" is empty\n");
    }
}
