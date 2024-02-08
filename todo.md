
------------

The pyodide version used here is pretty old, and does not have the pyodide.unpackArchive API.
Find an alternative so that we have a way of importing our app bundle.

------------

The entire build process took 29958s or ~8.3hours...
Most of the time was spent on cloning, perl-initiating, and compiling the QT5 repo.
Checkout timings at "./logs/time-Thu Feb  8 03:58:06 AM IST 2024.log"

------------

[FIXED] After building pyodide, there seems to be errors with an npm command
```
Error running ['/home/pradeep/projects/pyodide-with-pyqt5/pyodide/emsdk/emsdk/node/8.9.1_64bit/bin/npm', 'ci', '--production', '--no-optional']:
```

I might have to checkout out emsdk from Nov 26, 2020

------------