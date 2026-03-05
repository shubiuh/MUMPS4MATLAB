function test_zmumps()
    clc;
    disp('==============================================');
    disp('        MUMPS OpenMP Complex Test (ZMUMPS)    ');
    disp('==============================================');

    % 1. 检查 MEX 文件是否存在
    % 注意：编译复数版时，输出文件名为 zmumpsmex.mexw64
    if exist('zmumpsmex', 'file') ~= 3
        error('错误: 未找到 zmumpsmex.mexw64 文件！请先运行 compile_mumps(''z'')。');
    end
    disp('MEX 文件 (zmumpsmex) 检查通过。');

    % 2. 设置 OpenMP 线程数
    n_threads = 4; 
    setenv('OMP_NUM_THREADS', num2str(n_threads));
    fprintf('已设置 OMP_NUM_THREADS = %d\n', n_threads);

    % 3. 准备复数测试数据
    n = 5000;
    density = 0.01;
    fprintf('生成复数测试矩阵 (n=%d, density=%.2f)...\n', n, density);
    
    % 构造复数稀疏矩阵 A = Real + i*Imag
    % 保持对角占优以确保数值稳定性
    A = (sprand(n, n, density) + speye(n)*10) + ...
        1i * (sprand(n, n, density) + speye(n)*10);
        
    % 右端项也是复数
    b = rand(n, 1) + 1i * rand(n, 1);

    % 4. 初始化 MUMPS
    disp('初始化 ZMUMPS...');
    id = initmumps;
    id.JOB = -1;
    id.SYM = 0; % 0=非对称 (复数一般用非对称或厄米特，这里用非对称)
    
    % 【注意】这里需要调用 zmumps 接口
    % 如果您的文件夹里没有 zmumps.m 封装文件，可以直接调用 mex 文件：
    if exist('zmumps', 'file') == 2
        id = zmumps(id);
    else
        warning('未找到 zmumps.m 封装文件，尝试直接调用 zmumpsmex。');
        id = zmumpsmex(id);
    end

    % 5. 设置控制参数
    id.ICNTL(1:4) = 0; % 关闭输出
    
    % ICNTL(16) 是 OpenMP 线程数设置，通常设为 0 让其跟随 OMP_NUM_THREADS 环境变量
    % 但有些版本可能需要显式设置
    id.ICNTL(16) = n_threads; 
    
    % 开启输出以便观察
    id.ICNTL(1) = 6; 
    id.ICNTL(2) = 0; 
    id.ICNTL(3) = 6; 
    id.ICNTL(4) = 2; % 打印详细信息
    
    % 设置排序算法 (Ordering)
    % 0: AMD, 2: AMF, 3: SCOTCH, 4: PORD, 5: METIS, 7: Auto
    id.ICNTL(7) = 5; % 强制使用 METIS
    
    % 6. 执行求解
    disp('开始求解 (Complex)...');
    id.JOB = 6; 
    id.RHS = b;
    
    tic;
    if exist('zmumps', 'file') == 2
        id = zmumps(id, A);
    else
        id = zmumpsmex(id, A);
    end
    t_solve = toc;
    
    fprintf('求解完成！耗时: %.4f 秒\n', t_solve);

    % 7. 验证结果
    if ~isempty(id.SOL)
        x = id.SOL;
        % 计算复数残差
        rel_res = norm(A*x - b) / norm(b);
        fprintf('相对残差 (Complex): %.2e\n', rel_res);
        
        if rel_res < 1e-10
            disp('>> 测试成功！结果正确。 <<');
        else
            disp('>> 警告：残差过大，结果可能不正确。 <<');
        end
    else
        disp('错误：未返回解向量。');
    end

    % 8. 释放内存
    disp('清理内存...');
    id.JOB = -2;
    if exist('zmumps', 'file') == 2
        id = zmumps(id);
    else
        id = zmumpsmex(id);
    end
    disp('完成。');
end