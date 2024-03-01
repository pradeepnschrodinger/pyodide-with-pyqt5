import importlib.abc
import importlib.machinery
import sys


class Finder(importlib.abc.MetaPathFinder):
    def find_spec(self, fullname, path, target=None):
        print ("Niranjan: ", "find_spec called()")
        print ("Niranjan: ", "fullname: ", fullname)
        print ("Niranjan: ", "path: ", path)
        print ("Niranjan: ", "target: ", target)
        print ("sys.builtin_module_names", sys.builtin_module_names)
        # if fullname in sys.builtin_module_names:
        if True:
            print ('fullname_of_builtin_module', fullname)
            return importlib.machinery.ModuleSpec(
                fullname,
                importlib.machinery.BuiltinImporter,
            )


sys.meta_path.append(Finder())

import PyQt6.QtCore