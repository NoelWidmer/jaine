#import "Basic";

RUN_TESTS_AT_COMPILE_TIME :: false;
RUN_TESTS_AT_RUN_TIME :: true;

#no_reset tests : u8;

test :: (name: u8, func: ()->()) {
    if RUN_TESTS_AT_COMPILE_TIME {
        func();
    }

    if RUN_TESTS_AT_RUN_TIME {
        tests = name;
        print("added test: %\n", name);
    }
}

//Q: how would I go about having a bunch of #run directives which add things do an array and then at runtime I would like to for array