function [index_mat] = get_pixel_cell_partition_matrix(width, height, K)
%GET_PIXEL_CELL_PARTITION_MATRIX 
% The function takes as input the width and the height of the image
% sensor, and the number  K  which is the size of the  C  cells which
% divide the pixel grid. In order to peform quick lookup of which is 
% the corresponding cell for each pixel, this function returns a matrix 
% containing the index of the corresponding cell for each pixel which
% makes the lookup O(1). The indexes are returned in a row manner, i.e:
% 该函数将图像传感器的宽度和高度以及划分像素网格的C单元的大小K作为输入。 
% 为了快速查找每个像素对应的单元格，
% 该函数返回一个矩阵，
% 该矩阵包含进行查找O(1)的每个像素的对应单元格的索引。 
% 索引以行的方式返回，即：
%        
%        0 1 2 3 4
%        5 6 7 8 9

% 判断图像的长宽是C单元长宽K的整数倍
assert(rem(width,K)==0 && rem(height,K)==0);
cell_width = floor(width/K);
%cell_height = floor(height/K);
index_mat = zeros(width,height);

for i = 1:width
    for j = 1:height
        pixel_row = floor((i-1)/K);
        pixel_col = floor((j-1)/K);
        index_mat(i,j) = pixel_row*cell_width + pixel_col+1;
    end
end

end
%  例如：matrix = get_pixel_cell_partition_matrix(8,8,4)
% matrix
% array([[0, 0, 0, 0, 1, 1, 1, 1],
%       [0, 0, 0, 0, 1, 1, 1, 1],
%       [0, 0, 0, 0, 1, 1, 1, 1],
%       [0, 0, 0, 0, 1, 1, 1, 1],
%       [2, 2, 2, 2, 3, 3, 3, 3],
%       [2, 2, 2, 2, 3, 3, 3, 3],
%       [2, 2, 2, 2, 3, 3, 3, 3],
%       [2, 2, 2, 2, 3, 3, 3, 3]], dtype=int32)

