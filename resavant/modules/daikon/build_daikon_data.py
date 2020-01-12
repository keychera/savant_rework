import argparse
import pandas as pd
from pathlib import Path

# parse arguments
parser = argparse.ArgumentParser(description='Get inputs')
parser.add_argument('--clusters', dest='clusters_dir', type=str, required=True,help='clusters dir')
parser.add_argument('--coverage_stat', dest='coverage_stat_dir', type=str, required=True, help='coverage stat dir')
parser.add_argument('--out_dir', dest='out_dir', type=str, required=True, help='output dir')

args = parser.parse_args()
cvr_stat_dir = args.coverage_stat_dir
clusters_dir = args.clusters_dir
out_dir = args.out_dir

# get list of covered method
matrix_failing_path = '{}/{}'.format(cvr_stat_dir, 'matrix_failing.csv')
matrix_failing_df = pd.read_csv(matrix_failing_path, header=None)
covered_method = matrix_failing_df[0]

# get list of failing and passing tests
failing_test_path = '{}/{}'.format(cvr_stat_dir, 'matrix_failing.csv.header')
failing_tests = list()
with open(failing_test_path) as fp:
    for count, line in enumerate(fp):
        failing_tests.append(line.rstrip())

passing_test_path = '{}/{}'.format(cvr_stat_dir, 'matrix_passing.csv.header')
passing_tests = list()
with open(passing_test_path) as fp:
    for count, line in enumerate(fp):
        passing_tests.append(line.rstrip())

# get clusters and selected passing tests
clusters_path = '{}/{}'.format(clusters_dir, 'clusters')
clusters = list()
with open(clusters_path) as fp:
    for count, line in enumerate(fp):
        cluster = line.rstrip().split(',')
        clusters.append(cluster)

selected_tests_path = '{}/{}'.format(clusters_dir, 'selected_tests')
selected_tests = list()
with open(selected_tests_path) as fp:
    for count, line in enumerate(fp):
        tests = line.rstrip().split(',')
        selected_tests.append(tests)

assert (len(clusters) == len(selected_tests)), 'number of clusters must be the same as number of groups of selected tests'

# build the clusters files and the faling tests file
for i, cluster, tests in zip(range(0, len(clusters)), clusters, selected_tests):
    cluster_dir = '{}/{}/{}'.format(out_dir, 'clusters_dir', i)
    Path(cluster_dir).mkdir(parents=True, exist_ok=True)

    cluster_file = '{}/{}'.format(cluster_dir, 'cluster')
    with open(cluster_file, 'w+') as fp:
        for methodIndex in cluster:
            methodName = covered_method[int(methodIndex)]
            fp.write('{}\n'.format(methodName))
    
    test_file = '{}/{}'.format(cluster_dir, 'selected_tests')
    with open(test_file, 'w+') as fp:
        for testIndex in tests:
            testName = passing_tests[int(testIndex)]
            fp.write('{}\n'.format(testName))

failing_test_file = '{}/{}'.format(out_dir, 'failing_tests')
with open(failing_test_file, 'w+') as fp:
    for failing_test in failing_tests:
        fp.write('{}\n'.format(failing_test))
