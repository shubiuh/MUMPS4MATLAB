function [A, m, n, nnz_count] = load_sparse_matrix(matrix_file)
% LOAD_SPARSE_MATRIX Load sparse matrix from COO format file
%
% Input:
%   matrix_file - Path to matrix file (format: first line is m, n, nnz;
%                 then i, j, real, imag for each entry)
%
% Outputs:
%   A         - Sparse matrix
%   m         - Number of rows
%   n         - Number of columns
%   nnz_count - Number of non-zeros

opts = detectImportOptions(matrix_file, ...
                           'NumHeaderLines', 0, ...
                           'FileType', 'text', ...
                           'DecimalSeparator', '.');

dataA = readmatrix(matrix_file, opts);

m = dataA(1,1);
n = dataA(1,2);
nnz_count = dataA(1,3);

triplets = dataA(2:end, :);

i = triplets(:,1);
j = triplets(:,2);
v = triplets(:,3) + 1j*triplets(:,4);

A = sparse(i, j, v, m, n);

end
