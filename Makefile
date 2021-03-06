#Some Makefile for CLASS.
#Julien Lesgourgues, 28.11.2011

MDIR := $(shell pwd)
WRKDIR = $(MDIR)/build

.base:
	@mkdir -p $(WRKDIR)/lib
	@touch build/.base

vpath %.c source:tools:main:test
vpath %.o build
vpath .base build

########################################################
###### LINES TO ADAPT TO YOUR PLATEFORM ################
########################################################

# your C compiler:
CC       = gcc
#CC       = icc
#CC       = pgcc

# your tool for creating static libraries:
AR        = ar rv

# Your python interpreter.
# In order to use Python 3, you can manually
# substitute python3 to python in the line below, or you can simply
# add a compilation option on the terminal command line:
# "PYTHON=python3 make all" (THanks to Marius Millea for pyhton3
# compatibility)
PYTHON ?= python

# your optimization flag
#OPTFLAG = -O4 -ffast-math #-march=native
#OPTFLAG = -Ofast -ffast-math #-march=native
OPTFLAG = -ffast-math

# your openmp flag (comment for compiling without openmp)
OMPFLAG   = -fopenmp
#OMPFLAG   = -mp -mp=nonuma -mp=allcores -g
#OMPFLAG   = -openmp

# all other compilation flags
CCFLAG = -g -fPIC
LDFLAG = -g -fPIC -L $(HOME)/.local/lib

# leave blank to compile without HyRec, or put path to HyRec directory
# (with no slash at the end: e.g. hyrec or ../hyrec)
HYREC = hyrec

########################################################
###### IN PRINCIPLE THE REST SHOULD BE LEFT UNCHANGED ##
########################################################

# pass current working directory to the code
CCFLAG += -D__CLASSDIR__='"$(MDIR)"'

# where to find include files *.h
INCLUDES = -I $(MDIR)/include -I $(HOME)/.local/include

# libraries
LDLIBS = -lm

# automatically add external programs if needed. First, initialize to blank.
EXTERNAL =

# eventually update flags for including HyRec
ifneq ($(HYREC),)
vpath %.c $(HYREC)
CCFLAG += -DHYREC
#LDFLAGS += -DHYREC
INCLUDES += -I $(MDIR)/hyrec
EXTERNAL += hyrectools.o helium.o hydrogen.o history.o
endif

$(WRKDIR)/%.o:%.c .base
	$(CC) $(OPTFLAG) $(OMPFLAG) $(CCFLAG) $(INCLUDES) -c $< -o $(WRKDIR)/$*.o

TOOLS = growTable.o dei_rkck.o sparse.o evolver_rkck.o evolver_ndf15.o arrays.o parser.o quadrature.o hyperspherical.o common.o trigonometric_integrals.o

SOURCE = input.o background.o thermodynamics.o perturbations.o primordial.o nonlinear.o transfer.o spectra.o lensing.o

INPUT = input.o

PRECISION = precision.o

BACKGROUND = background.o

THERMO = thermodynamics.o

PERTURBATIONS = perturbations.o

TRANSFER = transfer.o

PRIMORDIAL = primordial.o

SPECTRA = spectra.o

NONLINEAR = nonlinear.o

LENSING = lensing.o

OUTPUT = output.o

CLASS = class.o

TEST_LOOPS = test_loops.o

TEST_LOOPS_OMP = test_loops_omp.o

TEST_SPECTRA = test_spectra.o

TEST_TRANSFER = test_transfer.o

TEST_NONLINEAR = test_nonlinear.o

TEST_PERTURBATIONS = test_perturbations.o

TEST_THERMODYNAMICS = test_thermodynamics.o

TEST_BACKGROUND = test_background.o

TEST_HYPERSPHERICAL = test_hyperspherical.o

C_TOOLS = $(addprefix tools/, $(addsuffix .c,$(basename $(TOOLS))))
C_SOURCE = $(addprefix source/, $(addsuffix .c,$(basename $(SOURCE) $(OUTPUT))))
C_TEST = $(addprefix test/, $(addsuffix .c,$(basename $(TEST_DEGENERACY) $(TEST_LOOPS) $(TEST_TRANSFER) $(TEST_NONLINEAR) $(TEST_PERTURBATIONS) $(TEST_THERMODYNAMICS))))
C_MAIN = $(addprefix main/, $(addsuffix .c,$(basename $(CLASS))))
C_ALL = $(C_MAIN) $(C_TOOLS) $(C_SOURCE)
H_ALL = $(addprefix include/, common.h svnversion.h $(addsuffix .h, $(basename $(notdir $(C_ALL)))))
PRE_ALL = cl_ref.pre clt_permille.pre
INI_ALL = explanatory.ini lcdm.ini
MISC_FILES = Makefile CPU psd_FD_single.dat myselection.dat myevolution.dat README bbn/sBBN.dat external_Pk/* cpp
PYTHON_FILES = python/classy.pyx python/setup.py python/cclassy.pxd python/test_class.py

.PHONY: all call clean

all: class libclass.a classy

call: clean .base all

libclass.a: $(addprefix $(WRKDIR)/, $(TOOLS) $(SOURCE) $(EXTERNAL))
	$(AR) $@ $(addprefix $(WRKDIR)/, $(TOOLS) $(SOURCE) $(EXTERNAL))

class: $(addprefix $(WRKDIR)/, $(TOOLS) $(SOURCE) $(EXTERNAL) $(OUTPUT) $(CLASS))
	$(CC) $(OPTFLAG) $(OMPFLAG) $(LDFLAG) -o class $(addprefix $(WRKDIR)/,$(notdir $^)) $(LDLIBS)

test_loops: $(addprefix $(WRKDIR)/, $(TOOLS) $(SOURCE) $(EXTERNAL) $(OUTPUT) $(TEST_LOOPS))
	$(CC) $(OPTFLAG) $(OMPFLAG) $(LDFLAG) -o $@ $(addprefix $(WRKDIR)/,$(notdir $^)) $(LDLIBS)

test_loops_omp: $(addprefix $(WRKDIR)/, $(TOOLS) $(SOURCE) $(EXTERNAL) $(OUTPUT) $(TEST_LOOPS_OMP))
	$(CC) $(OPTFLAG) $(OMPFLAG) $(LDFLAG) -o $@ $(addprefix $(WRKDIR)/,$(notdir $^)) $(LDLIBS)

test_spectra: $(addprefix $(WRKDIR)/, $(TOOLS) $(SOURCE) $(EXTERNAL) $(TEST_SPECTRA))
	$(CC) $(OPTFLAG) $(OMPFLAG) $(LDFLAG) -o  $@ $(addprefix $(WRKDIR)/,$(notdir $^)) $(LDLIBS)

test_nonlinear: $(addprefix $(WRKDIR)/, $(TOOLS) $(SOURCE) $(EXTERNAL) $(TEST_NONLINEAR))
	$(CC) $(OPTFLAG) $(OMPFLAG) $(LDFLAG) -o $@ $(addprefix $(WRKDIR)/,$(notdir $^)) $(LDLIBS)

test_perturbations: $(addprefix $(WRKDIR)/, $(TOOLS) $(SOURCE) $(EXTERNAL) $(TEST_PERTURBATIONS))
	$(CC) $(OPTFLAG) $(OMPFLAG) $(LDFLAG) -o $@ $(addprefix $(WRKDIR)/,$(notdir $^)) $(LDLIBS)

test_thermodynamics: $(addprefix $(WRKDIR)/, $(TOOLS) $(SOURCE) $(EXTERNAL) $(TEST_THERMODYNAMICS))
	$(CC) $(OPTFLAG) $(OMPFLAG) $(LDFLAG) -o $@ $(addprefix $(WRKDIR)/,$(notdir $^)) $(LDLIBS)

test_background: $(addprefix $(WRKDIR)/, $(TOOLS) $(SOURCE) $(EXTERNAL) $(TEST_BACKGROUND))
	$(CC) $(OPTFLAG) $(OMPFLAG) $(LDFLAG) -o $@ $(addprefix $(WRKDIR)/,$(notdir $^)) $(LDLIBS)

test_hyperspherical: $(addprefix $(WRKDIR)/, $(TOOLS) $(TEST_HYPERSPHERICAL))
	$(CC) $(OPTFLAG) $(OMPFLAG) $(LDFLAG) -o test_hyperspherical $(addprefix $(WRKDIR)/,$(notdir $^)) $(LDLIBS)


tar: $(C_ALL) $(C_TEST) $(H_ALL) $(PRE_ALL) $(INI_ALL) $(MISC_FILES) $(HYREC) $(PYTHON_FILES)
	tar czvf class.tar.gz $(C_ALL) $(H_ALL) $(PRE_ALL) $(INI_ALL) $(MISC_FILES) $(HYREC) $(PYTHON_FILES)

classy: libclass.a python/classy.pyx python/cclassy.pxd
ifdef OMPFLAG
	@cp python/setup.py python/autosetup.py
else
	grep -v "lgomp" python/setup.py > python/autosetup.py
endif
# Removes previously installed classy library if it's there.
	@rm -f $(shell python -c "import classy; print(classy.__file__)")
	@cd python; export CC=$(CC); export LD_LIBRARY_PATH=""; $(PYTHON) autosetup.py install || $(PYTHON) autosetup.py install --user
	@rm python/autosetup.py

clean: .base
	@rm -rf $(WRKDIR)
	@rm -f libclass.a
	@rm -f $(MDIR)/python/classy.c
	@rm -rf $(MDIR)/python/build
	@rm -f $(shell python -c "import classy; print(classy.__file__)")
