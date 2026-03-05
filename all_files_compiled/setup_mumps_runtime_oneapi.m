function setup_mumps_runtime_oneapi()
% SETUP_MUMPS_RUNTIME_ONEAPI Prepares Intel oneAPI 2025 DLLs for MUMPS MEX
    clc;
    fprintf('======================================================\n');
    fprintf('    MUMPS Runtime Setup: Intel oneAPI 2025 + VS2022    \n');
    fprintf('======================================================\n');

    % 1. Define OneAPI Base Path (Default installation)
    oneapi_root = 'C:\OPT\Intel\oneAPI';
    
    % 2. Build search paths for Compiler and MKL runtimes
    % oneAPI 2025 typically uses the "latest" symlink or specific version folders
    search_paths = {
        fullfile(oneapi_root, 'compiler', '2025.3', 'bin'), ...
        fullfile(oneapi_root, 'mkl', '2025.3', 'bin'), ...
        fullfile(oneapi_root, 'tbb', '2025.3', 'bin')
    };

    % 3. Define Intel-specific DLLs (Replaces gfortran/openblas)
    % libmmd: Math library
    % libifcoremd: Fortran core
    % libiomp5md: OpenMP
    % mkl_rt: The single dynamic library for MKL (replaces openblas)
    required_dlls = {
        'libmmd.dll', ...
        'libifcoremd.dll', ...
        'libifportmd.dll', ...
        'libiomp5md.dll', ...
        'svml_dispmd.dll', ...
        'mkl_rt.2.dll', ...   % Note: 2025 versioning often includes .2
        'mkl_core.2.dll', ...
        'mkl_intel_thread.2.dll', ...
        'mkl_sequential.2.dll', ...
        'mkl_avx2.2.dll', ...
        'tbb12.dll'
    };

    % 4. Execute copy operation
    count = 0;
    for p = 1:length(search_paths)
        current_dir = search_paths{p};
        if ~exist(current_dir, 'dir'), continue; end
        
        fprintf('Searching in: %s\n', current_dir);
        
        for i = 1:length(required_dlls)
            % Handle potential version wildcards if necessary
            target_name = required_dlls{i};
            src_file = fullfile(current_dir, target_name);
            
            if exist(src_file, 'file')
                dest_file = fullfile(pwd, target_name);
                try
                    copyfile(src_file, dest_file);
                    fprintf('  [Success] Copied: %s\n', target_name);
                    count = count + 1;
                catch ME
                    fprintf('  [Error] Failed to copy %s: %s\n', target_name, ME.message);
                end
            end
        end
    end

    if count == 0
        warning('No DLLs were copied. Check if "latest" links exist in %s', oneapi_root);
    else
        fprintf('------------------------------------------------------\n');
        fprintf('Setup Complete. Copied %d Intel runtime DLLs.\n', count);
    end
end