function build_mumps_metis_oneapi(target_arith)
    % =====================================================================
    % MUMPS + METIS Build Script for Intel oneAPI (MSVC-compatible)
    % Built against MUMPS 5.8.2 from mumps-superbuild with Intel oneAPI
    %
    % Prerequisites:
    %   - MUMPS 5.8.2 built via mumps-superbuild with Intel oneAPI
    %   - Intel oneAPI 2025.3 installed (compiler + MKL)
    %   - MATLAB mex configured for MSVC or Intel C compiler
    %   - Runtime DLLs copied via setup_mumps_runtime_oneapi.m
    %
    % Usage: build_mumps_metis_oneapi('d') or build_mumps_metis_oneapi('z')
    % =====================================================================

    if nargin < 1, target_arith = 'd'; end
    target_arith = lower(target_arith);

    % =====================================================================
    % 1. Configuration — Adjust these paths for your environment
    % =====================================================================

    % MUMPS superbuild root (where you ran cmake --build)
    superbuild_root = 'D:\trash\mumps-superbuild-5.8.2.0';
    build_dir       = fullfile(superbuild_root, 'build_mex');

    % Intel oneAPI paths
    oneapi_root      = 'C:\OPT\Intel\oneAPI';
    oneapi_compiler  = fullfile(oneapi_root, 'compiler', '2025.3');
    mkl_root         = fullfile(oneapi_root, 'mkl', 'latest');

    % =====================================================================
    % 2. Derived Paths
    % =====================================================================
    mumps_src     = fullfile(build_dir, 'mumps_upstream-src');
    mumps_include = fullfile(mumps_src, 'include');
    mumps_srcdir  = fullfile(mumps_src, 'src');
    pord_include  = fullfile(mumps_src, 'PORD', 'include');
    matlab_dir    = fullfile(mumps_src, 'MATLAB');
    lib_dir       = fullfile(build_dir, 'Release');

    metis_src_root = fullfile(superbuild_root, 'parmetis', 'METIS');
    metis_lib_dir  = fullfile(build_dir, 'parmetis', 'METIS', 'Release');
    gklib_lib_dir  = fullfile(build_dir, 'parmetis', 'METIS', 'GKlib', 'Release');

    oneapi_lib_dir = fullfile(oneapi_compiler, 'lib');
    mkl_lib_dir    = fullfile(mkl_root, 'lib');

    % =====================================================================
    % 3. Validate Critical Paths
    % =====================================================================
    check_paths = {
        mumps_include, 'MUMPS include dir';
        matlab_dir,    'MUMPS MATLAB source dir';
        lib_dir,       'MUMPS library dir (Release)';
        metis_lib_dir, 'METIS library dir';
        gklib_lib_dir, 'GKlib library dir';
        oneapi_lib_dir,'Intel oneAPI compiler lib dir';
        mkl_lib_dir,   'Intel MKL lib dir';
    };
    for i = 1:size(check_paths, 1)
        if ~exist(check_paths{i,1}, 'dir')
            error('Path not found: %s\n  (%s)\n  Please check your configuration.', ...
                check_paths{i,1}, check_paths{i,2});
        end
    end

    % =====================================================================
    % 4. Configure Target
    % =====================================================================
    if strcmp(target_arith, 'd')
        macro_arith = '-DMUMPS_ARITH=MUMPS_ARITH_d';
        output_name = 'dmumpsmex';
        fprintf('>>> Target: Double Precision Real (dmumpsmex) + METIS\n');
    elseif strcmp(target_arith, 'z')
        macro_arith = '-DMUMPS_ARITH=MUMPS_ARITH_z';
        output_name = 'zmumpsmex';
        fprintf('>>> Target: Double Precision Complex (zmumpsmex) + METIS\n');
    else
        error('Unsupported argument: "%s". Use ''d'' or ''z''.', target_arith);
    end

    % =====================================================================
    % 5. Construct MEX Command
    % =====================================================================
    mex_cmd = 'mex -v';

    % Macro definitions
    % -DUPPER: Intel Fortran on Windows uses UPPERCASE symbol names
    % -Dmetis: Enable METIS ordering in the C interface
    cflags_str = sprintf('-D_WIN32 -DWIN32 %s -DUPPER -Dmetis', macro_arith);
    mex_cmd = [mex_cmd ' ' cflags_str];

    % OpenMP: use /openmp for MSVC, -Qiopenmp for Intel icx-cl
    % Default to MSVC compatible. Change to -Qiopenmp if using Intel compiler.
    mex_cmd = [mex_cmd ' COMPFLAGS="$COMPFLAGS /openmp"'];

    % Include paths
    include_dirs = {
        mumps_include, ...
        mumps_srcdir, ...
        pord_include, ...
        fullfile(metis_src_root, 'include'), ...
        fullfile(metis_src_root, 'GKlib'), ...
        fullfile(metis_src_root, 'libmetis')
    };
    for i = 1:length(include_dirs)
        mex_cmd = [mex_cmd ' -I"' include_dirs{i} '"'];
    end

    % Source file (only mumpsmex.c — mumps_c.c is already in the MUMPS libs)
    mex_source = fullfile(matlab_dir, 'mumpsmex.c');
    if ~exist(mex_source, 'file')
        error('MEX source not found: %s', mex_source);
    end
    mex_cmd = [mex_cmd ' "' mex_source '"'];

    % =====================================================================
    % 6. Libraries to Link
    % =====================================================================

    % MUMPS libraries (from build_mex/Release)
    mumps_libs = {
        fullfile(lib_dir, 'dmumps.lib'), ...
        fullfile(lib_dir, 'zmumps.lib'), ...
        fullfile(lib_dir, 'mumps_common.lib'), ...
        fullfile(lib_dir, 'pord.lib'), ...
        fullfile(lib_dir, 'mpiseq_c.lib'), ...
        fullfile(lib_dir, 'mpiseq_fortran.lib')
    };

    % METIS + GKlib
    metis_libs = {
        fullfile(metis_lib_dir, 'metis.lib'), ...
        fullfile(gklib_lib_dir, 'GKlib.lib')
    };

    % Intel MKL (LP64 sequential — matches the superbuild configuration)
    mkl_libs = {
        fullfile(mkl_lib_dir, 'mkl_intel_lp64_dll.lib'), ...
        fullfile(mkl_lib_dir, 'mkl_sequential_dll.lib'), ...
        fullfile(mkl_lib_dir, 'mkl_core_dll.lib')
    };

    % Intel Fortran runtime + OpenMP (required for symbols in MUMPS .lib)
    intel_rt_libs = {
        fullfile(oneapi_lib_dir, 'libifcoremd.lib'), ...
        fullfile(oneapi_lib_dir, 'libmmd.lib'), ...
        fullfile(oneapi_lib_dir, 'libiomp5md.lib'), ...
        fullfile(oneapi_lib_dir, 'svml_dispmd.lib'), ...
        fullfile(oneapi_lib_dir, 'libirc.lib')
    };

    % System libraries
    sys_libs = {'kernel32.lib', 'user32.lib'};

    % Validate all library files exist
    all_libs = [mumps_libs, metis_libs, mkl_libs, intel_rt_libs];
    for i = 1:length(all_libs)
        if ~exist(all_libs{i}, 'file')
            error('Library not found: %s', all_libs{i});
        end
    end

    % Append all libraries to mex command
    link_libs = [mumps_libs, metis_libs, mkl_libs, intel_rt_libs, sys_libs];
    for i = 1:length(link_libs)
        mex_cmd = [mex_cmd ' "' link_libs{i} '"'];
    end

    % Output name
    mex_cmd = [mex_cmd ' -output ' output_name];

    % =====================================================================
    % 7. Execute Compilation
    % =====================================================================
    fprintf('--------------------------------------------------\n');
    fprintf('Executing MEX compilation...\n');
    fprintf('--------------------------------------------------\n');
    disp(mex_cmd);
    fprintf('--------------------------------------------------\n');

    try
        eval(mex_cmd);
        fprintf('\n======== Compilation Successful! Output: %s.%s ========\n', ...
            output_name, mexext);
        fprintf('Hint: Set ICNTL(7)=5 in your solver script to use METIS ordering.\n');
    catch ME
        fprintf('\n======== Compilation Failed! ========\n');
        fprintf('Troubleshooting tips:\n');
        fprintf('  1. Run "mex -setup C" to verify your C compiler configuration\n');
        fprintf('  2. If using Intel icx-cl, change /openmp to -Qiopenmp in script\n');
        fprintf('  3. Ensure Intel oneAPI environment is initialized (setvars.bat)\n');
        fprintf('  4. Run setup_mumps_runtime_oneapi.m to copy runtime DLLs\n');
        rethrow(ME);
    end
end
