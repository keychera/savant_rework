import sys, os, glob
from os.path import isdir

if len(sys.argv) >= 2:
    bug_features_path = sys.argv[1]

    # get all features
    bug_features = list()
    glob_depth1 = glob.glob('{}/*'.format(bug_features_path), recursive=False)
    files_depth1 = [f for f in glob_depth1 if not isdir(f)]
    for i, bug_feature_file in zip(range(0, len(files_depth1)), files_depth1):
        with open(bug_feature_file) as fp:
            for count, line in enumerate(fp):
                row = line.rstrip()
                if (' ' in row):
                    label, features = row.split(' ', 1)
                    row_with_qid = '{} qid:{} {}'.format(label, i, features)
                    bug_features.append(row_with_qid)
                else:
                    bug_features.append(row)
    
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