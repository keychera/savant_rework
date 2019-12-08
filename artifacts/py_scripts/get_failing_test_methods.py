import sys

if len(sys.argv) >= 2:
    report_path = sys.argv[1]

    failing_test_methods = list()
    with open(report_path) as fp:
        for count, line in enumerate(fp):
            if '--- ' in line:
                failing_test_methods.append(line[4:].rstrip())
    
    if len(sys.argv) == 3:
        output_file = sys.argv[2]
        with open(output_file, 'w+') as f:
            for failing_test_method in failing_test_methods:
                f.write("{}\n".format(failing_test_method))
    else:
        for failing_test_method  in failing_test_methods:
            print(failing_test_method )

else:
    print('python get_failing_test_methods.py [failing tests report] (opt)[output file]')