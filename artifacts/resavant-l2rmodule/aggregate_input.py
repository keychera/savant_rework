import sys, os

if len(sys.argv) >= 2:
    bug_features_path = sys.argv[1]

    # get all diff method
    bug_features = list()
    for bug_feature_file in os.listdir(bug_features_path):
        with open('{}/{}'.format(bug_features_path,bug_feature_file)) as fp:
            for count, line in enumerate(fp):
                bug_features.append(line.rstrip())
    
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