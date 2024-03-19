# Coral Labeler
This repo tracks the Coral Labeler application, which is in development by Dylan Chapell, Khawla Douah, Mai Nguyen, and Calvin Than. The goal of this application is to streamline the labeling of datasets containing images of corals. It provides manual labeling tools as well as a machine learning model to help predict labels.

# Building the application
## Installing Dependencies
Our application has the following dependencies: 

- Python 3
- PySide6 - Qt (and qt-quick) bindings for python
- numpy - Working with the data structure that holds the labels for each pixel
- Scikit Image - Provides flood fill functionality, as well as image dims
- torch and torchvision - Used to train and run the machine learning model that provides predicted labels
- rdp - Implementation of the Ramer–Douglas–Peucker algorithm to reduce the number of points in a line
- pyinstaller - Packages our application into the format to be distributed
- opencv

To install the dependencies in a virtual environment:
1. Move into the program directory `cd CoralLabeler`

2. Create a virual environment in this directory: `python3 -m venv venv`

3. [Activate the venv](https://docs.python.org/3/library/venv.html#how-venvs-work) if it is not already: 

    - `source venv/bin/activate` on POSIX

    - `venv/bin/activate.bat` on Windows

4. Install the dependencies: `pip install PySide6 scikit-image numpy torch torchvision rdp pyinstaller opencv-python`

If you would like to run the application without building it, you can do so now by running `python3 main.py`

## Compiling with pyinstaller

1. Inspect CoralLabeler.spec to ensure that the build options are set in the way you want. [(pyinstaller documentation)](https://pyinstaller.org/en/stable/spec-files.html)
    - Specifically, make sure all files you want bundled with the application are listed in datas. If you have added another AI descriptor file besides defaultAI.py, it will need to be added here.
2. Run `pyinstaller CoralLabeler.spec`

The compiled application will now be in the `./dist/CoralLabeler` directory. 
