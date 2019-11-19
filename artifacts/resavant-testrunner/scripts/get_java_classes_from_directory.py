import sys, os
from fnmatch import fnmatch

if len(sys.argv) >= 2:
    classdir_path = sys.argv[1]
    pattern = "*.java"
    
    path_length = len(classdir_path)
    classnames = list()
    for path, subdirs, files in os.walk(classdir_path):
        for file_name in files:
            if fnmatch(file_name, pattern):
                package_name = ''
                for package_subname in path[path_length:].split('/')[1:]:
                    package_name += package_subname + '.'
                classnames.append(package_name + file_name[:-5])
    
    if len(sys.argv) == 3:
        output_path = sys.argv[2]
        with open(output_path + '/all_classes', 'w+') as f:
            for classname in classnames:
                f.write("{}\n".format(classname))
    else:
        for classname in classnames:
            print(classname)

else: 
    print('python get_java_classes_from_directory.py [absolute path to the class directory] (opt)[outputpath]')