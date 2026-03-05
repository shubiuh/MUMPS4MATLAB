function build_mumps_metis(target_arith)
    % =====================================================================
    % MUMPS + METIS Build Script (V6.0 Path-Auto-Managed)
    % Functions: 
    %   1. Automatically adds ./MUMPS_5.7.2 to MATLAB path
    %   2. Compiles MUMPS (d/z) and links METIS
    %   3. Automatically cleans up path upon completion or error
    % Usage: build_mumps_metis('d') or build_mumps_metis('z')
    % =====================================================================

    if nargin < 1, target_arith = 'd'; end
    target_arith = lower(target_arith);
    
    % =====================================================================
    % 1. Path Management and Environment Setup
    % =====================================================================
    mumps_folder_name = 'MUMPS_5.7.2';
    mumps_root = fullfile(pwd, mumps_folder_name);
    
    if ~exist(mumps_root, 'dir')
        error('Error: Folder "%s" not found in the current directory. Please check the path.', mumps_folder_name);
    end
    
    % --- Key Step: Add Path ---
    fprintf('--------------------------------------------------\n');
    fprintf('Adding %s and its subfolders to MATLAB path...\n', mumps_folder_name);
    addpath(genpath(mumps_root));
    
    % --- Key Step: Register Cleanup Function (Executed on success or error) ---
    % This line creates a cleanup object that automatically calls restore_path when the function exits.
    cleanupObj = onCleanup(@() restore_path(mumps_root));

    % MSYS2 Configuration (Modify paths if different from default installation)
    msys_root = 'C:\msys64\ucrt64'; 
    msys_lib_path = fullfile(msys_root, 'lib');
    matlab_mingw_path = fullfile(matlabroot, 'extern', 'lib', 'win64', 'mingw64');
    
    % Locate nm.exe
    nm_exe = fullfile(msys_root, 'bin', 'nm.exe');
    if ~exist(nm_exe, 'file')
        [status, ~] = system('nm --version');
        if status == 0, nm_exe = 'nm'; else, error('nm.exe not found, please check msys_root setting.'); end
    end

    % =====================================================================
    % 2. Configure Target Variables
    % =====================================================================
    if strcmp(target_arith, 'd')
        lib_name_main = 'libdmumps.a';
        macro_arith   = '-DMUMPS_ARITH=MUMPS_ARITH_d';
        symbol_grep   = 'dmumps_f77';
        output_name   = 'dmumpsmex';
        fprintf('>>> Compilation Target: Double Precision Real (Real) + METIS\n');
    elseif strcmp(target_arith, 'z')
        lib_name_main = 'libzmumps.a';
        macro_arith   = '-DMUMPS_ARITH=MUMPS_ARITH_z';
        symbol_grep   = 'zmumps_f77';
        output_name   = 'zmumpsmex';
        fprintf('>>> Compilation Target: Double Precision Complex (Complex) + METIS\n');
    else
        error('Unsupported argument: %s', target_arith);
    end

    % =====================================================================
    % 3. Prepare MATLAB Dependency Libraries
    % =====================================================================
    matlab_libs = {'libmx.lib', 'libmex.lib', 'libmat.lib'};
    % Copy MATLAB libraries locally to avoid linker path/compatibility issues
    for i = 1:length(matlab_libs)
        src = fullfile(matlab_mingw_path, matlab_libs{i});
        dest = fullfile(pwd, matlab_libs{i});
        if ~exist(dest, 'file'), copyfile(src, dest); end
    end

    % =====================================================================
    % 4. Intelligent Symbol Diagnostics
    % =====================================================================
    lib_main_path = fullfile(mumps_root, 'lib', lib_name_main);
    if ~exist(lib_main_path, 'file')
        error('Static library %s not found.\nPlease ensure you have run "make %s" in MSYS2 after enabling METIS.', lib_name_main, target_arith);
    end

    fprintf('Diagnosing static library symbols: %s\n', lib_main_path);
    % Use nm to find the actual Fortran symbol name
    cmd = sprintf('"%s" -g "%s" | findstr /I "%s"', nm_exe, lib_main_path, symbol_grep);
    [status, cmdout] = system(cmd);
    
    add_macro = '-DAdd_'; % Default to single underscore (common Fortran naming)
    if status == 0 && ~isempty(cmdout)
        if contains(cmdout, [symbol_grep '__']), add_macro = '-DAdd__';
        elseif contains(cmdout, [symbol_grep '_']), add_macro = '-DAdd_';
        elseif contains(cmdout, symbol_grep), add_macro = ''; 
        elseif contains(cmdout, upper(symbol_grep)), add_macro = '-DUPPER';
        end
    end
    fprintf('>>> Determined macro: %s\n', add_macro);

    % =====================================================================
    % 5. Construct MEX Command
    % =====================================================================
    mex_cmd = 'mex -v -g';
    
    % Macro definitions (-Dmetis required for C interface)
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
    
    % Source files (mumpsmex.c + mumps_c.c for bridging)
    sources = {
        fullfile(mumps_root, 'MATLAB', 'mumpsmex.c'), ...
        fullfile(mumps_root, 'src', 'mumps_c.c')
    };
    for i = 1:length(sources)
        mex_cmd = [mex_cmd ' "' sources{i} '"'];
    end
    
    % --- Linking Strategy: Forced Repetition + METIS ---
    l_main   = strrep(lib_main_path, '\', '/');
    l_common = strrep(fullfile(mumps_root, 'lib', 'libmumps_common.a'), '\', '/');
    l_seq    = strrep(fullfile(mumps_root, 'libseq', 'libmpiseq.a'), '\', '/');
    l_pord   = strrep(fullfile(mumps_root, 'PORD', 'lib', 'libpord.a'), '\', '/');
    l_metis  = strrep(fullfile(msys_lib_path, 'libmetis.a'), '\', '/');
    
    if ~exist(l_metis, 'file')
        error('METIS library not found: %s\nPlease run: pacman -S mingw-w64-ucrt-x86_64-metis', l_metis);
    end

    % Construct linking string: (Main Common Seq Pord) + (Main Common) + METIS
    mumps_link_str = sprintf('%s %s %s %s %s %s %s', ...
        l_main, l_common, l_seq, l_pord, l_main, l_common, l_metis);
    
    % System libraries
    l_msys = strrep(msys_lib_path, '\', '/');
    sys_libs = sprintf('-L. -llibmx -llibmex -llibmat -L%s -lgfortran -lquadmath -lopenblas -lgomp -lmingw32 -lkernel32 -lm', l_msys);
    
    % Combine LINKLIBS
    mex_cmd = [mex_cmd ' LINKLIBS="' mumps_link_str ' ' sys_libs '"'];
    mex_cmd = [mex_cmd ' -output ' output_name];

    % =====================================================================
    % 6. Execute Compilation
    % =====================================================================
    fprintf('--------------------------------------------------\n');
    fprintf('Executing compilation...\n');
    disp(mex_cmd); 
    fprintf('--------------------------------------------------\n');

    try
        eval(mex_cmd);
        fprintf('\n\n======== Compilation Successful! Output file: %s.%s ========\n', output_name, mexext);
        
        % Clean up temporary lib files
        delete('libmx.lib'); delete('libmex.lib'); delete('libmat.lib');
        fprintf('Hint: Ensure ICNTL(7)=5 is set in your test code to use METIS.\n');
        
    catch ME
        fprintf('\n\n======== Compilation Failed! ========\n');
        % Path cleanup is automatically handled by onCleanup
        rethrow(ME);
    end
end

% =========================================================================
% Helper Function: Path Cleanup
% =========================================================================
function restore_path(p)
    fprintf('Cleaning up path (removing %s)...\n', p);
    rmpath(genpath(p));
end