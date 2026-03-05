clear;clc;close all;

%% read the whole matrix A
Lastin = maxNumCompThreads(1);
[systemMat, m, n, nnzsystemMat] = load_sparse_matrix('system_matrix_kz0_MD1_freq1_Src4.txt');
[P, ~, ~, nnzP] = load_sparse_matrix('p_matrix_kz0_MD1_freq1_Src4.txt');
[co, ~, ~, nnzCo] = load_sparse_matrix('common_matrix_kz0_MD1_freq1_Src4.txt');
[Pre, ~, ~, nnzPre] = load_sparse_matrix('pre_matrix_kz0_MD1_freq1_Src4.txt');

figure(1); 
spy(co);       % sparsity pattern
title(sprintf('Sparsity Pattern of Common matrix (nnz=%d, density=%.2f%%)', nnz(co), 100*nnz(co)/(m*n)));

figure(2);
spy(P);       % sparsity pattern
title(sprintf('Sparsity Pattern of P matrix (nnz=%d, density=%.2f%%)', nnz(P), 100*nnz(P)/(m*n)));

figure(3);
spy(Pre);       % sparsity pattern
title(sprintf('Sparsity Pattern of Pre matrix (nnz=%d, density=%.2f%%)', nnz(Pre), 100*nnz(Pre)/(m*n)));

%% Read RHS vector from file
rhs_data = readmatrix('rhs_b_kz0.000_Src4.txt', 'NumHeaderLines', 4);
rhs_real = rhs_data(:, 2);
rhs_imag = rhs_data(:, 3);
RHS = rhs_real + 1i * rhs_imag;

% read solution vector from file for verification
sol_data = readmatrix('solution_x_kz0.000_Src4.txt', 'NumHeaderLines', 4);
sol_real = sol_data(:, 2);
sol_imag = sol_data(:, 3);
sol = sol_real + 1i * sol_imag;

figure;
semilogy(1:length(sol),abs(sol.'));ylim([1e-12,1e4]);xlim([1 length(sol)]);

figure;
subplot(2,1,1)
plot(1:length(sol),sol_real);xlim([1 length(sol)]);
subplot(2,1,2)
plot(1:length(sol),sol_imag);xlim([1 length(sol)]);
%% solve using direct solver
opts = umfpack_v1; % set control for UMFPACK
opts.prl = 0; % set print level to  3 if want to seee more info

A = systemMat;
A = 1j*1*P+co;
tic
x = A\RHS;
toc

tic
[gEHSpec, info] = umfpack_v1(A, '\', RHS, opts);
toc

tic;
n_threads = 4; 
setenv('OMP_NUM_THREADS', num2str(n_threads));
fprintf('OMP_NUM_THREADS set to = %d\n', n_threads);

% 4. Initialize MUMPS
disp('Initializing ZMUMPS...');
id = initmumps;
id.JOB = -1;
id.SYM = 0; % 0=Unsymmetric (Complex matrices usually use Unsymmetric or Hermitian; using Unsymmetric here)

% [NOTE] The zmumps interface needs to be called here
% If the zmumps.m wrapper file is not in your folder, you can call the mex file directly:
if exist('zmumps', 'file') == 2
    id = zmumps(id);
else
    warning('zmumps.m wrapper file not found, attempting to call zmumpsmex directly.');
    id = zmumpsmex(id);
end

% 5. Set control parameters
id.ICNTL(1:4) = 0; % Turn off output

% ICNTL(16) is the OpenMP thread count setting, usually set to 0 to follow the OMP_NUM_THREADS environment variable
% But some versions may require explicit setting
id.ICNTL(16) = n_threads; 

% Enable output for observation
id.ICNTL(1) = 6; 
id.ICNTL(2) = 0; 
id.ICNTL(3) = 6; 
id.ICNTL(4) = 2; % Print detailed information

% Set the ordering algorithm
% 0: AMD, 2: AMF, 3: SCOTCH, 4: PORD, 5: METIS, 7: Auto
id.ICNTL(7) = 5; % Force use of METIS

% 6. Execute the solve
disp('Starting solve (Complex)...');
id.JOB = 6; 
id.RHS = RHS;

if exist('zmumps', 'file') == 2
    id = zmumps(id, A);
else
    id = zmumpsmex(id, A);
end
t_solve = toc;

fprintf('Solve complete! Time taken: %.4f seconds\n', t_solve);

% 7. Verify results
if ~isempty(id.SOL)
    x = id.SOL;
    % Calculate complex residual
    rel_res = norm(A*x - RHS) / norm(RHS);
    fprintf('Relative residual (Complex): %.2e\n', rel_res);
    
    if rel_res < 1e-10
        disp('>> Test successful! Result is correct. <<');
    else
        disp('>> Warning: Residual is too large, result may be incorrect. <<');
    end
else
    disp('Error: Solution vector not returned.');
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

%% Plot solution
figure(6);
subplot(1,2,1);
plot(real(gEHSpec), 'b-', 'LineWidth', 1.5);
grid on;
title('Real Part of Solution');
xlabel('Index'); ylabel('Value');

subplot(1,2,2);
plot(imag(gEHSpec), 'r-', 'LineWidth', 1.5);
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
    legend('UMFPACK', 'C++', 'MATLAB A\\b');
    grid on;
    title('Real Part Comparison');
    xlabel('Index'); ylabel('Value');
    
    subplot(2,3,2);
    plot(imag(gEHSpec), 'b-', 'LineWidth', 1.5);
    hold on;
    plot(sol_idx+1, sol_imag, 'r--', 'LineWidth', 1.5);
    plot(imag(x), 'g:', 'LineWidth', 1.5);
    legend('UMFPACK', 'C++', 'MATLAB A\\b');
    grid on;
    title('Imaginary Part Comparison');
    xlabel('Index'); ylabel('Value');
    
    subplot(2,3,3);
    semilogy(abs(gEHSpec), 'b-', 'LineWidth', 1.5);
    hold on;
    semilogy(abs(x_cpp), 'r--', 'LineWidth', 1.5);
    semilogy(abs(x), 'g:', 'LineWidth', 1.5);
    legend('UMFPACK', 'C++', 'MATLAB A\\b');
    grid on;
    title('Magnitude Comparison (log)');
    xlabel('Index'); ylabel('Magnitude');
    
    subplot(2,3,4);
    diff_real_cpp = real(gEHSpec) - sol_real;
    plot(diff_real_cpp, 'r-', 'LineWidth', 1.5);
    hold on;
    diff_real_backslash = real(gEHSpec) - real(x);
    plot(diff_real_backslash, 'g-', 'LineWidth', 1.5);
    legend('UMFPACK - C++', 'UMFPACK - A\\b');
    grid on;
    title('Real Part Difference');
    xlabel('Index'); ylabel('Difference');
    
    subplot(2,3,5);
    diff_imag_cpp = imag(gEHSpec) - sol_imag;
    plot(diff_imag_cpp, 'r-', 'LineWidth', 1.5);
    hold on;
    diff_imag_backslash = imag(gEHSpec) - imag(x);
    plot(diff_imag_backslash, 'g-', 'LineWidth', 1.5);
    legend('UMFPACK - C++', 'UMFPACK - A\\b');
    grid on;
    title('Imaginary Part Difference');
    xlabel('Index'); ylabel('Difference');
    
    subplot(2,3,6);
    diff_mag_cpp = abs(gEHSpec - x_cpp);
    semilogy(diff_mag_cpp, 'r-', 'LineWidth', 1.5);
    hold on;
    diff_mag_backslash = abs(gEHSpec - x);
    semilogy(diff_mag_backslash, 'g-', 'LineWidth', 1.5);
    legend('|UMFPACK - C++|', '|UMFPACK - A\\b|');
    grid on;
    title('Magnitude Difference (log)');
    xlabel('Index'); ylabel('|Difference|');
    
    fprintf('\n=== Comparison Statistics ===\n');
    fprintf('\nC++ vs UMFPACK:\n');
    fprintf('  Max Real Difference: %e\n', max(abs(diff_real_cpp)));
    fprintf('  Max Imag Difference: %e\n', max(abs(diff_imag_cpp)));
    fprintf('  RMS Real Difference: %e\n', sqrt(mean(diff_real_cpp.^2)));
    fprintf('  RMS Imag Difference: %e\n', sqrt(mean(diff_imag_cpp.^2)));
    fprintf('  Max Magnitude Diff:  %e\n', max(diff_mag_cpp));
    
    fprintf('\nMATLAB A\\b vs UMFPACK:\n');
    fprintf('  Max Real Difference: %e\n', max(abs(diff_real_backslash)));
    fprintf('  Max Imag Difference: %e\n', max(abs(diff_imag_backslash)));
    fprintf('  RMS Real Difference: %e\n', sqrt(mean(diff_real_backslash.^2)));
    fprintf('  RMS Imag Difference: %e\n', sqrt(mean(diff_imag_backslash.^2)));
    fprintf('  Max Magnitude Diff:  %e\n', max(diff_mag_backslash));
end