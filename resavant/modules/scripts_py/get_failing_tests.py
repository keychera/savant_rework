import sys

if len(sys.argv) >= 2:
    report_path = sys.argv[1]

    failing_tests = list()
    with open(report_path) as fp:
        for count, line in enumerate(fp):
            if '--- ' in line:
                failing_tests.append(line[4:].rstrip())
    
    if len(sys.argv) == 3:
        output_file = sys.argv[2]
        with open(output_file, 'w+') as f:
            for failing_test_method in failing_tests:
                f.write("{}\n".format(failing_test_method))
    else:
        for failing_test_method  in failing_tests:
            print(failing_test_method )

else:
    print('python get_failing_tests.py [failing tests report] (opt)[output file]')