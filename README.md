# mumps4matlab_windows_openmp
**Compiling the OpenMP + METIS Parallel MUMPS Solver (Real/Complex Version) for MATLAB using MSYS2/MinGW64 in a Windows Environment**

This has been successfully tested on **Windows 11 with MATLAB 2025a**.

Additionally, a pre-compiled Linux version has been successfully tested on **Ubuntu 24 with MATLAB 2025a**.

The folders `pre_compiled_version_windows` and `pre_compiled_version_linux` provide the pre-compiled versions, which can be run directly in MATLAB.

`README_ENGLISH` and `README_CHINESE` provide detailed compilation procedures. If you need to compile it yourself, please refer to the instructions in these files.

The `src` folder contains the original MUMPS_5.7.2 source files and the configuration files used during the compilation process. You can base your own compilation efforts on the contents of this folder.

The `all_files_compiled` folder contains all the compiled files. If you compile the solver yourself, you can use the contents of this folder for comparison and reference.

The `test` folder provides several test files.
