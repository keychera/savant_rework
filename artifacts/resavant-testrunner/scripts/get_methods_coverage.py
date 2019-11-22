import sys
from bs4 import BeautifulSoup

if len(sys.argv) >= 2:
    xml_file_path = sys.argv[1]
    with open(xml_file_path, 'r') as xml_file:
        cvr_xml = BeautifulSoup(xml_file.read(), features='html.parser')

    all_classes = cvr_xml.findAll(name = 'class')
    method_names = list()
    for a_class in all_classes:
        all_methods = a_class.findAll(name = 'method')

        covered_methods = list()
        for method in all_methods:
            if method.get('line-rate') != '0.0':
                covered_methods.append(method)

        for method in covered_methods:
            method_name = method.get('name')
            class_name = a_class.get('name')
            method_names.append('{}::{}'.format(class_name, method_name))
    
    if len(sys.argv) >= 3:
        output_path = sys.argv[2]
        if len(sys.argv) >= 4:
            testname = sys.argv[3]
        else:
            testname = 'some'
        with open(output_path + '/covered_methods-{}'.format(testname), 'w+') as f:
            for method_name in method_names:
                f.write("{}\n".format(method_name))
    else:
        for method_name in method_names:
            print(method_name)


else:
    print('python get_methods_coverage.py [path to coverage.xml file] (opt)[outputpath]')