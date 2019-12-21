import glob, sys, inspect, importlib
from os.path import dirname, basename, isfile, join

all_py_files = glob.glob(join(dirname(__file__), "*.py"))
all_module_names = [ basename(f)[:-3] for f in all_py_files if isfile(f) and not f.endswith('__init__.py')]

current_module = sys.modules[__name__]
current_module_name = current_module.__name__

all_sbfl_strategies = list()

for module_name in all_module_names:
    module = importlib.import_module('{}.{}'.format(current_module_name, module_name))
    for name, obj in inspect.getmembers(module):
        parent_class = abstract_strategy.AbstractSBFLStrategy.AbstractSBFLStrategy
        if inspect.isclass(obj) and issubclass(obj, parent_class) and (obj != parent_class):
            all_sbfl_strategies.append(obj)