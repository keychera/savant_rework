import sys, os

if len(sys.argv) >= 2:
    aggregate_path = sys.argv[1]

    # get all diff method
    bug_features = list()
    with open(aggregate_path) as fp:
        for count, line in enumerate(fp):
            bug_features.append(line.rstrip())
    
    # get values per column
    a_row = bug_features[0].split(' ')[1:]
    column_list = list() 
    for i in range(0, len(a_row)):
        column_list.append(list())

    label_list = list()
    for row in bug_features:
        row_split = row.split(' ')[1:]
        label_list.append(row.split(' ')[0])
        for i in range(0, len(row_split)):
            row_val = row_split[i]
            column_list[i].append(row_val)
    
    val_only_column_list = list()
    for column in column_list:
        val_only_column = list()
        for val in column:
            val_only = val.split(":")[1]
            val_only_column.append(val_only)
        val_only_column_list.append(val_only_column)

    # normalize bug features
    normalized_column_list = list()
    maxmin_column_stat = list()
    for val_only_column in val_only_column_list:
        max_val = max(float(x) for x in val_only_column)
        min_val = min(float(x) for x in val_only_column)

        normalized_column = list()
        for val in val_only_column:
            if (max_val == min_val):
                normalized_column.append(val)
            else:
                normalized_val = (float(val) - min_val)/(max_val - min_val)
                normalized_column.append(normalized_val)
        
        normalized_column_list.append(normalized_column)
        maxmin_column_stat.append((max_val, min_val))
    
    # build the feature list back from column list
    normalized_features_list = list()
    for label in label_list:
        normalized_features_list.append(label)
    
    col_i = 0
    for normalized_column in normalized_column_list:
        i = 0
        for val in normalized_column:
            normalized_features_list[i] = normalized_features_list[i] + ' {}:{}'.format(col_i, val)
            i = i + 1
        col_i = col_i + 1

    # output the result
    if len(sys.argv) >= 4:
        norm_output_file = sys.argv[2]
        maxmin_output_file = sys.argv[3]

        with open(norm_output_file, 'w+') as f:
            for row in normalized_features_list:
                f.write("{}\n".format(row))
        
        with open(maxmin_output_file, 'w+') as f:
            for a_tuple in maxmin_column_stat:
                f.write("{},{}\n".format(a_tuple[0], a_tuple[1]))
    else:
        for row in normalized_features_list:
            print(row)
        for a_tuple in maxmin_column_stat:
            print(row)

else:
    print('python aggregate input.py')