import sys, os

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
    sbfl_rows = list()
    with open(sbfl_stat_path) as fp:
        for count, line in enumerate(fp):
            sbfl_rows.append(line.rstrip())

    l2r_rows = list()

    for row in sbfl_rows:
        row_split = row.split(',')
        if row_split[0] in diff_methods:
            row_split[0] = '1'
        else:
            row_split[0] = '0'
        for i in range(1, len(row_split)):
            row_split[i] = '{}:{}'.format(i, row_split[i])

        l2r_rows.append(row_split)

    # get the invariant diff features
    # TODO

    # format the rows
    formatted_l2r_rows = list()
    for row in l2r_rows:
        formatted_row = ' '.join(row)
        formatted_l2r_rows.append(formatted_row)
    
    # output the result
    if len(sys.argv) >= 5:
        output_file = sys.argv[4]
        with open(output_file, 'w+') as f:
            for row in formatted_l2r_rows:
                f.write("{}\n".format(row))
    else:
        for row in formatted_l2r_rows:
            print(row)


else:
    print('python build_input.py')