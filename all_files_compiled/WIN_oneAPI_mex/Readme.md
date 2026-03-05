# Building MUMPS MEX Files on Windows with Intel oneAPI and GNU Make

This guide walks through compiling [MUMPS 5.7.3](https://mumps-solver.org/) (with METIS ordering) into MATLAB MEX files on Windows, using **Intel oneAPI compilers** (`icx`/`ifx`) and **GNU Make** from MSYS2.

---

## Prerequisites

| Tool | Version tested | Purpose |
|------|---------------|---------|
| **Visual Studio 2022** (Build Tools or full IDE) | 17.12 LTSC | Provides the MSVC linker, `lib.exe`, and Windows SDK |
| **Intel oneAPI Base & HPC Toolkit** | 2025.3 | Compilers (`icx`, `ifx`), MKL, OpenMP runtime |
| **MSYS2** | Latest | Supplies GNU `make`, `cp`, `grep`, and other Unix utilities |
| **MATLAB** | R2025b | MEX compilation and runtime |

> **Tip:** Only the *x64 Native Tools Command Prompt for VS 2022* is needed — you do not need a full Visual Studio project.

---

## Step 1 — Build the METIS Library

MUMPS uses [METIS](http://glaros.dtc.umn.edu/gkhome/metis/metis/overview) for fill-reducing ordering. Build it from the [MUMPS superbuild](https://github.com/scivision/mumps-superbuild/releases/tag/v5.8.2.0) project, which also compiles **GKlib** (a METIS dependency).

After building, copy the resulting files into the MUMPS source tree so they are easy to reference:

```
MUMPS_5.7.3\lib\metis\
├── include\
│   └── metis.h        ← METIS header
└── lib\
    ├── metis.lib       ← METIS static library
    └── GKlib.lib       ← GKlib static library (if built separately)
```

---

## Step 2 — Edit `Makefile.inc`

Open `MUMPS_5.7.3/Makefile.inc` and apply the changes below. Lines that differ from the default MUMPS distribution are marked with comments.

```makefile
#--------------------------------------------------------------
# Archiver — use the MSVC 'lib' tool instead of Unix 'ar'
#--------------------------------------------------------------
AR      = lib /OUT:
RANLIB  = echo                 # not needed on Windows

#--------------------------------------------------------------
# Compilers — Intel oneAPI
#--------------------------------------------------------------
CC      = icx
FC      = ifx
FL      = ifx

#--------------------------------------------------------------
# Library extension — Windows static libs use .lib
#--------------------------------------------------------------
LIBEXT  = .lib

#--------------------------------------------------------------
# Optimization flags (with OpenMP)
#   -MD          : link against the multithreaded DLL CRT
#   -Qopenmp     : enable OpenMP
#   -Dintel_      : preprocessor symbol for Intel-specific code
#   -fpp         : enable Fortran preprocessor
#--------------------------------------------------------------
OPTF    = -O3 -MD -Qopenmp -Dintel_ -DALLOW_NON_INIT -fpp
OPTL    = -O2 -MD -Qopenmp
OPTC    = -O2 -MD -Qopenmp

#--------------------------------------------------------------
# MKL (LAPACK + BLAS) — threaded, LP64 interface
#   On Windows the .lib names are passed directly to the linker;
#   the MKLROOT / -L flags below are kept for consistency but
#   LIBBLAS is what the linker actually picks up.
#--------------------------------------------------------------
MKLROOT = /opt/intel/mkl/lib/intel64
LAPACK  = -L$(MKLROOT) -lmkl_intel_lp64 -lmkl_intel_thread -lmkl_core
LIBBLAS = mkl_intel_lp64.lib mkl_intel_thread.lib mkl_core.lib libiomp5md.lib

#--------------------------------------------------------------
# Sequential MPI stub (libmpiseq, bundled with MUMPS)
#--------------------------------------------------------------
LIBM    = $(LIBSEQ)
INCSEQ  = -I$(topdir)/libseq
LIBSEQ  = $(topdir)/libseq/libmpiseq.lib

#--------------------------------------------------------------
# METIS ordering
#   Adjust LMETISDIR to where metis.lib lives on your machine.
#--------------------------------------------------------------
LMETISDIR = D:/trash/mumps-superbuild-5.8.2.0/build_mex/local/lib
LMETIS    = $(LMETISDIR)/metis.lib
IMETIS    = -ID:/trash/mumps-superbuild-5.8.2.0/build_mex/local/include \
            -DIDXTYPEWIDTH=32 -DREALTYPEWIDTH=32

ORDERINGSF = -Dmetis
ORDERINGSC = $(ORDERINGSF)

#--------------------------------------------------------------
# Linker extras — tell the MSVC linker where METIS lives
#--------------------------------------------------------------
LIBOTHERS = -link -LIBPATH:$(LMETISDIR)

#--------------------------------------------------------------
# Fortran-to-C calling convention
#--------------------------------------------------------------
CDEFS   = -DAdd_
```

> **Important:** Update every path that starts with `D:/trash/...` to match the location where you built METIS on your system.

---

## Step 3 — Patch the Makefiles for Windows

The stock MUMPS Makefiles assume a Unix environment. The modified Makefiles under `MUMPS_5.7.3/`, `MUMPS_5.7.3/src/`, and `MUMPS_5.7.3/libseq/` in this repository already contain the necessary changes (e.g. using `lib /OUT:` instead of `ar cr`, `.lib` extensions, object file naming). If you are starting from a fresh MUMPS tarball, compare against the files shipped in this folder and replicate the differences.

Key changes across all three Makefiles:

- **`Makefile`** (top-level): No functional changes needed beyond what `Makefile.inc` provides, but make sure the `examples` target does not block the build (create an empty `examples/` directory with a no-op Makefile if needed).
- **`libseq/Makefile`**: Produces `libmpiseq.lib` using `lib /OUT:` and compiles `.c`/`.f` sources with the Intel compilers.
- **`src/Makefile`**: Produces `libmumps_common.lib`, `libdmumps.lib`, and `libzmumps.lib`.

---

## Step 4 — Compile MUMPS

Open the **x64 Native Tools Command Prompt for VS 2022** (not PowerShell, not a regular CMD—this one has MSVC tools on `PATH`).

```bat
REM 1. Activate Intel oneAPI environment
call "C:\Program Files (x86)\Intel\oneAPI\setvars.bat" intel64

REM 2. Prevent MSYS2 path mangling (stops /O2 being rewritten to C:/msys64/O2)
set MSYS2_ARG_CONV_EXCL=/

REM 3. Put MSYS2 Unix tools (make, cp, grep, etc.) on PATH
set PATH=C:\msys64\usr\bin;%PATH%

REM 4. Navigate to MUMPS source root
cd /d "path\to\MUMPS_5.7.3"

REM 5. Build the sequential MPI stub first
cd libseq
make clean
make
cd ..

REM 6. Build MUMPS (double-real 'd' and double-complex 'z')
make clean
make all
```

On success the following libraries are created under `MUMPS_5.7.3\lib\`:

| Library | Contents |
|---------|----------|
| `libmumps_common.lib` | Arithmetic-independent common routines |
| `libdmumps.lib` | Double-precision real solver |
| `libzmumps.lib` | Double-precision complex solver |
| `libmpiseq.lib` (in `libseq/`) | Sequential MPI stub |

---

## Step 5 — Build the MEX Files in MATLAB

1. Open **MATLAB R2025b**.
2. Make sure a C compiler is configured (`mex -setup C` — MSVC is recommended).
3. Run the build script:

```matlab
% Build the double-real MEX
build_mumps_metis_oneapi_573('d')

% Build the double-complex MEX
build_mumps_metis_oneapi_573('z')
```

> Before running the build script, edit the path variables at the top of `build_mumps_metis_oneapi_573.m` to point to your MUMPS and oneAPI installation directories.

---

## Step 6 — Copy Runtime DLLs

The MEX files depend on Intel compiler and MKL runtime DLLs. If MATLAB reports missing DLLs at load time, run:

```matlab
setup_mumps_runtime_oneapi
```

This copies the required DLLs (e.g. `libiomp5md.dll`, `mkl_rt.2.dll`, `libifcoremd.dll`, …) from the oneAPI installation into the current working directory so MATLAB can find them.

> Alternatively, add the oneAPI `bin` directories to the system `PATH` instead of copying DLLs.

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `make` not found | Ensure `C:\msys64\usr\bin` is on `PATH` (Step 4.3). |
| `/O2` rewritten to `C:/msys64/O2` | Set `MSYS2_ARG_CONV_EXCL=/` before running `make` (Step 4.2). |
| `icx` / `ifx` not found | Run `setvars.bat intel64` first (Step 4.1). |
| `lib` command not found or wrong `lib` | Use the **x64 Native Tools Command Prompt**; it puts MSVC `lib.exe` on `PATH`. |
| MEX compilation error: `/openmp` vs `-Qiopenmp` | The build script uses MSVC-style `/openmp` by default. If `mex -setup C` is configured for Intel `icx-cl`, change to `-Qiopenmp` in `build_mumps_metis_oneapi_573.m`. |
| Missing DLL at runtime | Run `setup_mumps_runtime_oneapi` in MATLAB, or add oneAPI `bin` dirs to system `PATH`. |
| METIS ordering not active | Set `ICNTL(7) = 5` in your MUMPS solver script to select METIS ordering. |
