# packaging
```
pip wheel .
```

# use with pyodide
```
# install app
import micropip
await micropip.install('http://localhost:8000/examples/multifile_app
/app-1.0-py3-none-any.whl')

# import and execute app
import app
app.execute()
```