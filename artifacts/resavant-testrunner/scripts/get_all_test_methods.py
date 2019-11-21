import sys, re

if len(sys.argv) >= 3:
    alltests_input = sys.argv[1]
    test_dir = sys.argv[2]
 
    all_tests = list()
    with open(alltests_input) as fp:
        for count, line in enumerate(fp):
            all_tests.append(line.rstrip())

    all_test_methods = list()
    for test in all_tests:
        test_sourcode_path = '{}/{}.java'.format(test_dir, test.replace('.','/'))

        with open(test_sourcode_path) as test_sc_file:
            test_sc = test_sc_file.read()
        
        reg_exp = r'@Test(?:\s*)public void (.+)\('
        
        for test_method in re.findall(reg_exp, test_sc):
            all_test_methods.append('{}::{}'.format(test,test_method))

    if len(sys.argv) == 4:
        output_path = sys.argv[3]
        with open(output_path + '/all_test_methods', 'w+') as f:
            for test_method in  all_test_methods:
                f.write("{}\n".format(test_method))
    else:
        for test_method in all_test_methods:
            print(test_method)