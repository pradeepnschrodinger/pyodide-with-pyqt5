#include <Python.h>
#include <emscripten.h>

#include "hiwire.h"
#include "js2python.h"
#include "jsimport.h"
#include "jsproxy.h"
#include "pyimport.h"
#include "pyproxy.h"
#include "python2js.h"
#include "runpython.h"


/* PyQt initializion functions */
extern PyObject *PyInit_sip();
extern PyObject *PyInit_Qt();
extern PyObject *PyInit_QtCore();
extern PyObject *PyInit_QtGui();
extern PyObject *PyInit_QtWidgets();
extern PyObject *PyInit_QtSvg();

void execLastQApp();  // Start QTs main loop

// Wrapper modules

static PyMethodDef PyQt5Methods[] = {
    {NULL, NULL, 0, NULL}
};

static struct PyModuleDef PyQt5 = {
    PyModuleDef_HEAD_INIT,
    "PyQt5",
    0,
    -1,
    PyQt5Methods
};

PyMODINIT_FUNC PyInit_PyQt5(void)
{
    printf("in PyInit\r\n");
    PyObject *mod = PyModule_Create(&PyQt5);
    PyModule_AddObject(mod, "__path__", Py_BuildValue("()"));
    return mod;
}

int
main(int argc, char** argv)
{
  hiwire_setup();

  setenv("PYTHONHOME", "/", 0);

  // Register PyQT modules to Python
  PyImport_AppendInittab("PyQt5", PyInit_PyQt5);
  PyImport_AppendInittab("PyQt5.sip", PyInit_sip);
  PyImport_AppendInittab("PyQt5.Qt", PyInit_QtCore);
  PyImport_AppendInittab("PyQt5.QtCore", PyInit_QtCore);
  PyImport_AppendInittab("PyQt5.QtGui", PyInit_QtGui);
  PyImport_AppendInittab("PyQt5.QtWidgets", PyInit_QtWidgets);
  PyImport_AppendInittab("PyQt5.QtSvg", PyInit_QtSvg);


  Py_InitializeEx(0);

  // This doesn't seem to work anymore, but I'm keeping it for good measure
  // anyway The effective way to turn this off is below: setting
  // sys.done_write_bytecode = True
  setenv("PYTHONDONTWRITEBYTECODE", "1", 0);

  PyObject* sys = PyImport_ImportModule("sys");
  if (sys == NULL) {
    return 1;
  }
  if (PyObject_SetAttrString(sys, "dont_write_bytecode", Py_True)) {
    return 1;
  }
  Py_DECREF(sys);

  // Fix import system to accomendate the shallow PyQt5 mock module
  // Thanks to dgym @ https://stackoverflow.com/questions/39250524/programmatically-define-a-package-structure-in-embedded-python-3
  PyRun_SimpleString(
        "from importlib import abc, machinery \n" \
        "import sys\n" \
        "\n" \
        "class Finder(abc.MetaPathFinder):\n" \
        "    def find_spec(self, fullname, path, target=None):\n" \
        "        if fullname in sys.builtin_module_names:\n" \
        "            return machinery.ModuleSpec(fullname, machinery.BuiltinImporter)\n" \
        "\n" \
        "sys.meta_path.append(Finder())\n" \
  );

  // Create our QApplication inside Python
  PyRun_SimpleString("from PyQt5.QtWidgets import QApplication\nqtApp = QApplication([\"pyodide\"])\n");

  if (js2python_init() || JsImport_init() || JsProxy_init() ||
      pyimport_init() || pyproxy_init() || python2js_init() ||
      runpython_init_js() || runpython_init_py() || runpython_finalize_js()) {
    return 1;
  }

  printf("Python initialization complete\n");

  execLastQApp(); //

  emscripten_exit_with_live_runtime();
  return 0;
}
