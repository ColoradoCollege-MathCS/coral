# define python module name to be used for AI magic wand
module_name = 'defaultAI'


"""
pipeline_function(image_path: str, seed: Tuple[int, int]) -> np.ndarray

Defines the pipeline for identifying the area of interest using a Pytorch model.

    Args:
        image_path (str): The path of the image.
        seed (Tuple[int, int]): A tuple representing the coordinates (x, y) of the seed pixel selected by the user.

    Returns:
        np.ndarray: A 2D boolean array where True represents pixels of interest and False represents background.

    Note:
        The processing steps, the PyTorch model used, and the interpretation of model outputs
        to obtain the area of interest are left to the user's discretion.

"""

# define pipeline
pipeline = "default_pred" # default_pred(image path, seed)