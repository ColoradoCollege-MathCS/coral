# Coral Labeler Prototype
This version of the Coral Labeler application was created by Dylan Chapell to 
test the overlaying of masks onto source images

## Dependencies
PySide6 - Qt (and qt-quick) bindings for python
numpy - Working with the data structure that holds the labels for each pixel
Scikit Image - Provides flood fill functionality, as well as image dims

Create a virual environment in this directory: `python3 -m venv venv`

[Activate the venv](https://docs.python.org/3/library/venv.html#how-venvs-work) if it is not already: 

`source venv/bin/activate` on POSIX

`venv/bin/activate.bat` on Windows

Install the dependencies: `pip install PySide6 scikit-image numpy`


### File dependencies
Right now the program needs 2 test images to run: a Larry Fisherman album cover 
that is the source image, and mask2.png which is quickly switched to in order to
refresh mask.png when neccesary. These images will eventually be removed but are
provided for convinence.

## File List
- README.md: This file
- main.py: bootstrap code to create the QML application window and associate the Toolbox.
- main.qml: QML code to define the elements of the window as well as interaction logic
- toolbox.py: Contains a QObject signal handler with methods exposed to QML allowing the GUI to control the labelling datastructure
- select_tools.py: Contains functions for the 4 selection tools, as well as a function that converts from a numpy array of labels to an array of RGB values

