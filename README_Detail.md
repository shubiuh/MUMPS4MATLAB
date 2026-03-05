# MUMPS for MATLAB Compilation Technical Report (Windows/MSYS2)

**Environment:** Windows 11, MATLAB 2025a, MSYS2 (UCRT64/MinGW64) **Objective:** Compile the MUMPS solver (Real/Complex versions) with support for OpenMP multithreading and METIS ordering.

[toc]

## 1. Environment Setup (Prerequisites)

### 1.1 Install MSYS2 Toolchain

Do not use Visual Studio (MSVC), as it poorly supports Fortran and complex Makefiles. Please use the **MSYS2 UCRT64** environment.

Run the following commands in the MSYS2 terminal to install the compiler, math libraries, and METIS:

```
pacman -S mingw-w64-ucrt-x86_64-gcc
pacman -S mingw-w64-ucrt-x86_64-gcc-fortran
pacman -S mingw-w64-ucrt-x86_64-make
pacman -S mingw-w64-ucrt-x86_64-openblas
pacman -S mingw-w64-ucrt-x86_64-metis
```

### 1.2 Configure MUMPS `Makefile.inc`

In the MUMPS source root directory, copy `Make.inc/Makefile.inc.generic` to `Makefile.inc` and modify the following key sections:

1. **Enable OpenMP and METIS Macros:**

   ```
   # Add -fopenmp to compiler options
   OPTF    = -O -fopenmp
   OPTC    = -O -fopenmp
   OPTL    = -O -fopenmp
   
   # Add -Dmetis to ordering options
   ORDERINGSF  = -Dpord -Dmetis
   ```

2. **Specify METIS Path (MSYS2 Default):**

   ```
   # Note: Paths must use Unix format
   LMETISDIR   = /c/msys64/ucrt64/lib
   IMETIS      = -I/c/msys64/ucrt64/include
   # Link the static library directly
   LMETIS      = $(LMETISDIR)/libmetis.a
   ```

3. **Specify BLAS (OpenBLAS):**

   ```
   LIBBLAS = -lopenblas
   ```

4. **Use Pseudo-MPI (Sequential):**

   ```
   LIBSEQ      = ../libseq/libmpiseq.a
   INCPAR      = -I../libseq
   LIBPAR      = $(LIBSEQ)
   ```

### 1.3 Compile Static Libraries

In the MSYS2 terminal, execute:

```
# First compile the pseudo-MPI library
cd libseq && make && cd ..

# Clean and compile main libraries
make clean
make d  # Compile Double Precision Real (Generates libdmumps.a)
make z  # Compile Double Precision Complex (Generates libzmumps.a)
```

## 2. MATLAB Compilation Script (Build Script)

This is the final successfully debugged build script. It resolves symbol naming conflicts, static library circular dependencies, METIS integration, and path spacing issues.

Run `build_mumps_metis.m` after running `mex -setup` in MATLAB to configure the C, C++, and Fortran compilers to the MSYS64 GCC.

If MATLAB cannot find the MSYS64 GCC, or if setting it up fails, first delete the `MATLAB Support for MinGW-w64 C/C++/Fortran Compiler` downloaded by the MATLAB toolbox. Then, add the environment variable `MW_MINGW64_LOC` to your computer's environment variables, setting it to `C:\msys64\ucrt64` (the installation path of `msys64\ucrt64`), and restart MATLAB.

**Script Features:**

- **Automatic Path Management:** Adds the source path before running and cleans it up afterward.
- **Intelligent Symbol Detection:** Automatically detects the Fortran symbol format (`dmumps_f77` vs `dmumps_f77_`).
- **METIS Integration:** Automatically links the METIS static library.
- **Forced Repeat Linking:** Solves circular dependencies between `libdmumps` and `libcommon`.

```
function build_mumps_metis(target_arith)
    % =====================================================================
    % MUMPS + METIS Build Script (V6.0 Final)
    % Usage: build_mumps_metis('d') [Real] or build_mumps_metis('z') [Complex]
    % =====================================================================

    if nargin < 1, target_arith = 'd'; end
    target_arith = lower(target_arith);
    
    % --- 1. Path Management and Environment Setup ---
    mumps_folder_name = 'MUMPS_5.7.2'; % Ensure this folder is in the current directory
    mumps_root = fullfile(pwd, mumps_folder_name);
    
    if ~exist(mumps_root, 'dir')
        error('Error: Folder "%s" not found in the current directory. Please check the path.', mumps_folder_name);
    end
    
    fprintf('--------------------------------------------------\n');
    fprintf('Initializing paths...\n');
    addpath(genpath(mumps_root));
    % Use onCleanup to ensure path cleanup upon script termination or error
    cleanupObj = onCleanup(@() restore_path(mumps_root));

    % MSYS2 Configuration (Modify based on actual installation location)
    msys_root = 'C:\msys64\ucrt64'; 
    msys_lib_path = fullfile(msys_root, 'lib');
    matlab_mingw_path = fullfile(matlabroot, 'extern', 'lib', 'win64', 'mingw64');
    
    % Locate nm tool
    nm_exe = fullfile(msys_root, 'bin', 'nm.exe');
    if ~exist(nm_exe, 'file')
        [status, ~] = system('nm --version');
        if status == 0, nm_exe = 'nm'; else, error('nm.exe not found'); end
    end

    % --- 2. Configure Target Variables ---
    if strcmp(target_arith, 'd')
        lib_name_main = 'libdmumps.a';
        macro_arith   = '-DMUMPS_ARITH=MUMPS_ARITH_d';
        symbol_grep   = 'dmumps_f77';
        output_name   = 'dmumpsmex';
        fprintf('>>> Target: Double Precision Real (Real) + METIS\n');
    elseif strcmp(target_arith, 'z')
        lib_name_main = 'libzmumps.a';
        macro_arith   = '-DMUMPS_ARITH=MUMPS_ARITH_z';
        symbol_grep   = 'zmumps_f77';
        output_name   = 'zmumpsmex';
        fprintf('>>> Target: Double Precision Complex (Complex) + METIS\n');
    else
        error('Unsupported argument: %s', target_arith);
    end

    % --- 3. Prepare MATLAB Dependency Libraries (Copy MATLAB lib) ---
    matlab_libs = {'libmx.lib', 'libmex.lib', 'libmat.lib'};
    for i = 1:length(matlab_libs)
        src = fullfile(matlab_mingw_path, matlab_libs{i});
        dest = fullfile(pwd, matlab_libs{i});
        if ~exist(dest, 'file'), copyfile(src, dest); end
    end

    % --- 4. Intelligent Symbol Diagnostics ---
    lib_main_path = fullfile(mumps_root, 'lib', lib_name_main);
    if ~exist(lib_main_path, 'file')
        error('Static library %s not found. Please run "make %s" in MSYS2 first.', lib_name_main, target_arith);
    end

    fprintf('Diagnosing symbols: %s\n', lib_main_path);
    cmd = sprintf('"%s" -g "%s" | findstr /I "%s"', nm_exe, lib_main_path, symbol_grep);
    [status, cmdout] = system(cmd);
    
    add_macro = '-DAdd_'; % Default strategy
    if status == 0 && ~isempty(cmdout)
        if contains(cmdout, [symbol_grep '__']), add_macro = '-DAdd__';
        elseif contains(cmdout, [symbol_grep '_']), add_macro = '-DAdd_';
        elseif contains(cmdout, symbol_grep), add_macro = ''; 
        elseif contains(cmdout, upper(symbol_grep)), add_macro = '-DUPPER';
        end
    end
    fprintf('>>> Determined macro: %s\n', add_macro);

    % --- 5. Construct MEX Command ---
    mex_cmd = 'mex -v -g';
    
    % Macro definitions (-Dmetis informs the C interface)
    cflags_str = sprintf('-D_WIN32 %s %s -Dmetis', macro_arith, add_macro);
    mex_cmd = [mex_cmd ' ' cflags_str];
    mex_cmd = [mex_cmd ' CFLAGS="$CFLAGS -fopenmp" LDFLAGS="$LDFLAGS -fopenmp"'];
    
    % Include paths
    include_dirs = {
        fullfile(mumps_root, 'include'), ...
        fullfile(mumps_root, 'libseq'), ...
        fullfile(mumps_root, 'PORD', 'include'), ...
        fullfile(mumps_root, 'src')
    };
    for i = 1:length(include_dirs)
        mex_cmd = [mex_cmd ' -I"' include_dirs{i} '"'];
    end
    
    % Source files (mumpsmex.c + mumps_c.c for C interface bridging)
    sources = {
        fullfile(mumps_root, 'MATLAB', 'mumpsmex.c'), ...
        fullfile(mumps_root, 'src', 'mumps_c.c')
    };
    for i = 1:length(sources)
        mex_cmd = [mex_cmd ' "' sources{i} '"'];
    end
    
    % --- Linking Strategy: Forced Repeat Linking + METIS ---
    % Path normalization (prevent backslash escape issues)
    l_main   = strrep(lib_main_path, '\', '/');
    l_common = strrep(fullfile(mumps_root, 'lib', 'libmumps_common.a'), '\', '/');
    l_seq    = strrep(fullfile(mumps_root, 'libseq', 'libmpiseq.a'), '\', '/');
    l_pord   = strrep(fullfile(mumps_root, 'PORD', 'lib', 'libpord.a'), '\', '/');
    l_metis  = strrep(fullfile(msys_lib_path, 'libmetis.a'), '\', '/');
    
    if ~exist(l_metis, 'file')
        error('METIS library not found: %s\nPlease run: pacman -S mingw-w64-ucrt-x86_64-metis', l_metis);
    end

    % Construct linking string: Repeat CORE libraries for circular dependency
    mumps_link_str = sprintf('%s %s %s %s %s %s %s', ...
        l_main, l_common, l_seq, l_pord, l_main, l_common, l_metis);
    
    % System libraries
    l_msys = strrep(msys_lib_path, '\', '/');
    sys_libs = sprintf('-L. -llibmx -llibmex -llibmat -L%s -lgfortran -lquadmath -lopenblas -lgomp -lmingw32 -lkernel32 -lm', l_msys);
    
    % Put into LINKLIBS
    mex_cmd = [mex_cmd ' LINKLIBS="' mumps_link_str ' ' sys_libs '"'];
    mex_cmd = [mex_cmd ' -output ' output_name];

    % --- 6. Execute ---
    fprintf('--------------------------------------------------\n');
    fprintf('Executing compilation...\n');
    disp(mex_cmd); 
    
    try
        eval(mex_cmd);
        fprintf('\n\n======== Compilation Successful! Output file: %s.%s ========\n', output_name, mexext);
        delete('libmx.lib'); delete('libmex.lib'); delete('libmat.lib');
        fprintf('Hint: Ensure ICNTL(7)=5 is set in your test code to use METIS.\n');
    catch ME
        fprintf('\n\n======== Compilation Failed! ========\n');
        rethrow(ME);
    end
end

function restore_path(p)
    fprintf('Cleaning up path (removing %s)...\n', p);
    rmpath(genpath(p));
end
```

## 3. Runtime Environment Setup

The compiled MEX file depends on MSYS2 Dynamic Link Libraries (DLLs). Please ensure the following DLL files are in the same directory as the generated `.mexw64` file:

**Required Files (Copy from `C:\msys64\ucrt64\bin`):**

1. `libgfortran-5.dll`
2. `libopenblas.dll`
3. `libquadmath-0.dll`
4. `libgomp-1.dll` (OpenMP Support)
5. `libgcc_s_seh-1.dll`
6. `libwinpthread-1.dll`
7. `libstdc++-6.dll`

The file **`setup_mumps_runtime.m`** automates this process:

```
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
```

## 4. Testing and Verification

### 4.1 Test Script (`test_dmumps.m`)

This script verifies:

1. OpenMP multithreading settings.
2. METIS ordering algorithm invocation (`id.ICNTL(7) = 5`).
3. Solution accuracy (residual).

```
function test_dmumps()
    clc;
    disp('=== MUMPS Test (Double Real + OpenMP + METIS) ===');
    if exist('dmumpsmex', 'file') ~= 3, error('dmumpsmex not found'); end
    
    % 1. Parallel settings (4 threads)
    setenv('OMP_NUM_THREADS', '4');
    
    % 2. Data preparation
    n = 5000;
    A = sprand(n, n, 0.01) + speye(n)*10;
    A = A + A'; 
    b = rand(n, 1);
    
    % 3. Initialization
    id = initmumps;
    id.JOB = -1;
    id.SYM = 0;
    id = dmumps(id); 
    
    % 4. Enable METIS
    id.ICNTL(1:4) = 0; % Turn off verbose output
    id.ICNTL(7) = 5;   % 5 = Force METIS ordering
    
    % 5. Solve
    disp('Starting solve...');
    tic;
    id.JOB = 6; 
    id.RHS = b;
    id = dmumps(id, A);
    toc;
    
    % 6. Verification
    rel_res = norm(A*id.SOL - b) / norm(b);
    fprintf('Relative Residual: %.2e\n', rel_res);
    
    if rel_res < 1e-10
        disp('>> Test successful!');
    else
        disp('>> Warning: Large residual');
    end
    
    id.JOB = -2;
    dmumps(id);
end
```

### 4.2 Test Script (`test_zmumps.m`)

This script verifies the Complex version with OpenMP and METIS.

```
function test_zmumps()
    clc;
    disp('==============================================');
    disp('        MUMPS OpenMP Complex Test (ZMUMPS)    ');
    disp('==============================================');

    % 1. Check MEX file existence
    if exist('zmumpsmex', 'file') ~= 3
        error('Error: zmumpsmex.mexw64 file not found! Please run compile_mumps(''z'').');
    end
    disp('MEX file (zmumpsmex) check passed.');

    % 2. Set OpenMP threads
    n_threads = 4; 
    setenv('OMP_NUM_THREADS', num2str(n_threads));
    fprintf('OMP_NUM_THREADS set to = %d\n', n_threads);

    % 3. Prepare complex test data
    n = 5000;
    density = 0.01;
    fprintf('Generating complex test matrix (n=%d, density=%.2f)...\n', n, density);
    
    % Construct complex sparse matrix A = Real + i*Imag
    A = (sprand(n, n, density) + speye(n)*10) + ...
        1i * (sprand(n, n, density) + speye(n)*10);
        
    % Right-hand side is complex
    b = rand(n, 1) + 1i * rand(n, 1);

    % 4. Initialize MUMPS
    disp('Initializing ZMUMPS...');
    id = initmumps;
    id.JOB = -1;
    id.SYM = 0; % Unsymmetric
    
    % Call zmumps wrapper or mex file
    if exist('zmumps', 'file') == 2
        id = zmumps(id);
    else
        warning('zmumps.m wrapper not found, attempting direct call to zmumpsmex.');
        id = zmumpsmex(id);
    end

    % 5. Set control parameters
    id.ICNTL(1:4) = 0; % Turn off output
    
    % ICNTL(16) is OpenMP thread count
    id.ICNTL(16) = n_threads; 
    
    % Turn on verbose output for testing purposes
    id.ICNTL(1) = 6; 
    id.ICNTL(2) = 0; 
    id.ICNTL(3) = 6; 
    id.ICNTL(4) = 2; % Standard statistics
    
    % Set ordering algorithm
    id.ICNTL(7) = 5; % Force METIS
    
    % 6. Execute solve
    disp('Starting solve (Complex)...');
    id.JOB = 6; 
    id.RHS = b;
    
    tic;
    if exist('zmumps', 'file') == 2
        id = zmumps(id, A);
    else
        id = zmumpsmex(id, A);
    end
    t_solve = toc;
    
    fprintf('Solve finished! Time elapsed: %.4f seconds\n', t_solve);

    % 7. Verification
    if ~isempty(id.SOL)
        x = id.SOL;
        % Calculate complex residual
        rel_res = norm(A*x - b) / norm(b);
        fprintf('Relative Residual (Complex): %.2e\n', rel_res);
        
        if rel_res < 1e-10
            disp('>> Test successful! Result accurate. <<');
        else
            disp('>> Warning: Large residual, result may be inaccurate. <<');
        end
    else
        disp('Error: No solution vector returned.');
    end

    % 8. Release memory
    disp('Cleaning up memory...');
    id.JOB = -2;
    if exist('zmumps', 'file') == 2
        id = zmumps(id);
    else
        id = zmumpsmex(id);
    end
    disp('Done.');
end
```

## 5. Common Issues and Solutions

1. **`undefined reference to dmumps_c`**:
   - **Reason:** The MATLAB interface expected symbol does not match the one in the static library (usually includes an underscore `_`).
   - **Solution:** The script uses `nm` detection and passes the `-DAdd_` macro, compiling `src/mumps_c.c` simultaneously to generate the correct C bridge code.
2. **`mxCreateDoubleMatrix` Linking Error**:
   - **Reason:** The MATLAB 2025a `.lib` import format is incompatible with the newer MinGW linker.
   - **Solution:** The script automatically copies the `.lib` files locally and links them using `-L.`, bypassing the complex path parsing issues.
3. **Static Library Circular Dependency Error**:
   - **Reason:** `libdmumps` and `libmumps_common` have circular dependencies, causing single-pass linking to fail.
   - **Solution:** The `LINKLIBS` parameter uses a repeat strategy (`libA libB libA libB`) to force the linker to scan multiple times.
4. **METIS Not Active**:
   - **Reason:** The static library was not linked or `ICNTL(7)` was not set.
   - **Solution:** Ensure `Makefile.inc` included `-Dmetis` and set `id.ICNTL(7)=5` during the MATLAB call.