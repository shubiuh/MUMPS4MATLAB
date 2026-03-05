# MUMPS for MATLAB 编译技术报告 (Windows/MSYS2)

**环境:** Windows 11, MATLAB 2025a, MSYS2 (UCRT64/MinGW64) **目标:** 编译支持 OpenMP 多线程和 METIS 排序的 MUMPS 求解器 (实数/复数版)

------

[toc]

## 1. 环境准备 (Prerequisites)

### 1.1 安装 MSYS2 工具链

不要使用 Visual Studio (MSVC)，因为其对 Fortran 和复杂的 Makefile 支持不佳。请使用 **MSYS2 UCRT64** 环境。

在 MSYS2 终端中运行以下命令，安装编译器、数学库和 METIS：

```Bash
pacman -S mingw-w64-ucrt-x86_64-gcc
pacman -S mingw-w64-ucrt-x86_64-gcc-fortran
pacman -S mingw-w64-ucrt-x86_64-make
pacman -S mingw-w64-ucrt-x86_64-openblas
pacman -S mingw-w64-ucrt-x86_64-metis
```

### 1.2 配置 MUMPS `Makefile.inc`

在 MUMPS 源码根目录下，复制 `Make.inc/Makefile.inc.generic` 为 `Makefile.inc`，并修改以下关键部分：

1. **启用 OpenMP 和 METIS 宏：**

   ```Makefile
   # 编译器选项加入 -fopenmp
   OPTF    = -O -fopenmp
   OPTC    = -O -fopenmp
   OPTL    = -O -fopenmp
   
   # 排序选项加入 -Dmetis
   ORDERINGSF  = -Dpord -Dmetis
   ```

2. **指定 METIS 路径 (MSYS2 默认路径)：**

   ```Makefile
   # 注意：路径需使用 Unix 格式
   LMETISDIR   = /c/msys64/ucrt64/lib
   IMETIS      = -I/c/msys64/ucrt64/include
   # 直接链接静态库
   LMETIS      = $(LMETISDIR)/libmetis.a
   ```

3. **指定 BLAS (OpenBLAS)：**

   ```Makefile
   LIBBLAS = -lopenblas
   ```

4. **使用伪 MPI (Sequential)：**

   ```Makefile
   LIBSEQ      = ../libseq/libmpiseq.a
   INCPAR      = -I../libseq
   LIBPAR      = $(LIBSEQ)
   ```

### 1.3 编译静态库

在 MSYS2 终端中执行：

```Bash
# 先编译伪 MPI 库
cd libseq && make && cd ..

# 清理并编译主库
make clean
make d  # 编译双精度实数 (生成 libdmumps.a)
make z  # 编译双精度复数 (生成 libzmumps.a)
```

------

## 2. MATLAB 编译脚本 (Build Script)

这是最终调试成功的构建脚本。它解决了符号命名冲突、静态库循环依赖、METIS 集成以及路径空格问题。

运行`build_mumps_metis.m`前，在matlab中`mex -setup`将C、C++、Fortran编译器配置为msys64的GCC。

如matlab找不到msys64的GCC，或者设置后没有用，请先删除matlab工具箱下载的`MATLAB Support for MinGW-w64 C/C++/Fortran Compiler`，然后电脑环境变量中增加变量`MW_MINGW64_LOC`为`C:\msys64\ucrt64`（安装的`msys64\ucrt64`路径），重新启动matlab。

**脚本功能：**

- **路径自动管理：** 运行前自动添加源码路径，运行后自动清理。
- **智能符号侦测：** 自动检测 Fortran 符号格式 (`dmumps_f77` vs `dmumps_f77_`)。
- **METIS 集成：** 自动链接 METIS 静态库。
- **强制重复链接：** 解决 `libdmumps` 和 `libcommon` 之间的循环依赖。

请将以下代码保存为 **`build_mumps_metis.m`**：

```Matlab
function build_mumps_metis(target_arith)
    % =====================================================================
    % MUMPS + METIS Build Script (V6.0 Final)
    % 用法: build_mumps_metis('d') [实数] 或 build_mumps_metis('z') [复数]
    % =====================================================================

    if nargin < 1, target_arith = 'd'; end
    target_arith = lower(target_arith);
    
    % --- 1. 路径管理与环境初始化 ---
    mumps_folder_name = 'MUMPS_5.7.2'; % 请确保此文件夹在当前目录
    mumps_root = fullfile(pwd, mumps_folder_name);
    
    if ~exist(mumps_root, 'dir')
        error('错误: 当前目录下未找到 "%s"。', mumps_folder_name);
    end
    
    fprintf('--------------------------------------------------\n');
    fprintf('正在初始化路径...\n');
    addpath(genpath(mumps_root));
    % 使用 onCleanup 确保脚本结束或报错时都能自动清理路径
    cleanupObj = onCleanup(@() restore_path(mumps_root));

    % MSYS2 配置 (根据实际安装路径修改)
    msys_root = 'C:\msys64\ucrt64'; 
    msys_lib_path = fullfile(msys_root, 'lib');
    matlab_mingw_path = fullfile(matlabroot, 'extern', 'lib', 'win64', 'mingw64');
    
    % 查找 nm 工具
    nm_exe = fullfile(msys_root, 'bin', 'nm.exe');
    if ~exist(nm_exe, 'file')
        [status, ~] = system('nm --version');
        if status == 0, nm_exe = 'nm'; else, error('找不到 nm.exe'); end
    end

    % --- 2. 配置目标变量 ---
    if strcmp(target_arith, 'd')
        lib_name_main = 'libdmumps.a';
        macro_arith   = '-DMUMPS_ARITH=MUMPS_ARITH_d';
        symbol_grep   = 'dmumps_f77';
        output_name   = 'dmumpsmex';
        fprintf('>>> 目标: 双精度实数 (Real) + METIS\n');
    elseif strcmp(target_arith, 'z')
        lib_name_main = 'libzmumps.a';
        macro_arith   = '-DMUMPS_ARITH=MUMPS_ARITH_z';
        symbol_grep   = 'zmumps_f77';
        output_name   = 'zmumpsmex';
        fprintf('>>> 目标: 双精度复数 (Complex) + METIS\n');
    else
        error('参数错误: 请使用 ''d'' 或 ''z''');
    end

    % --- 3. 准备依赖库 (复制 MATLAB lib) ---
    matlab_libs = {'libmx.lib', 'libmex.lib', 'libmat.lib'};
    for i = 1:length(matlab_libs)
        src = fullfile(matlab_mingw_path, matlab_libs{i});
        dest = fullfile(pwd, matlab_libs{i});
        if ~exist(dest, 'file'), copyfile(src, dest); end
    end

    % --- 4. 智能符号侦测 ---
    lib_main_path = fullfile(mumps_root, 'lib', lib_name_main);
    if ~exist(lib_main_path, 'file')
        error('找不到静态库 %s。请先在 MSYS2 中运行 "make %s"。', lib_name_main, target_arith);
    end

    fprintf('正在诊断符号: %s\n', lib_name_main);
    cmd = sprintf('"%s" -g "%s" | findstr /I "%s"', nm_exe, lib_main_path, symbol_grep);
    [status, cmdout] = system(cmd);
    
    add_macro = '-DAdd_'; % 默认策略
    if status == 0 && ~isempty(cmdout)
        if contains(cmdout, [symbol_grep '__']), add_macro = '-DAdd__';
        elseif contains(cmdout, [symbol_grep '_']), add_macro = '-DAdd_';
        elseif contains(cmdout, symbol_grep), add_macro = ''; 
        elseif contains(cmdout, upper(symbol_grep)), add_macro = '-DUPPER';
        end
    end
    fprintf('>>> 决定使用的宏: %s\n', add_macro);

    % --- 5. 构造 MEX 命令 ---
    mex_cmd = 'mex -v -g';
    
    % 宏定义 (-Dmetis 让 C 接口知晓)
    cflags_str = sprintf('-D_WIN32 %s %s -Dmetis', macro_arith, add_macro);
    mex_cmd = [mex_cmd ' ' cflags_str];
    mex_cmd = [mex_cmd ' CFLAGS="$CFLAGS -fopenmp" LDFLAGS="$LDFLAGS -fopenmp"'];
    
    % 包含路径
    include_dirs = {
        fullfile(mumps_root, 'include'), ...
        fullfile(mumps_root, 'libseq'), ...
        fullfile(mumps_root, 'PORD', 'include'), ...
        fullfile(mumps_root, 'src')
    };
    for i = 1:length(include_dirs)
        mex_cmd = [mex_cmd ' -I"' include_dirs{i} '"'];
    end
    
    % 源文件 (混编 mumps_c.c 以生成正确的 C 接口)
    sources = {
        fullfile(mumps_root, 'MATLAB', 'mumpsmex.c'), ...
        fullfile(mumps_root, 'src', 'mumps_c.c')
    };
    for i = 1:length(sources)
        mex_cmd = [mex_cmd ' "' sources{i} '"'];
    end
    
    % --- 链接策略: 强制重复链接 + METIS ---
    % 路径标准化 (防止反斜杠转义问题)
    l_main   = strrep(lib_main_path, '\', '/');
    l_common = strrep(fullfile(mumps_root, 'lib', 'libmumps_common.a'), '\', '/');
    l_seq    = strrep(fullfile(mumps_root, 'libseq', 'libmpiseq.a'), '\', '/');
    l_pord   = strrep(fullfile(mumps_root, 'PORD', 'lib', 'libpord.a'), '\', '/');
    l_metis  = strrep(fullfile(msys_lib_path, 'libmetis.a'), '\', '/');
    
    if ~exist(l_metis, 'file')
        error('找不到 METIS 库，请检查 MSYS2 安装。');
    end

    % 构造链接串：重复前两个库以解决循环依赖，METIS 放在最后
    mumps_link_str = sprintf('%s %s %s %s %s %s %s', ...
        l_main, l_common, l_seq, l_pord, l_main, l_common, l_metis);
    
    % 系统库
    l_msys = strrep(msys_lib_path, '\', '/');
    sys_libs = sprintf('-L. -llibmx -llibmex -llibmat -L%s -lgfortran -lquadmath -lopenblas -lgomp -lmingw32 -lkernel32 -lm', l_msys);
    
    % 放入 LINKLIBS
    mex_cmd = [mex_cmd ' LINKLIBS="' mumps_link_str ' ' sys_libs '"'];
    mex_cmd = [mex_cmd ' -output ' output_name];

    % --- 6. 执行 ---
    fprintf('--------------------------------------------------\n');
    fprintf('正在编译...\n');
    disp(mex_cmd); 
    
    try
        eval(mex_cmd);
        fprintf('\n\n======== 编译成功！生成文件: %s.%s ========\n', output_name, mexext);
        delete('libmx.lib'); delete('libmex.lib'); delete('libmat.lib');
        fprintf('提示: 运行测试时请确保设置 id.ICNTL(7)=5 以启用 METIS。\n');
    catch ME
        fprintf('\n\n======== 编译失败 ========\n');
        rethrow(ME);
    end
end

function restore_path(p)
    fprintf('正在清理路径...\n');
    rmpath(genpath(p));
end
```

------

## 3. 运行时环境准备 (Runtime Setup)

编译后的 MEX 文件依赖 MSYS2 的动态链接库。请确保以下 DLL 文件与生成的 `.mexw64` 文件在同一目录：

**必需文件 (从 `C:\msys64\ucrt64\bin` 复制):**

1. `libgfortran-5.dll`
2. `libopenblas.dll`
3. `libquadmath-0.dll`
4. `libgomp-1.dll` (OpenMP 支持)
5. `libgcc_s_seh-1.dll`
6. `libwinpthread-1.dll`
7. `libstdc++-6.dll`

请将以下代码保存为 **`setup_mumps_runtime.m`**，脚本自动复制所需文件。

``` matlab
function setup_mumps_runtime()
% SETUP_MUMPS_RUNTIME 自动准备 MUMPS MEX 运行所需的 DLL 依赖文件
% 该脚本会从 MSYS2/MinGW64 的 bin 目录复制必要的运行时库到当前文件夹。

    clc;
    fprintf('======================================================\n');
    fprintf('       MUMPS Runtime Environment Setup Tool           \n');
    fprintf('======================================================\n');

    % 1. 定义可能的 MSYS2 安装路径 (根据你的环境调整)
    % 通常是 C:\msys64\ucrt64\bin 或 C:\msys64\mingw64\bin
    % 你的上一次编译使用的是 UCRT64 环境
    search_paths = {
        'C:\msys64\ucrt64\bin', ...
        'C:\msys64\mingw64\bin', ...
        'D:\msys64\ucrt64\bin', ...
        'C:\Program Files\Git\mingw64\bin' 
    };

    % 2. 查找有效的 bin 目录
    msys_bin_path = '';
    for i = 1:length(search_paths)
        if exist(search_paths{i}, 'dir')
            % 检查关键文件是否存在以确认路径有效性
            if exist(fullfile(search_paths{i}, 'libgfortran-5.dll'), 'file') || ...
               exist(fullfile(search_paths{i}, 'libgfortran-4.dll'), 'file')
                msys_bin_path = search_paths{i};
                break;
            end
        end
    end

    if isempty(msys_bin_path)
        error(['错误: 无法自动找到 MSYS2/MinGW 的 bin 目录。\n' ...
               '请手动修改脚本中的 search_paths 变量指向你的 msys64/ucrt64/bin 路径。']);
    else
        fprintf('找到工具链路径: %s\n', msys_bin_path);
    end

    % 3. 定义需要复制的 DLL 列表
    % 这些是 MinGW GCC + OpenBLAS + OpenMP 编译通常需要的依赖
    required_dlls = {
        'libgfortran-*.dll', ... % 通配符匹配版本号 (如 libgfortran-5.dll)
        'libquadmath-*.dll', ...
        'libopenblas.dll',   ... % 或者 libopenblas*.dll
        'libgomp-*.dll',     ... % OpenMP 核心库
        'libgcc_s_seh-*.dll',... % GCC 异常处理
        'libwinpthread-*.dll',...% Windows 线程库
        'libstdc++-*.dll'    ... % C++ 标准库 (有时需要)
    };

    % 4. 执行复制
    count = 0;
    fprintf('开始复制依赖文件...\n');
    
    for i = 1:length(required_dlls)
        pattern = required_dlls{i};
        full_pattern = fullfile(msys_bin_path, pattern);
        
        % 查找匹配的文件
        files = dir(full_pattern);
        
        if isempty(files)
            % 尝试去掉通配符再找一次（针对没有版本号的文件）
            clean_name = strrep(pattern, '-*', '');
            if exist(fullfile(msys_bin_path, clean_name), 'file')
                files = dir(fullfile(msys_bin_path, clean_name));
            end
        end

        if isempty(files)
            fprintf('  [警告] 未找到: %s (可能不需要或名称不同)\n', pattern);
        else
            for k = 1:length(files)
                src_file = fullfile(files(k).folder, files(k).name);
                dest_file = fullfile(pwd, files(k).name);
                
                % 检查是否已存在且较新
                copy_flag = true;
                if exist(dest_file, 'file')
                    d_info = dir(dest_file);
                    % 如果文件大小和修改时间一致，跳过
                    if d_info.bytes == files(k).bytes && d_info.datenum >= files(k).datenum
                        copy_flag = false;
                        % fprintf('  [跳过] 已存在: %s\n', files(k).name);
                    end
                end
                
                if copy_flag
                    try
                        copyfile(src_file, dest_file);
                        fprintf('  [成功] 复制: %s\n', files(k).name);
                        count = count + 1;
                    catch ME
                        fprintf('  [错误] 复制失败: %s (%s)\n', files(k).name, ME.message);
                    end
                end
            end
        end
    end

    fprintf('------------------------------------------------------\n');
    if count > 0
        fprintf('成功复制了 %d 个 DLL 文件。\n', count);
    else
        fprintf('所有依赖文件似乎已存在，无需更新。\n');
    end
    
    % 5. 最终检查
    fprintf('当前目录 DLL 列表:\n');
    ls('*.dll');
    
    disp('环境准备就绪。现在可以运行测试脚本了。');
end
```

------

## 4. 测试与验证

### 4.1 测试脚本 (`test_dmumps.m`)

该脚本验证了：

1. OpenMP 多线程设置。
2. METIS 排序算法的调用。
3. 求解精度（残差）。

```Matlab
function test_dmumps()
    clc;
    disp('=== MUMPS Test (Double Real + OpenMP + METIS) ===');
    if exist('dmumpsmex', 'file') ~= 3, error('未找到 dmumpsmex'); end
    
    % 1. 并行设置 (4线程)
    setenv('OMP_NUM_THREADS', '4');
    
    % 2. 数据准备
    n = 5000;
    A = sprand(n, n, 0.01) + speye(n)*10;
    A = A + A'; 
    b = rand(n, 1);
    
    % 3. 初始化
    id = initmumps;
    id.JOB = -1;
    id.SYM = 0;
    id = dmumps(id); 
    
    % 4. 启用 METIS
    id.ICNTL(1:4) = 0; % 关闭冗余输出
    id.ICNTL(7) = 5;   % 5 = 强制使用 METIS 排序
    
    % 5. 求解
    disp('开始求解...');
    tic;
    id.JOB = 6; 
    id.RHS = b;
    id = dmumps(id, A);
    toc;
    
    % 6. 验证
    rel_res = norm(A*id.SOL - b) / norm(b);
    fprintf('相对残差: %.2e\n', rel_res);
    
    if rel_res < 1e-10
        disp('>> 测试成功！');
    else
        disp('>> 警告：残差过大');
    end
    
    id.JOB = -2;
    dmumps(id);
end
```

### 4.2 测试脚本 (`test_zmumps.m`)

``` matlab
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
```

------

## 5. 常见问题总结

1. **`undefined reference to dmumps_c`**:
   - 原因：MATLAB 接口代码期望的符号与静态库中的符号（通常带下划线 `_`）不匹配。
   - 解决：脚本通过 `nm` 侦测并传递 `-DAdd_` 宏，且同时编译 `src/mumps_c.c` 来生成正确的桥接代码。
2. **`mxCreateDoubleMatrix` 链接错误**:
   - 原因：MATLAB 2025a 的 `.lib` 导入库格式与新版 MinGW 链接器不兼容。
   - 解决：脚本自动将 `.lib` 复制到当前目录，并通过 `-L.` 本地链接，绕过路径解析问题。
3. **静态库循环依赖错误**:
   - 原因：`libdmumps` 和 `libmumps_common` 相互依赖，单次链接失败。
   - 解决：在 `LINKLIBS` 中采用重复策略（`libA libB libA libB`），强制链接器多次扫描。
4. **METIS 未生效**:
   - 原因：静态库未链接或 `ICNTL(7)` 未设置。
   - 解决：确保 `Makefile.inc` 中包含了 `-Dmetis`，且 MATLAB 脚本正确链接了 `libmetis.a`。调用时设置 `id.ICNTL(7)=5`。