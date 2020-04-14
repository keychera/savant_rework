import sys, os
from os.path import isfile, join

if len(sys.argv) >= 2:
    bug_features_path = sys.argv[1]

    # get all features
    bug_features = list()
    all_files_in_dir = [f for f in os.listdir(bug_features_path) if isfile(join(bug_features_path, f))]
    for i, bug_feature_file in zip(range(0, len(all_files_in_dir)), all_files_in_dir):
        with open('{}/{}'.format(bug_features_path,bug_feature_file)) as fp:
            for count, line in enumerate(fp):
                row = line.rstrip()
                label, features = row.split(' ', 1)
                row_with_qid = '{} qid:{} {}'.format(label, i, features)
                bug_features.append(row_with_qid)
    
    # output the result
    if len(sys.argv) >= 3:
        output_file = sys.argv[2]
        with open(output_file, 'w+') as f:
            for row in bug_features:
                f.write("{}\n".format(row))
    else:
        for row in bug_features:
            print(row)

else:
    print('python aggregate input.py')