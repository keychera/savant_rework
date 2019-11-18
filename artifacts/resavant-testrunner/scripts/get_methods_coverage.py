import sys
from bs4 import BeautifulSoup

if len(sys.argv) == 2:
    project_path = sys.argv[1]
    cvr_results_file = open(project_path + '/coverage.xml', 'r')

    cvr_xml = BeautifulSoup(cvr_results_file.read(), features='html.parser')

    cvr_results_file.close()

    all_classes = cvr_xml.findAll(name = 'class')
    for class_name in all_classes:
        all_methods = class_name.findAll(name = 'method')

        covered_methods = list()
        for method in all_methods:
            if method.get('line-rate') != '0.0':
                covered_methods += [method]
        
        for method in covered_methods:
            print(method.get('name'))


else:
    print('python get_methods_coverage.py [path_to_defects4j_project]')