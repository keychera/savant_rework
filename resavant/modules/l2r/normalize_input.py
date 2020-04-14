import sys, os

def normalize(val, min_val, max_val):
    if (max_val == min_val):
        return val
    else:
        return (float(val) - min_val)/(max_val - min_val)

if len(sys.argv) >= 2:
    aggregate_path = sys.argv[1]

    # get all diff method
    bug_features = list()
    with open(aggregate_path) as fp:
        for count, line in enumerate(fp):
            bug_features.append(line.rstrip())
    
    # get values per column
    column_list = {}
    label_qid_list = list()
    for i, row in zip(range(0, len(bug_features)), bug_features):
        all_split = row.split(' ')
        row_split = all_split[2:]
        label_qid_list.append('{} {}'.format(all_split[0], all_split[1]))
        for j in range(0, len(row_split)):
            col_index, val = row_split[j].split(':')
            col_index = int(col_index)
            if (not col_index in column_list):
                column_list[col_index] = [0] * len(bug_features)
            column_list[col_index][i] = val
    
    # normalize bug features
    normalized_column_list = {}
    maxmin_column_stat = {}
    for col_index in column_list:
        val_only_column = column_list[col_index]
        max_val = max(float(x) for x in val_only_column)
        min_val = min(float(x) for x in val_only_column)
        
        func = lambda x: normalize(x, min_val, max_val)
        normalized_column = map(func, val_only_column)
        normalized_column_list[col_index] = list(normalized_column)
        maxmin_column_stat[col_index] = (max_val, min_val)
    
    # build the feature list back from column list
    normed_features_list = list()
    for label_qid in label_qid_list:
        normed_features_list.append(label_qid)
    
    for col_index in sorted(normalized_column_list):
        normalized_column = normalized_column_list[col_index]
        for i, val in zip(range(0, len(normalized_column)), normalized_column):
            normed_features_list[i] = '{} {}:{}'.format(normed_features_list[i], col_index, val)

    # output the result
    if len(sys.argv) >= 4:
        norm_output_file = sys.argv[2]
        maxmin_output_file = sys.argv[3]

        with open(norm_output_file, 'w+') as f:
            for row in normed_features_list:
                f.write("{}\n".format(row))
        
        with open(maxmin_output_file, 'w+') as f:
            for col_index in sorted(maxmin_column_stat):
                a_tuple = maxmin_column_stat[col_index]
                f.write("{}:{},{}\n".format(col_index ,a_tuple[0], a_tuple[1]))
    else:
        for row in normed_features_list:
            print(row)
        for col_index in sorted(maxmin_column_stat):
            a_tuple = maxmin_column_stat[col_index]
            print("{}:{},{}\n".format(col_index ,a_tuple[0], a_tuple[1]))

else:
    print('python aggregate input.py')