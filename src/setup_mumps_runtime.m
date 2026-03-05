function setup_mumps_runtime()
% SETUP_MUMPS_RUNTIME Automatically prepares DLL dependencies required for MUMPS MEX runtime
% This script copies necessary runtime libraries from the MSYS2/MinGW64 bin directory to the current folder.

    clc;
    fprintf('======================================================\n');
    fprintf('       MUMPS Runtime Environment Setup Tool           \n');
    fprintf('======================================================\n');

    % 1. Define possible MSYS2 installation paths (Adjust based on your environment)
    % Typically C:\msys64\ucrt64\bin or C:\msys64\mingw64\bin
    % Your previous compilation used the UCRT64 environment
    search_paths = {
        'C:\msys64\ucrt64\bin', ...
        'C:\msys64\mingw64\bin', ...
        'D:\msys64\ucrt64\bin', ...
        'C:\Program Files\Git\mingw64\bin' 
    };

    % 2. Find a valid bin directory
    msys_bin_path = '';
    for i = 1:length(search_paths)
        if exist(search_paths{i}, 'dir')
            % Check for key files to confirm path validity
            if exist(fullfile(search_paths{i}, 'libgfortran-5.dll'), 'file') || ...
               exist(fullfile(search_paths{i}, 'libgfortran-4.dll'), 'file')
                msys_bin_path = search_paths{i};
                break;
            end
        end
    end

    if isempty(msys_bin_path)
        error(['Error: Could not automatically locate the MSYS2/MinGW bin directory.\n' ...
               'Please manually modify the search_paths variable in the script to point to your msys64/ucrt64/bin path.']);
    else
        fprintf('Toolchain path found: %s\n', msys_bin_path);
    end

    % 3. Define the list of required DLLs to copy
    % These are dependencies typically required for MinGW GCC + OpenBLAS + OpenMP compilation
    required_dlls = {
        'libgfortran-*.dll', ... % Wildcard matches version number (e.g., libgfortran-5.dll)
        'libquadmath-*.dll', ...
        'libopenblas.dll',   ... % Or libopenblas*.dll
        'libgomp-*.dll',     ... % OpenMP core library
        'libgcc_s_seh-*.dll',... % GCC exception handling
        'libwinpthread-*.dll',...% Windows threading library
        'libstdc++-*.dll'    ... % C++ standard library (sometimes required)
    };

    % 4. Execute copy operation
    count = 0;
    fprintf('Starting to copy dependency files...\n');
    
    for i = 1:length(required_dlls)
        pattern = required_dlls{i};
        full_pattern = fullfile(msys_bin_path, pattern);
        
        % Search for matching files
        files = dir(full_pattern);
        
        if isempty(files)
            % Try searching again without wildcard (for files without version number)
            clean_name = strrep(pattern, '-*', '');
            if exist(fullfile(msys_bin_path, clean_name), 'file')
                files = dir(fullfile(msys_bin_path, clean_name));
            end
        end

        if isempty(files)
            fprintf('  [Warning] Not found: %s (May not be needed or name is different)\n', pattern);
        else
            for k = 1:length(files)
                src_file = fullfile(files(k).folder, files(k).name);
                dest_file = fullfile(pwd, files(k).name);
                
                % Check if already exists and is up-to-date
                copy_flag = true;
                if exist(dest_file, 'file')
                    d_info = dir(dest_file);
                    % Skip if file size and modification time are consistent
                    if d_info.bytes == files(k).bytes && d_info.datenum >= files(k).datenum
                        copy_flag = false;
                        % fprintf('  [Skipped] Already exists: %s\n', files(k).name);
                    end
                end
                
                if copy_flag
                    try
                        copyfile(src_file, dest_file);
                        fprintf('  [Success] Copied: %s\n', files(k).name);
                        count = count + 1;
                    catch ME
                        fprintf('  [Error] Failed to copy: %s (%s)\n', files(k).name, ME.message);
                    end
                end
            end
        end
    end

    fprintf('------------------------------------------------------\n');
    if count > 0
        fprintf('Successfully copied %d DLL files.\n', count);
    else
        fprintf('All dependency files seem to exist, no update needed.\n');
    end
    
    % 5. Final check
    fprintf('Current directory DLL list:\n');
    ls('*.dll');
    
    disp('Environment ready. You can now run the test script.');
end