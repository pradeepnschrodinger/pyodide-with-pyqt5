#define PY_SSIZE_T_CLEAN
#include "Python.h"
#include <emscripten.h>
#include <stdbool.h>


/* PyQt initializion functions */
extern PyObject *PyInit_sip();
extern PyObject *PyInit_Qt();
extern PyObject *PyInit_QtCore();
extern PyObject *PyInit_QtGui();
extern PyObject *PyInit_QtWidgets();

void execLastQApp();  // Start QTs main loop

// Wrapper modules

static PyMethodDef PyQt6Methods[] = {
    {NULL, NULL, 0, NULL}
};

static struct PyModuleDef PyQt6 = {
    PyModuleDef_HEAD_INIT,
    "PyQt6",
    0,
    -1,
    PyQt6Methods
};

PyMODINIT_FUNC PyInit_PyQt6(void)
{
    printf("in PyInit\r\n");
    PyObject *mod = PyModule_Create(&PyQt6);
    PyModule_AddObject(mod, "__path__", Py_BuildValue("()"));
    return mod;
}

#define FAIL_IF_STATUS_EXCEPTION(status)                                       \
  if (PyStatus_Exception(status)) {                                            \
    goto finally;                                                              \
  }

// Initialize python. exit() and print message to stderr on failure.
static void
initialize_python(int argc, char** argv)
{
  bool success = false;
  PyStatus status;


  // Register PyQT modules to Python
  PyImport_AppendInittab("PyQt6", PyInit_PyQt6);
  PyImport_AppendInittab("PyQt6.sip", PyInit_sip);
  PyImport_AppendInittab("PyQt6.Qt", PyInit_QtCore);
  PyImport_AppendInittab("PyQt6.QtCore", PyInit_QtCore);
  PyImport_AppendInittab("PyQt6.QtGui", PyInit_QtGui);
  PyImport_AppendInittab("PyQt6.QtWidgets", PyInit_QtWidgets);
  
  PyPreConfig preconfig;
  PyPreConfig_InitPythonConfig(&preconfig);

  status = Py_PreInitializeFromBytesArgs(&preconfig, argc, argv);
  FAIL_IF_STATUS_EXCEPTION(status);

  PyConfig config;
  PyConfig_InitPythonConfig(&config);

  status = PyConfig_SetBytesArgv(&config, argc, argv);
  FAIL_IF_STATUS_EXCEPTION(status);

  status = PyConfig_SetBytesString(&config, &config.home, "/");
  FAIL_IF_STATUS_EXCEPTION(status);

  config.write_bytecode = false;
  status = Py_InitializeFromConfig(&config);
  FAIL_IF_STATUS_EXCEPTION(status);

  // Fix import system to accomendate the shallow PyQt6 mock module
  // Thanks to dgym @ https://stackoverflow.com/questions/39250524/programmatically-define-a-package-structure-in-embedded-python-3
  PyRun_SimpleString(
        "from importlib import abc, machinery \n" \
        "import sys\n" \
        "\n" \
        "class Finder(abc.MetaPathFinder):\n" \
        "    def find_spec(self, fullname, path, target=None):\n" \
        "        if fullname in sys.builtin_module_names:\n" \
        "            print (\"Got builtin mode\", fullname)\n" \
        "            return machinery.ModuleSpec(fullname, machinery.BuiltinImporter)\n" \
        "\n" \
        "sys.meta_path.append(Finder())\n" \
        "print (\"Import magic run!\")"
  );

  // Create our QApplication inside Python
  PyRun_SimpleString("print (\"qtApp going to be created\")");  
  PyRun_SimpleString("from PyQt6.QtWidgets import QApplication\nqtApp = QApplication([\"pyodide\"])");
  PyRun_SimpleString("print (\"qtApp should be created now\")");

  execLastQApp();
  success = true;
finally:
  PyConfig_Clear(&config);
  if (!success) {
    // This will exit().
    Py_ExitStatusException(status);
  }
}

PyObject*
PyInit__pyodide_core(void);

/**
 * Bootstrap steps here:
 *  1. Import _pyodide package (we depend on this in _pyodide_core)
 *  2. Initialize the different ffi components and create the _pyodide_core
 *     module
 *  3. Create a PyProxy wrapper around _pyodide package so that JavaScript can
 *     call into _pyodide._base.eval_code and
 *     _pyodide._import_hook.register_js_finder (this happens in loadPyodide in
 *     pyodide.js)
 */
int
main(int argc, char** argv)
{
  // This exits and prints a message to stderr on failure,
  // no status code to check.
  PyImport_AppendInittab("_pyodide_core", PyInit__pyodide_core);
  initialize_python(argc, argv);
  emscripten_exit_with_live_runtime();
  return 0;
}

void
pymain_run_python(int* exitcode);

EMSCRIPTEN_KEEPALIVE int
run_main()
{
  int exitcode;
  pymain_run_python(&exitcode);
  return exitcode;
}
