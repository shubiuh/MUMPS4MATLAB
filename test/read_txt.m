clear;clc;close all;

%% read the whole matrix A
Lastin = maxNumCompThreads(1);
[systemMat, m, n, nnzsystemMat] = load_sparse_matrix('system_matrix_kz0_MD1_freq1.txt');
[P, ~, ~, nnzP] = load_sparse_matrix('p_matrix_kz0_MD1_freq1.txt');
[co, ~, ~, nnzCo] = load_sparse_matrix('common_matrix_kz0_MD1_freq1.txt');
[Pre, ~, ~, nnzPre] = load_sparse_matrix('pre_matrix_kz0_MD1_freq1.txt');

figure(1); 
spy(co);       % sparsity pattern
title(sprintf('Sparsity Pattern of Common matrix (nnz=%d, density=%.2f%%)', nnz(co), 100*nnz(co)/(m*n)));

RHS = ones(m,1); % use all-1 RHS

%% solve using zmumpsmex
if exist('zmumpsmex', 'file') ~= 3
    error('zmumpsmex.mexw64 not found. Please run compile_mumps(''z'') first.');
end

n_threads = 4;
setenv('OMP_NUM_THREADS', num2str(n_threads));
fprintf('OMP_NUM_THREADS set to %d\n', n_threads);

A = co;

% Initialize MUMPS
id = initmumps;
id.JOB = -1;
id.SYM = 0; % unsymmetric

if exist('zmumps', 'file') == 2
    id = zmumps(id);
else
    id = zmumpsmex(id);
end

% Control parameters
id.ICNTL(1:4) = 0;
id.ICNTL(16) = n_threads;
id.ICNTL(1) = 6;
id.ICNTL(2) = 0;
id.ICNTL(3) = 6;
id.ICNTL(4) = 2;
id.ICNTL(7) = 5; % METIS ordering

% Solve
id.JOB = 6;
id.RHS = RHS;

fprintf('Solving with ZMUMPS...\n');
tic;
if exist('zmumps', 'file') == 2
    id = zmumps(id, A);
else
    id = zmumpsmex(id, A);
end
t_solve = toc;
fprintf('Solve complete. Time: %.4f seconds\n', t_solve);

if ~isempty(id.SOL)
    gEHSpec = id.SOL;
    rel_res = norm(A * gEHSpec - RHS) / norm(RHS);
    fprintf('Relative residual: %.2e\n', rel_res);
else
    error('ZMUMPS did not return a solution.');
end

% Release MUMPS memory
id.JOB = -2;
if exist('zmumps', 'file') == 2
    id = zmumps(id);
else
    id = zmumpsmex(id);
end

%% Solve with UMFPACK (umfpack_v1)
if exist('umfpack_v1', 'file') == 3
    opts = umfpack_v1;
    opts.prl = 0;
    fprintf('Solving with UMFPACK...\n');
    tic;
    [x_umfpack, ~] = umfpack_v1(A, '\', RHS, opts);
    t_umfpack = toc;
    fprintf('UMFPACK complete. Time: %.4f seconds\n', t_umfpack);
else
    warning('umfpack_v1 not found, skipping UMFPACK solve.');
    x_umfpack = [];
    t_umfpack = NaN;
end

%% Solve with MATLAB built-in backslash
fprintf('Solving with MATLAB A\\b...\n');
tic;
x = A \ RHS;
t_backslash = toc;
fprintf('MATLAB A\\b complete. Time: %.4f seconds\n', t_backslash);

%% Timing comparison
fprintf('\n=== Solver Timing Comparison ===\n');
fprintf('  ZMUMPS  : %.4f seconds\n', t_solve);
if ~isnan(t_umfpack)
    fprintf('  UMFPACK : %.4f seconds\n', t_umfpack);
end
fprintf('  A\\b     : %.4f seconds\n', t_backslash);

%% Plot solution
figure(6);
subplot(1,2,1);
plot(real(gEHSpec), 'b--', 'LineWidth', 1.5);
hold on;
plot(real(x_umfpack), 'r.-', 'LineWidth', 1.5);
grid on;
title('Real Part of Solution');
xlabel('Index'); ylabel('Value');

subplot(1,2,2);

plot(imag(gEHSpec), 'b--', 'LineWidth', 1.5);
hold on;
plot(imag(x_umfpack), 'r.-', 'LineWidth', 1.5);
grid on;
title('Imaginary Part of Solution');
xlabel('Index'); ylabel('Value');

%% Load solution from C++ output file

opts_sol = detectImportOptions('solution_x.txt', ...
                               'NumHeaderLines', 4, ...
                               'FileType', 'text', ...
                               'DecimalSeparator', '.');

sol_data = readmatrix('solution_x.txt', opts_sol);

% Extract index, real, and imaginary parts
sol_idx  = sol_data(:,1);
sol_real = sol_data(:,2);
sol_imag = sol_data(:,3);

% Create complex solution vector
x_cpp = sol_real + 1j*sol_imag;

% Compare MATLAB vs C++ solutions vs MATLAB left divide solution
if exist('gEHSpec', 'var') && exist('x', 'var')
    figure(8);
    subplot(2,3,1);
    plot(real(gEHSpec), 'b-', 'LineWidth', 1.5);
    hold on;
    plot(sol_idx+1, sol_real, 'r--', 'LineWidth', 1.5);
    plot(real(x), 'g:', 'LineWidth', 1.5);
    legend('ZMUMPS', 'C++', 'MATLAB A\\b');
    grid on;
    title('Real Part Comparison');
    xlabel('Index'); ylabel('Value');
    
    subplot(2,3,2);
    plot(imag(gEHSpec), 'b-', 'LineWidth', 1.5);
    hold on;
    plot(sol_idx+1, sol_imag, 'r--', 'LineWidth', 1.5);
    plot(imag(x), 'g:', 'LineWidth', 1.5);
    legend('ZMUMPS', 'C++', 'MATLAB A\\b');
    grid on;
    title('Imaginary Part Comparison');
    xlabel('Index'); ylabel('Value');
    
    subplot(2,3,3);
    semilogy(abs(gEHSpec), 'b-', 'LineWidth', 1.5);
    hold on;
    semilogy(abs(x_cpp), 'r--', 'LineWidth', 1.5);
    semilogy(abs(x), 'g:', 'LineWidth', 1.5);
    if ~isempty(x_umfpack); semilogy(abs(x_umfpack), 'm-.', 'LineWidth', 1.5); end
    legend('ZMUMPS', 'C++', 'MATLAB A\\b', 'UMFPACK');
    grid on;
    title('Magnitude Comparison (log)');
    xlabel('Index'); ylabel('Magnitude');
    
    subplot(2,3,4);
    diff_real_cpp = real(gEHSpec) - sol_real;
    plot(diff_real_cpp, 'r-', 'LineWidth', 1.5);
    hold on;
    diff_real_backslash = real(gEHSpec) - real(x);
    plot(diff_real_backslash, 'g-', 'LineWidth', 1.5);
    legend('ZMUMPS - C++', 'ZMUMPS - A\\b');
    grid on;
    title('Real Part Difference');
    xlabel('Index'); ylabel('Difference');
    
    subplot(2,3,5);
    diff_imag_cpp = imag(gEHSpec) - sol_imag;
    plot(diff_imag_cpp, 'r-', 'LineWidth', 1.5);
    hold on;
    diff_imag_backslash = imag(gEHSpec) - imag(x);
    plot(diff_imag_backslash, 'g-', 'LineWidth', 1.5);
    legend('ZMUMPS - C++', 'ZMUMPS - A\\b');
    grid on;
    title('Imaginary Part Difference');
    xlabel('Index'); ylabel('Difference');
    
    subplot(2,3,6);
    diff_mag_cpp = abs(gEHSpec - x_cpp);
    semilogy(diff_mag_cpp, 'r-', 'LineWidth', 1.5);
    hold on;
    diff_mag_backslash = abs(gEHSpec - x);
    semilogy(diff_mag_backslash, 'g-', 'LineWidth', 1.5);
    legend('|ZMUMPS - C++|', '|ZMUMPS - A\\b|');
    grid on;
    title('Magnitude Difference (log)');
    xlabel('Index'); ylabel('|Difference|');
    
    fprintf('\n=== Comparison Statistics ===\n');
    fprintf('\nC++ vs ZMUMPS:\n');
    fprintf('  Max Real Difference: %e\n', max(abs(diff_real_cpp)));
    fprintf('  Max Imag Difference: %e\n', max(abs(diff_imag_cpp)));
    fprintf('  RMS Real Difference: %e\n', sqrt(mean(diff_real_cpp.^2)));
    fprintf('  RMS Imag Difference: %e\n', sqrt(mean(diff_imag_cpp.^2)));
    fprintf('  Max Magnitude Diff:  %e\n', max(diff_mag_cpp));
    
    fprintf('\nMATLAB A\\b vs ZMUMPS:\n');
    fprintf('  Max Real Difference: %e\n', max(abs(diff_real_backslash)));
    fprintf('  Max Imag Difference: %e\n', max(abs(diff_imag_backslash)));
    fprintf('  RMS Real Difference: %e\n', sqrt(mean(diff_real_backslash.^2)));
    fprintf('  RMS Imag Difference: %e\n', sqrt(mean(diff_imag_backslash.^2)));
    fprintf('  Max Magnitude Diff:  %e\n', max(diff_mag_backslash));
    
    if ~isempty(x_umfpack)
        diff_real_umf = real(gEHSpec) - real(x_umfpack);
        diff_imag_umf = imag(gEHSpec) - imag(x_umfpack);
        diff_mag_umf  = abs(gEHSpec - x_umfpack);
        fprintf('\nUMFPACK vs ZMUMPS:\n');
        fprintf('  Max Real Difference: %e\n', max(abs(diff_real_umf)));
        fprintf('  Max Imag Difference: %e\n', max(abs(diff_imag_umf)));
        fprintf('  RMS Real Difference: %e\n', sqrt(mean(diff_real_umf.^2)));
        fprintf('  RMS Imag Difference: %e\n', sqrt(mean(diff_imag_umf.^2)));
        fprintf('  Max Magnitude Diff:  %e\n', max(diff_mag_umf));
    end
end