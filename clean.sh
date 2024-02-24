# clean root directory
git clean -fdx

# clean pyodide
pushd pyodide
git clean -fdx
popd

# clean qt6
pushd qt6
git clean -fdx
git submodule foreach --recursive git clean -fdx
popd
