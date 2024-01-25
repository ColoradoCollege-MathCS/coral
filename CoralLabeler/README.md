# Coral Labeler Prototype
This version of the Coral Labeler application was created by Dylan Chapell to 
test the overlaying of masks onto source images

## Dependencies
PySide6 - Qt (and qt-quick) bindings for python
numpy - Working with the data structure that holds the labels for each pixel
Scikit Image - Provides flood fill functionality, as well as image dims

Create a virual environment in this directory:
`python3 -m venv venv`
Activate the venv if it is not already:
`source venv/bin/activate`
Install the dependencies:
`pip install PySide6 scikit-image numpy`

### File dependencies
Right now the program needs 2 test images to run: a Larry Fisherman album cover 
that is the source image, and mask2.png which is quickly switched to in order to
refresh mask.png when neccesary. These images will eventually be removed but are
provided for convinence.