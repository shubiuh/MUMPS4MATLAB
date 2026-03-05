#
#  This file is part of MUMPS 5.7.3, released
#  on Mon Jul 15 11:44:21 UTC 2024
#
#Begin orderings

# NOTE that PORD is distributed within MUMPS by default. It is recommended to
# install other orderings. For that, you need to obtain the corresponding package
# and modify the variables below accordingly.
# For example, to have Metis available within MUMPS:
#          1/ download Metis and compile it
#          2/ uncomment (suppress # in first column) lines
#             starting with LMETISDIR,  LMETIS
#          3/ add -Dmetis in line ORDERINGSF
#             ORDERINGSF  = -Dpord -Dmetis
#          4/ Compile and install MUMPS
#             make clean; make   (to clean up previous installation)
#
#          Metis/ParMetis and SCOTCH/PT-SCOTCH (ver 6.0 and later) orderings are recommended.
#

#SCOTCHDIR  = ${HOME}/scotch_6.0
#ISCOTCH    = -I$(SCOTCHDIR)/include
#
# You have to choose one among the following two lines depending on
# the type of analysis you want to perform. If you want to perform only
# sequential analysis choose the first (remember to add -Dscotch in the ORDERINGSF
# variable below); for both parallel and sequential analysis choose the second 
# line (remember to add -Dptscotch in the ORDERINGSF variable below)

#LSCOTCH    = -L$(SCOTCHDIR)/lib -lesmumps -lscotch -lscotcherr
#LSCOTCH    = -L$(SCOTCHDIR)/lib -lptesmumps -lptscotch -lptscotcherr


#LPORDDIR = $(topdir)/PORD/lib/
#IPORD    = -I$(topdir)/PORD/include/
#LPORD    = -L$(LPORDDIR) -lpord$(PLAT)

LMETISDIR = D:/trash/mumps-superbuild-5.8.2.0/build_mex/local/lib
IMETIS    = -ID:/trash/mumps-superbuild-5.8.2.0/build_mex/local/include -DIDXTYPEWIDTH=32 -DREALTYPEWIDTH=32

# You have to choose one among the following two lines depending on
# the type of analysis you want to perform. If you want to perform only
# sequential analysis choose the first (remember to add -Dmetis in the ORDERINGSF
# variable below); for both parallel and sequential analysis choose the second 
# line (remember to add -Dparmetis in the ORDERINGSF variable below)

LMETIS = $(LMETISDIR)/metis.lib
#LMETIS    = -L$(LMETISDIR) -lparmetis -lmetis

# The following variables will be used in the compilation process.
# Please note that -Dptscotch and -Dparmetis imply -Dscotch and -Dmetis respectively.
# If you want to use Metis 4.X or an older version, you should use -Dmetis4 instead of -Dmetis
# or in addition with -Dparmetis (if you are using parmetis 3.X or older).
#ORDERINGSF = -Dscotch -Dmetis -Dpord -Dptscotch -Dparmetis
ORDERINGSF  = -Dmetis
ORDERINGSC  = $(ORDERINGSF)

LORDERINGS = $(LMETIS) $(LPORD) $(LSCOTCH)
IORDERINGSF = $(ISCOTCH)
IORDERINGSC = $(IMETIS) $(IPORD) $(ISCOTCH)

#End orderings
########################################################################
################################################################################

PLAT    =
LIBEXT  = .lib
LIBEXT_SHARED  = .dll
SONAME = -soname
SHARED_OPT = -shared
FPIC_OPT = -fPIC
# Adapt/uncomment RPATH_OPT to avoid modifying
# LD_LIBRARY_PATH in case of shared libraries
# RPATH_OPT = -Wl,-rpath,/path/to/MUMPS_x.y.z/lib/
OUTC    = -o 
OUTF    = -o 
RM = /bin/rm -f
CC = icx
FC = ifx
FL = ifx
AR = lib /OUT:
#RANLIB = ranlib
RANLIB  = echo
# Make this variable point to the path where the Intel MKL library is
# installed. It is set to the default install directory for Intel MKL.
MKLROOT=/opt/intel/mkl/lib/intel64
LAPACK = -L$(MKLROOT) -lmkl_intel_lp64 -lmkl_intel_thread -lmkl_core

LIBM = $(LIBSEQ)

INCSEQ = -I$(topdir)/libseq
LIBSEQ = $(topdir)/libseq/libmpiseq.lib

LIBBLAS = mkl_intel_lp64.lib mkl_intel_thread.lib mkl_core.lib libiomp5md.lib
LIBOTHERS = -link -LIBPATH:$(LMETISDIR)

#Preprocessor defs for calling Fortran from C (-DAdd_ or -DAdd__ or -DUPPER)
CDEFS   = -DAdd_

#Begin Optimized options
OPTF = -O3 -MD -Qopenmp -Dintel_ -DALLOW_NON_INIT -fpp
OPTL = -O2 -MD -Qopenmp
OPTC = -O2 -MD -Qopenmp
#End Optimized options
 
INCS = $(INCSEQ)
LIBS = $(LIBSEQ)
LIBSEQNEEDED = libseqneeded
