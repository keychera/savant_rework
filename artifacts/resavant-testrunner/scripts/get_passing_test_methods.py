import sys

if len(sys.argv) >= 3:
    alltests_path = sys.argv[1]
    failingtests_path = sys.argv[2]

    failing_test_methods = list()
    with open(alltests_path) as fp:
        for count, line in enumerate(fp):
            failing_test_methods.append(line)
    
    all_test_methods = list()
    with open(alltests_path) as fp:
        for count, line in enumerate(fp):
            if not (line in failing_test_methods):
                all_test_methods.append(line.rstrip())
    
    if len(sys.argv) == 4:
        output_path = sys.argv[3]
        with open(output_path + '/passing_tests', 'w+') as f:
            for test_method in  all_test_methods:
                f.write("{}\n".format(test_method))
    else:
        for test_method in all_test_methods:
            print(test_method)

else:
    print('python scripts/get_passing_test_methods.py [all_tests file] [failing_tests file]')