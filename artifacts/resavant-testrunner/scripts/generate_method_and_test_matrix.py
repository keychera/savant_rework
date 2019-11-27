import sys, os

if len(sys.argv) >= 4:
    cvr_res_folder = sys.argv[1]
    methods_file_path = sys.argv[2]
    tests_file_path = sys.argv[3]

    if not os.path.isdir(cvr_res_folder):
        raise ValueError('This input is not a directory! : ', cvr_res_folder)
    
    if not os.path.isfile(methods_file_path):
        raise ValueError('This input is not a file! : ', methods_file_path)

    if not os.path.isfile(tests_file_path):
        raise ValueError('This input is not a file! : ', tests_file_path)

    methods = list()
    with open(methods_file_path) as fp:
        for count, line in enumerate(fp):
            methods.append([line])

    for path, subdirs, files in os.walk(cvr_res_folder):
        abs_path = os.path.abspath(path)
        for dir_name in subdirs:
            method_report_path = '{}/{}/{}'.format(abs_path,dir_name,'cobertura/covered_methods')
            method_covered_by_test = list()
            with open(method_report_path) as fp:
                for count, line in enumerate(fp):
                    method_covered_by_test.append(line)
            for method in methods:
                if method[0] in method_covered_by_test:
                    method.append(1)
                else:
                    method.append(0)
        break

    method_lines = list()
    for method in methods:
        line = '{}'.format(method[0].rstrip())
        for i in range(1, len(method)):
            line += ',{}'.format(method[i])
        method_lines.append(line)

    if len(sys.argv) >= 5:
        output_file = sys.argv[4]
        with open(output_file, 'w+') as f:
            for line in method_lines:
                f.write("{}\n".format(line))
    else:
        for line in method_lines:
            pass
            print(line)
    
else:
    print('python generate_method_and_test_matrix.py [coverage result folder] [method list] [test list] (opt)[output file]')