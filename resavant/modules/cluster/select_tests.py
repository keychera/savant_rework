import sys
import pandas as pd

if len(sys.argv) >= 4:
    method_test_matrix_file = sys.argv[1]
    method_cluster_file = sys.argv[2]

    sT = int(sys.argv[3])

    df = pd.read_csv(method_test_matrix_file, header=None)

    cluster_idx_list = list()
    with open(method_cluster_file, 'r') as fp:
        for count, line in enumerate(fp):
            idx_list = line.rstrip().split(',')
            cluster_idx_list.append(list(map(int, idx_list)))
    
    cluster_matrix_list = list()
    transposed = df.T
    for idx_list in cluster_idx_list:
        cluster_matrix_list.append(transposed[idx_list].copy())

    selected_tests = list()
    for mt in cluster_matrix_list:
        sorted_mt = mt[1:len(mt.values)].sort_values(by=list(mt.columns), ascending=False)

        selected_test = list()
        for method in sorted_mt.columns:
            coverage = 0
            idx = 1
            mt_series = sorted_mt[method]
            while coverage < sT and idx < len(mt_series.values):
                if mt_series[idx] == 1:
                    coverage += 1
                    selected_test.append(sorted_mt.index[idx-1]-1)
                idx += 1

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
    
    
            