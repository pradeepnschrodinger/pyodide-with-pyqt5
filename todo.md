last command:

(.venv-native) pradeep@pradeep-ubuntu-vm:~/projects/pyodide-with-pyqt5/pyqt6-wasm-build$ make &> ../logs/pyqt6-wasm-make.log


------------

pyqt6 make troubles

/home/pradeep/projects/pyodide-with-pyqt5/pyqt6-wasm-build/QtCore/sipQtCorecmodule.cpp:9017:30: error: no member named 'NameType' in 'QTimeZone'
    qMetaTypeId<::QTimeZone::NameType>();
                ~~~~~~~~~~~~~^
/home/pradeep/projects/pyodide-with-pyqt5/pyqt6-wasm-build/QtCore/sipQtCorecmodule.cpp:9018:30: error: no member named 'TimeType' in 'QTimeZone'
    qMetaTypeId<::QTimeZone::TimeType>();

^ Seems like the above errors are coming because qtimezone.h has
#if QT_CONFIG(timezone)
There's a high chance this is not defined?

checkout /home/pradeep/projects/pyodide-with-pyqt5/qt6/qtbase/src/corelib/qtcore-config.h where they have explicitly disabled timezone

------------

[FIXED] The pyodide version used here is pretty old, and does not have the pyodide.unpackArchive API.
Find an alternative so that we have a way of importing our app bundle.

Use pyodide v0.24.1

------------

[FIXED] The entire build process took 29958s or ~8.3hours...
Most of the time was spent on cloning, perl-initiating, and compiling the QT5 repo.
Checkout timings at "./logs/time-Thu Feb  8 03:58:06 AM IST 2024.log"

As long as the qt5 repo directory isn't removed, we should be good.
Use `git clean -fdxf ` instead for a faster reset.

------------

[FIXED] After building pyodide, there seems to be errors with an npm command
```
Error running ['/home/pradeep/projects/pyodide-with-pyqt5/pyodide/emsdk/emsdk/node/8.9.1_64bit/bin/npm', 'ci', '--production', '--no-optional']:
```

I might have to checkout out emsdk from Nov 26, 2020

------------