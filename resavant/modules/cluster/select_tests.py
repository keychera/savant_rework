import sys
import pandas as pd

def coverage(sorted_mt, selected_test, sT):
    sum_val = list()
    for column in sorted_mt.columns:
        sum_val.append(0)

    for idx in selected_test:
        selected_mt_val = sorted_mt.loc[idx+1]
        i = 0
        sum_val = [a + b for a,b in zip(sum_val, selected_mt_val)]

    return all(a >= sT for a in sum_val)

if len(sys.argv) >= 4:
    method_test_matrix_file = sys.argv[1]
    method_cluster_file = sys.argv[2]

    sT = int(sys.argv[3])

    method_test_df = pd.read_csv(method_test_matrix_file, header=None)

    cluster_idx_list = list()
    with open(method_cluster_file, 'r') as fp:
        for count, line in enumerate(fp):
            idx_list = line.rstrip().split(',')
            cluster_idx_list.append(list(map(int, idx_list)))
    
    cluster_matrix_list = list()
    transposed = method_test_df.T
    for idx_list in cluster_idx_list:
        cluster_matrix_list.append(transposed[idx_list].copy())

    selected_tests = list()
    for mt in cluster_matrix_list:
        sorted_mt = mt[1:len(mt.values)].sort_values(by=list(mt.columns), ascending=False)

        selected_test = list()
        i = 0
        while not coverage(sorted_mt, selected_test, sT) and i < len(sorted_mt.index):
            if (sorted_mt.iloc[i].sum()>0):
                index = sorted_mt.index[i-1]
                selected_test.append(index-1)
            i += 1

        selected_test = list(set(selected_test))
        selected_tests.append(selected_test)

    res = selected_tests

    if len(sys.argv) == 5:
        output_file = sys.argv[4]
        with open(output_file, 'w+') as f:
            for cs in res:
                cs_str = ','.join(map(str,cs))
                f.write("{}\n".format(cs_str)) 
    else:
        for cs in res:
            print(cs)
    
else:
    print('python select_tests.py [method test matrix file] [method cluster file] [T value] (opt)[output file]')
    
    
            