import sys

if len(sys.argv) >= 3:
    alltests_path = sys.argv[1]
    failingtests_path = sys.argv[2]

    failing_tests = list()
    with open(failingtests_path) as fp:
        for count, line in enumerate(fp):
            failing_tests.append(line)
    
    all_tests = list()
    with open(alltests_path) as fp:
        for count, line in enumerate(fp):
            if not (line in failing_tests):
                all_tests.append(line.rstrip())
    
    if len(sys.argv) == 4:
        output_file = sys.argv[3]
        with open(output_file, 'w+') as f:
            for test_method in  all_tests:
                f.write("{}\n".format(test_method))
    else:
        for test_method in all_tests:
            print(test_method)

else:
    print('python get_passing_tests.py [all_tests file] [failing_tests file] (opt)[output file]')