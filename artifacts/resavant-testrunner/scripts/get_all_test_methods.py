import sys

arg_num = 3

if len(sys.argv) >= arg_num - 1:
    report_path = sys.argv[1]

    all_test_methods = list()
    with open(report_path) as fp:
        for count, line in enumerate(fp):
            test_method_name, package_name = line.rstrip().split('(')
            test_method = '{}::{}'.format(package_name[:-1], test_method_name)
            all_test_methods.append(test_method)

    if len(sys.argv) == arg_num:
        output_path = sys.argv[2]
        with open(output_path + '/all_test_methods', 'w+') as f:
            for test_method in  all_test_methods:
                f.write("{}\n".format(test_method))
    else:
        for test_method in all_test_methods:
            print(test_method)