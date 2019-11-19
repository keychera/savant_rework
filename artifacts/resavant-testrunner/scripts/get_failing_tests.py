import sys

if len(sys.argv) >= 2:
    report_path = sys.argv[1]

    failing_tests = list()
    with open(report_path) as fp:
        for count, line in enumerate(fp):
            if '--- ' in line:
                failing_tests.append(line[4:].rstrip())
    
    if len(sys.argv) == 3:
        output_path = sys.argv[2]
        with open(output_path + '/failing_tests', 'w+') as f:
            for failing_test in failing_tests:
                f.write("{}\n".format(failing_test))
    else:
        for failing_test in failing_tests:
            print(failing_test)
