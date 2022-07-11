

https://medium.com/swlh/setting-up-a-conda-environment-in-less-than-5-minutes-e64d8fc338e4


For Mac OS M1 use [Miniforge](https://github.com/conda-forge/miniforge)


Running tests requires an installed miniconda environment or similar

> conda create -n firmware python=3.7
> conda activate firmware
> conda install tensorflow opencv
> conda env export > firmware.yml
> conda info --envs


> conda deactivate


Test calibration with Open CV

> opencv_version
> opencv_interactive-calibration


Should show checkerboard image:

> python ./opencv_test/calibrate.py