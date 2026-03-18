FLAGS_CODE_SANITY := \
  -warn all \
  -fstack-protector-all \
  -check bounds \
  -D_FORTIFY_SOURCE=2
FFLAGS_FP_SANITY :=
ifeq ($(WITH_FPE_CHECKS),yes)
FFLAGS_FP_SANITY += -fpe0 -init=snan,arrays
endif
FFLAGS_FORTRAN_SANITY := -stand f08
FLAGS_REPRO := -ffp-contract=fast
FFLAGS_PREPROCESSOR := -cpp

ifeq ($(PROFILE),release)
  FLAGS_OPT := -O2 -xHost
  FLAGS_DEBUG :=
else ifeq ($(PROFILE),release-with-dbg-info)
  FLAGS_OPT := -O2 -xHost
  FLAGS_DEBUG := -g
else ifeq ($(PROFILE),debug)
  FLAGS_OPT := -O0
  FLAGS_DEBUG := -g -traceback
else
  $(error Unknown or unset PROFILE)
endif

ifeq ($(WITH_OPENMP),yes)
  FLAGS_OPENMP := -qopenmp
else
  FLAGS_OPENMP :=
endif

FFLAGS_COMPAT := -assume nostd_minus0_rounding
FFLAGS_FREE := -free -fpp -warn declarations
FFLAGS_FIXED := -fixed -fpp -extend-source 132
FLAGS_DEPS := $(call pkg-config,--cflags,$(EXTERNAL_DEPENDS_ON) $(INTERNAL_DEPENDS_ON)) $(INCLUDE_DIRS)

ifeq ($(WITH_COVERAGE),yes)
  FLAGS_COVERAGE := --coverage
else
  FLAGS_COVERAGE :=
endif

FFLAGS_SHARED  := \
  $(FLAGS_CODE_SANITY) \
  $(FFLAGS_FP_SANITY) \
  $(FFLAGS_FORTRAN_SANITY) \
  $(FLAGS_REPRO) \
  $(FFLAGS_PREPROCESSOR) \
  $(FLAGS_OPT) \
  $(FLAGS_DEBUG) \
  $(FLAGS_OPENMP) \
  $(FFLAGS_COMPAT) \
  $(FLAGS_DEPS) \
  $(FLAGS_COVERAGE)
FFLAGS_FIXED := $(FFLAGS_SHARED) $(FFLAGS_FIXED) $(FFLAGS)
_FFLAGS := $(FFLAGS_SHARED) $(FFLAGS_FREE) $(FFLAGS)
_CFLAGS := -Wall $(FLAGS_REPRO) $(FLAGS_OPT) $(FLAGS_DEBUG) $(FLAGS_DEPS) $(FLAGS_OPENMP) $(FLAGS_COVERAGE) $(CFLAGS)

PREPROCESS := ifx -cpp -E
FCOMPILE := ifx $(_FFLAGS) -c
FCOMPILE_MODULE := ifx $(_FFLAGS) -w -c -fsyntax-only
FCOMPILE_FIXED := ifx $(FFLAGS_FIXED) -c
FCOMPILE_MODULE_FIXED:= ifx $(FFLAGS_FIXED) -w -c -fsyntax-only
CCOMPILE := icx $(_CFLAGS) -c
LIB_DEP_ARGS := $(call pkg-config, --libs,$(EXTERNAL_DEPENDS_ON)) $(call pkg-config, --libs --static,$(INTERNAL_DEPENDS_ON))
LIB_TOOL_STATIC := ar rcs
LIB_TOOL_DYNAMIC := ifx -shared $(FLAGS_OPENMP) $(FLAGS_COVERAGE)
EXECUTABLE := ifx $(FLAGS_OPENMP) $(FLAGS_COVERAGE)
