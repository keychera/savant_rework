import argparse, re

# parse arguments
parser = argparse.ArgumentParser(description='Get inputs')
parser.add_argument('--method_list', dest='method_list', type=str, required=True,help='method list file')

args = parser.parse_args()
method_list_path = args.method_list

methods_regex = list()
with open(method_list_path) as fp:
    for count, line in enumerate(fp):
        method_full_name = line.rstrip()

        method_capture = re.search(r'(.+)::(\w+)\((.*)\) : (\w+)', method_full_name)
        if (not isinstance(method_capture, type(None))):
            class_full_name = method_capture.group(1)
            method_name = method_capture.group(2)
            input_types_string = method_capture.group(3)

            class_regex_name = class_full_name.replace('.', '\.')
            input_types_pattern = '.*{}'.format(input_types_string)
            regex_pattern = '{}\.{}\\({}\\)'.format(class_regex_name, method_name, input_types_pattern)

            methods_regex.append(regex_pattern)

regex_result = ''
list_len = len(methods_regex)
for i, regex_pattern in zip(range(0, list_len), methods_regex):
    regex_result += '({})'.format(regex_pattern)
    if (i != list_len - 1):
        regex_result += '|'

print(regex_result)