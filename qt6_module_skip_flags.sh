qt_modules="qtvirtualkeyboard qtspeech qtimageformats qtdoc qtnetworkauth qtsvg qt5compat qtmqtt qtserialbus qtwebchannel qtwebengine qt3d qtconnectivity qtcoap qthttpserver qtwebsockets qtserialport qtremoteobjects qtdatavis3d qtquick3d qtlottie qtactiveqt qttools qtgrpc qtsensors qtgraphs qtquickeffectmaker qtwayland qttranslations qtlocation qtopcua qtbase qtqa qtscxml qtlanguageserver qtquicktimeline qtmultimedia qtwebview qtshadertools qtdeclarative qtcharts qtpositioning qtquick3dphysics"
qt_modules_to_build=$1

# Convert the qt_modules string to an array
IFS=' ' read -ra qt_modules <<< "$qt_modules"

# Convert the qt_modules_to_build string to an array
IFS=' ' read -ra qt_modules_to_build <<< "$qt_modules_to_build"

# Initialize an empty array for the filtered qt_modules
qt_modules_to_skip=()

# Loop through each module in the qt_modules array
for folder in "${qt_modules[@]}"; do
    # Check if the folder is not in the exclude array
    if [[ ! " ${qt_modules_to_build[@]} " =~ " $folder " ]]; then
        # Add the folder to the qt_modules_to_skip array
        qt_modules_to_skip+=("$folder")
    fi
done

# Join the qt_modules_to_skip with "--skip" and convert to a string
qt_modules_skip_flags=$(printf -- "-skip %s " "${qt_modules_to_skip[@]}")

echo $qt_modules_skip_flags
