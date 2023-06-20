#import "Basic";

RUN_TESTS_AT_COMPILE_TIME :: false;
RUN_TESTS_AT_RUN_TIME :: true;

#no_reset tests : [2]u8;

test :: (name: string, func: ()->()) {
    if RUN_TESTS_AT_COMPILE_TIME {
        func();
    }

    if RUN_TESTS_AT_RUN_TIME {
        tests[0] = 99;
        //array_add(*tests, 99);
        print("added test: %\n", name);
    }
}

run_tests :: () {
    //print("about to run % tests ...\n", tests.count);
    
    print("about to run % tests.\n", tests.count);

    for tests {
        print("now running test %\n", it);
    }

    print("all tests ran\n");
}

//Q: how would I go about having a bunch of #run directives which add things do an array and then at runtime I would like to for array