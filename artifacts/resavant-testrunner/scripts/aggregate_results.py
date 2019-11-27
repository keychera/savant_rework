import sys, os

if len(sys.argv) >= 2:
    results_folder = sys.argv[1]

    if not os.path.isdir(results_folder):
        raise ValueError('Input is not a directory! : ', results_folder)

    aggregate = [[]]
    for path, subdirs, files in os.walk(results_folder):
        for file_name in files:
            file_path = '{}/{}'.format(path,file_name)
            method_list = list()
            with open(file_path) as fp:
                for count, line in enumerate(fp):
                    method_list.append(line.rstrip())
            aggregate.append(method_list)
            aggregate_union = set().union(*aggregate)
            aggregate = [list(aggregate_union)]
            aggregate.sort()
    
    aggregate = aggregate[0]

    if len(sys.argv) >= 3:
        output_file = sys.argv[2]
        with open(output_file, 'w+') as f:
            for line in aggregate:
                f.write("{}\n".format(line))
    else:
        for line in aggregate:
            print(line)

else:
    print('python aggregate_results.py [input file] (opt)[output file]')