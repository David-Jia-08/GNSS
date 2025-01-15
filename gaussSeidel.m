function [x, iter] = gaussSeidel(A, b, tol, maxIter)
% gaussSeidel: 使用 Gauss-Seidel 方法求解 AX = b
% 
% 输入:
%   A       - 系数矩阵 (n x n)
%   b       - 常数向量 (n x 1)
%   tol     - 误差容限 (默认: 1e-6)
%   maxIter - 最大迭代次数 (默认: 100)
%
% 输出:
%   x       - 解向量
%   iter    - 实际迭代次数

    % 参数默认值
    if nargin < 3, tol = 1e-6; end
    if nargin < 4, maxIter = 100; end

    % 初始化
    n = length(b);       % 方程个数
    x = zeros(n, 1);     % 初始解
    iter = 0;            % 迭代计数
    x_prev = x;          % 前一轮的解 (用于误差判断)

    % 检查输入矩阵是否为方阵
    if size(A, 1) ~= size(A, 2)
        error('矩阵 A 必须是方阵');
    end

    % 检查对角线是否为零
    if any(diag(A) == 0)
        error('矩阵 A 的对角线元素不能为零');
    end

    % 迭代求解
    for iter = 1:maxIter
        for i = 1:n
            % 计算当前 x_i 的新值
            sigma = 0;
            for j = 1:n
                if j ~= i
                    sigma = sigma + A(i, j) * x(j);
                end
            end
            x(i) = (b(i) - sigma) / A(i, i);
        end

        % 检查误差 (使用欧几里得范数)
        if norm(x - x_prev, inf) < tol
            break;
        end
        x_prev = x; % 更新解
    end

    % 如果达到最大迭代次数未收敛，给出警告
    if iter == maxIter
        warning('Gauss-Seidel 方法未在最大迭代次数内收敛');
    end
end
