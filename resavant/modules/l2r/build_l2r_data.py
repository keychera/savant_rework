import sys, os
import pandas as pd
import re

def read_file_each_line(file_path):
    lines = list()
    try:
        with open(file_path) as fp:
            for count, line in enumerate(fp):
                lines.append(line.rstrip())
    except IOError:
        pass
    return lines

if len(sys.argv) >= 4:
    method_diff_path = sys.argv[1]
    sbfl_stat_path = sys.argv[2]
    daikon_stat_path = sys.argv[3]

    # get all diff method
    diff_methods = list()
    for diff_file in os.listdir(method_diff_path):
        with open('{}/{}'.format(method_diff_path,diff_file)) as fp:
            for count, line in enumerate(fp):
                diff_methods.append(line.rstrip())
        
    # get the sbfl stat
    sbfl_stat_df = pd.read_csv(sbfl_stat_path, header=None)
    
    # build data based on daikon result structure
    failing_x_selected = read_file_each_line('{}/{}'.format(daikon_stat_path, 'failing_x_selected'))
    failing_x_failing_selected = read_file_each_line('{}/{}'.format(daikon_stat_path, 'failing_x_failing_selected'))
    selected_x_failing_selected = read_file_each_line('{}/{}'.format(daikon_stat_path, 'selected_x_failing_selected'))

    method_features = {}
    all_comb = (failing_x_selected, failing_x_failing_selected, selected_x_failing_selected)
    daikon_method_pattern = r'(.*) # (.+)'
    
    for i, combination in zip(range(0,len(all_comb)), all_comb):
        for line in combination:
            method_capture = re.search(daikon_method_pattern, line)
            if (not isinstance(method_capture, type(None))):
                daikon_features = method_capture.group(1)
                daikon_method_name = method_capture.group(2)

                if (not daikon_method_name in method_features):
                    label_and_features = {}
                    label_and_features['label'] = None
                    label_and_features['daikon'] = [None] * len(all_comb)
                    label_and_features['sbfl'] = None
                    method_features[daikon_method_name] = label_and_features
                
                method_features[daikon_method_name]['daikon'][i] = daikon_features

    # integrate label and SBFL data
    l2r_data = list()

    sbfl_method_pattern = r'(.+)::(\w+)\((.*)\)[ : (\w+)]*'
    for row in sbfl_stat_df.itertuples(index=True):
    
        label = '0'
        method_full_name = row[1]
        if method_full_name in diff_methods:
            label = '1'
        
        sbfl_features = ''
        for index, sbfl_score in zip(range(0, len(row) - 2), row[2:]):
            sbfl_features = sbfl_features + ' {}:{}'.format(index, sbfl_score)

        method_capture = re.search(sbfl_method_pattern, method_full_name)
        if (not isinstance(method_capture, type(None))):
            class_full_name = method_capture.group(1)
            method_name = method_capture.group(2)
            input_types_string = method_capture.group(3)

            class_regex_name = class_full_name.replace('.', '\.')
            input_types_pattern = ''
            if (len(input_types_string) > 0):
                input_types_string = input_types_string.replace(' ', '').replace('[','\[').replace(']','\]')
                input_types = input_types_string.split(',')
                for input_type in input_types:
                    input_types_pattern += '.*{}'.format(input_type)
            
            sbfl_regex_pattern = '{}\.{}\\({}\\)'.format(class_regex_name, method_name, input_types_pattern)

        for daikon_method_name in method_features:
            is_matching = re.match(sbfl_regex_pattern, daikon_method_name)
            if is_matching:
                method_features[daikon_method_name]['label'] = label
                method_features[daikon_method_name]['sbfl'] = sbfl_features

                # format into l2r data row strings as well
                # format daikon features
                total_index_num = 96721
                all_daikon_features = method_features[daikon_method_name]['daikon']
                formatted_daikon_features = ''
                for i, daikon_features in zip(range(0,len(all_daikon_features)), all_daikon_features):
                     if (not isinstance(daikon_features, type(None))): 
                        split_features = daikon_features.split(' ')

                        for feature in split_features:
                            if ':' in feature:
                                index, value = feature.split(':')
                                formatted_feature = ' {}:{}'.format(int(index) + (total_index_num * i),value)
                                formatted_daikon_features += formatted_feature

                # format sbfl features
                formatted_sbfl_features = ''
                split_features = sbfl_features.split(' ')
                for feature in split_features:
                    if ':' in feature:
                        index, value = feature.split(':')
                        formatted_feature = ' {}:{}'.format(int(index) + (total_index_num * 3),value)
                        formatted_sbfl_features += formatted_feature

                formatted_features = '{}{}'.format(formatted_daikon_features, formatted_sbfl_features)
                l2r_row = '{}{}'.format(label, formatted_features)
                l2r_data.append(l2r_row)

    # output the result
    if len(sys.argv) >= 5:
        output_file = sys.argv[4]
        with open(output_file, 'w+') as f:
            for row in l2r_data:
                f.write("{}\n".format(row))
    else:
        for row in l2r_data:
            print(row)


else:
    print('python build_input.py')