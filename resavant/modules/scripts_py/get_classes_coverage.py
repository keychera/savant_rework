import sys
from bs4 import BeautifulSoup

if len(sys.argv) >= 2:
    report_path = sys.argv[1]

    covered_methods = list()
    with open(report_path) as fp:
        for count, line in enumerate(fp):
            covered_methods.append(line.rstrip())

    covered_classes = list()
    for method in covered_methods:
        a_class = method.split('::')[0]
        if not(a_class in covered_classes): 
            covered_classes.append(a_class)
        
    if len(sys.argv) >= 3:
        output_file = sys.argv[2]
        with open(output_file, 'w+') as f:
            for failing_test in covered_classes:
                f.write("{}\n".format(failing_test))
    else:
        for failing_test in covered_classes:
            print(failing_test)

else:
    print('python get_classes_coverage.py [covered_method file] (opt)[output file]')
