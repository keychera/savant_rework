import sys, random
import pandas as pd
from sklearn.cluster import KMeans

if len(sys.argv) >= 3:
    method_test_matrix_file = sys.argv[1]

    df = pd.read_csv(method_test_matrix_file, header=None)

    sI = len(df.index)
    sM = int(sys.argv[2])
    n = round(sI / sM)

    col_len = len(df.columns)
    kmeans = KMeans(n_clusters=n).fit(df[df.columns[1:col_len]])

    cs_list = list()

    for label in set(kmeans.labels_):
        sublist = list()
        cs_list.append(sublist)

    
    for method_idx in range(0, len(df[0])):
        cl_label = kmeans.labels_[method_idx]
        cs_list[cl_label].append(method_idx)

    new_clusters = list()
    for cs in cs_list:
        while (len(cs) > sM):
            new_cluster = list()
            for i in range(0, sM):
                random_selected = random.choice(cs)
                new_cluster.append(random_selected)
                idx_selected = cs.index(random_selected)
                del cs[idx_selected]

            new_clusters.append(new_cluster)

    all_clusters = cs_list + new_clusters
    if len(sys.argv) == 4:
        output_file = sys.argv[3]
        with open(output_file, 'w+') as f:
            for cs in all_clusters:
                cs_str = ','.join(map(str,cs))
                f.write("{}\n".format(cs_str)) 
    else:
        for cs in all_clusters:
            print(cs)

else:
    print('python get_method_cluster.py [method test matrix csv file] [max cluster size] (opt)[output file]')

    