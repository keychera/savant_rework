import sys

if len(sys.argv) >= 2:
    report_path = sys.argv[1]

    all_tests = list()
    with open(report_path) as fp:
        for count, line in enumerate(fp):
            test_method_name, package_name = line.rstrip().split('(')
            test_method = '{}::{}'.format(package_name[:-1], test_method_name)
            all_tests.append(test_method)

    if len(sys.argv) >= 3:
        output_file = sys.argv[2]
        with open(output_file, 'w+') as f:
            for test_method in  all_tests:
                f.write("{}\n".format(test_method))
    else:
        for test_method in all_tests:
            print(test_method)

else:
    print('python get_all_tests [all_tests path] (opt)[output file]')