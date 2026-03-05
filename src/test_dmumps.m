function test_dmumps()
    clc;
    disp('==============================================');
    disp('        MUMPS OpenMP Interface Test           ');
    disp('==============================================');

    % 1. 检查 MEX 文件是否存在
    if exist('dmumpsmex', 'file') ~= 3
        error('错误: 未找到 dmumpsmex.mexw64 文件！请确保编译成功并在当前路径。');
    end
    disp('MEX 文件检查通过。');

    % 2. 设置 OpenMP 线程数 (核心测试点)
    % 我们设置不同的线程数来观察性能变化
    n_threads = 4; 
    setenv('OMP_NUM_THREADS', num2str(n_threads));
    fprintf('已设置 OMP_NUM_THREADS = %d\n', n_threads);

    % 3. 准备测试数据 (生成一个稍微大一点的稀疏矩阵)
    n = 5000;
    density = 0.01;
    fprintf('生成测试矩阵 (n=%d, density=%.2f)...\n', n, density);
    A = sprand(n, n, density) + speye(n)*10; % 对角占优以确保可逆
    A = A + A'; % 对称化 (虽然MUMPS也能处理非对称)
    b = rand(n, 1);

    % 4. 初始化 MUMPS
    disp('初始化 MUMPS...');
    id = initmumps;
    id.JOB = -1;
    id.SYM = 0; % 0=非对称, 1=正定对称, 2=一般对称 (这里先用0通用测试)
    id = dmumps(id); 

    % 5. 设置控制参数
    % ICNTL(1)-ICNTL(4) 控制输出冗余度，设为0以保持安静
    id.ICNTL(1:4) = 0; 
    
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
    
    % 6. 执行求解 (Analysis + Factorization + Solve)
    disp('开始求解...');
    id.JOB = 6; 
    id.RHS = b;
    
    tic;
    id = dmumps(id, A);
    t_solve = toc;
    
    fprintf('求解完成！耗时: %.4f 秒\n', t_solve);

    % 7. 验证结果
    if ~isempty(id.SOL)
        x = id.SOL;
        rel_res = norm(A*x - b) / norm(b);
        fprintf('相对残差: %.2e\n', rel_res);
        
        if rel_res < 1e-10
            disp('>> 测试成功！结果正确。 <<');
        else
            disp('>> 警告：残差过大，结果可能不正确。 <<');
        end
    else
        disp('错误：未返回解向量。检查 INFO(1) 错误码。');
        disp(['INFO(1) = ', num2str(id.INFO(1))]);
        disp(['INFO(2) = ', num2str(id.INFO(2))]);
    end

    % 8. 释放内存
    disp('清理内存...');
    id.JOB = -2;
    id = dmumps(id);
    disp('完成。');
end