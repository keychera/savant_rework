import sys, os
import pandas as pd

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
    
    # TODO get the invariant diff features

    # build the l2r data
    l2r_data = list()

    for row in sbfl_stat_df.itertuples(index=True):
        
        label = '0'
        method_name = row[1]
        if method_name in diff_methods:
            label = '1'
        
        sbfl_row = ''
        for index, sbfl_score in zip(range(0, len(row) - 2), row[2:]):
            sbfl_row = sbfl_row + ' {}:{}'.format(index, sbfl_score)

        # TODO daikon integrate
        
        l2r_row = '{}{}'.format(label, sbfl_row)
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