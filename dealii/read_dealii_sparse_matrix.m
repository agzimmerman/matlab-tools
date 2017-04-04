function [ Matrix ] = read_dealii_sparse_matrix(FilePath)

FileID = fopen(FilePath, 'rt');

Numbers = textscan(FileID, '(%u,%u) %f \n');

Matrix = sparse(double(Numbers{1}) + 1, double(Numbers{2}) + 1, Numbers{3});

end