IFS=$'\n'; set -f
for file in $(find ~/projects/pyodide-with-pyqt5 -name '*.pdf' -or -name '*.doc'); do
    if [[ "$file" =~ \.a ]]; then
        echo "Processing library file: $file"
        nm -A "$file" | echo
        # echo "---------------------------------------------"
    fi    
done