# Coral Labeler
This repo tracks the Coral Labeler application, which is in development by Dylan Chapell, Khawla Douah, Mai Nguyen, and Calvin Than. The goal of this application is to streamline the labeling of datasets containing images of corals. It provides manual labeling tools as well as a machine learning model to help predict labels.

## Dependencies
- Python 3
- PySide6 - Qt (and qt-quick) bindings for python
- numpy - Working with the data structure that holds the labels for each pixel
- Scikit Image - Provides flood fill functionality, as well as image dims

### Running the application
These instructions are to run the application while it is in develoment, and will be different when distributed to end users.

1. Move into the program directory `cd CoralLabeler`

2. Create a virual environment in this directory: `python3 -m venv venv`

3. [Activate the venv](https://docs.python.org/3/library/venv.html#how-venvs-work) if it is not already: 

    - `source venv/bin/activate` on POSIX

    - `venv/bin/activate.bat` on Windows

4. Install the dependencies: `pip install PySide6 scikit-image numpy`

5. Run the program: `python3 main.py`

