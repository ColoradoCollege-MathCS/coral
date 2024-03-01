#!/usr/bin/env bash

#Check that python3 is < v12 or python3.11 exists
#Get minor version from string Python 3.xx.xx
pyt3_out=$(python3 --version)
IFS='.'
read -ra vers_arr <<< "$pyt3_out"
py3_minor_vers=${vers_arr[1]}


if [ ! type "$python3.11" > /dev/null ]; then
    python_command="python3.11"
elif [ py3_minor_vers < 12 ]; then
    python_command="python3"
else
    echo "python3.11 is not installed and the default python3 is 3.12 or greater, which is incompatible with torch. The application cannot be built."
    exit 1
fi

#This script should be run from inside the CoralLabeler directory
if [ ! -d "$venv" ]; then
    #Create the venv
    eval "$python_command -v venv venv"
fi

source venv/bin/activate
echo "Installing dependencies"
pip install PySide6 scikit-image numpy torch torchvision rdp pyinstaller opencv-python

echo
echo "Building Application"
pyinstaller CoralLabeler.spec

if [ ? != 0 ]; then
    echo "Something went wrong with pyinstaller. Cancelling build"
    exit 2
fi

if [ ! type "create-dmg" > /dev/null ]; then
    echo
    echo "create-dmg command not available. The .app package has been created in dist/"
    echo "If you would like the dmg also, please install create-dmg (easiest through homebrew)"
    exit 3
fi
echo
echo "Building dmg"

test -f "dist/CoralLabeler.dmg" && rm "dist/CoralLabeler.dmg"
test -d "build/dmg" && rm -rf "build/dmg"
cp -r "dist/CoralLabeler.app" "build/dmg"

#When I get the icon, add the icon options"
create-dmg \
    --volname "CoralLabler" \
    --window-pos 200 120 \
    --window-size 800 400 \
    --icon-size 100 \
    --icon "CoralLabeler.app" \
    --app-drop-link 600 185 \
    "dist/CoralLabeler.dmg" \
    "build/dmg/"