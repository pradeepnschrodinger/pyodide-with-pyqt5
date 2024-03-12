

### [FIXED] The pyodide version used here is pretty old, and does not have the pyodide.unpackArchive API.
Find an alternative so that we have a way of importing our app bundle.

### [FIX] Use pyodide v0.24.1

------------

### [FIXED] The entire build process took 29958s or ~8.3hours...
Most of the time was spent on cloning, perl-initiating, and compiling the QT5 repo.
Checkout timings at "./logs/time-Thu Feb  8 03:58:06 AM IST 2024.log"

### [FIX] As long as the qt5 repo directory isn't removed, we should be good.
Use `git clean -fdxf ` instead for a faster reset.

------------

### [FIXED] After building pyodide, there seems to be errors with an npm command
```
Error running ['/home/pradeep/projects/pyodide-with-pyqt5/pyodide/emsdk/emsdk/node/8.9.1_64bit/bin/npm', 'ci', '--production', '--no-optional']:
```

I might have to checkout out emsdk from Nov 26, 2020

### [FIX] 
Checkout 0.v.24.1 version of emsdk by modifying emsdk/Makefile
```
git checkout bda1ba4edf6e4140952c5596e4af47521d21f7eb #v0.24.1
```

------------