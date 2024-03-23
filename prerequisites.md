sudo apt install -y curl

#
# PYODIDE + EMSDK
#

# required to create virtual environment for python
sudo apt-get install -y python3.10-venv

# The build process for pyodide requires 3.8 version of python.
# It did not work for python 3.10 for whatever reason.
#
# If your system doesn't have 3.8, then clone CPython and checkout v3.8.2
# Build and install cpython after configuring with the --prefix flag.
```
cd <cpython-root>
git checkout v3.8.2
./configure --prefix ./configure --prefix /home/pradeep/projects/cpython/pradeep/3.8.2
make
make install
```

# Once this is done, activate a virtualenv for python 3.8 via:
```
~/projects/cpython/pradeep/3.8.2/bin/python3 -m venv env
source env/bin/activate
pip install pyyaml
```

Install build dependencies:
```
sudo apt-get install -y libffi-dev gfortran uglifyjs make pkg-config npm cmake
sudo apt install -y zlib1g 
sudo apt install -y zlib1g-dev

sudo npm install -g less
```
