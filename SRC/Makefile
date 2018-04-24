# Related directories, over-written in Run.sh
OUTDIR     := .
CDIR       := .
SACDIR     := /opt/sac

# Compile parameters & dirs, some could be overwritten in Run.sh
# Notice: the order of library names in LIBS could matter.
CCOMP      := gcc -Wall -Wimplicit -fPIC
CPPCOMP    := c++ -std=c++14 -Wall -fPIC
FCOMP      := gfortran -std=legacy
INCDIR     := -I. -I$(CDIR) -I$(SACDIR)/include
LIBDIR     := -L. -L$(CDIR) -L$(SACDIR)/lib
LIBS       := -lASU_tools -lsac -lsacio -lfftw3 -lm

# all source files
CFILES     := $(wildcard *.c)
CDEPS      := $(patsubst %.c, $(OUTDIR)/%.d, $(CFILES))
COBJS      := $(patsubst %.d, %.co, $(CDEPS))

CPPFILES   := $(wildcard *.cpp)
CPPDEPS    := $(patsubst %.cpp, $(OUTDIR)/%.d, $(CPPFILES))
CPPOBJS    := $(patsubst %.d, %.cppo, $(CPPDEPS))

FFILES     := $(wildcard *.f)

# main files
CMAINS     := $(filter-out %.fun.c, $(CFILES))
CEXES      := $(patsubst %.c, $(OUTDIR)/%.cout, $(CMAINS))
CPPMAINS   := $(filter-out %.fun.cpp, $(CPPFILES))
CPPEXES    := $(patsubst %.cpp, $(OUTDIR)/%.cppout, $(CPPMAINS))
FMAINS     := $(FFILES)
FEXES      := $(patsubst %.f, $(OUTDIR)/%.fout, $(FMAINS))
EXES       := $(addsuffix .out, $(basename $(CEXES) $(CPPEXES) $(FEXES)))

# function files
CFUNS      := $(wildcard *fun.c)
CFUNOBJS   := $(patsubst %.c, $(OUTDIR)/%.co, $(CFUNS))
CPPFUNS    := $(wildcard *fun.cpp)
CPPFUNOBJS := $(patsubst %.cpp, $(OUTDIR)/%.cppo, $(CPPFUNS))

all: $(EXES) $(CEXES) $(CPPEXES) $(FEXES) $(COBJS) $(CPPOBJS)
	@echo > /dev/null

# Resolve dependencies automatically.
-include $(CDEPS) $(CPPDEPS)

%.out: $(CEXES) $(CPPEXES) $(FEXES)
	@cp $(basename $@)\.?*out $@

%.cout: %.co $(CFUNOBJS) $(CDIR)/libASU_tools.a
	@echo "Updating: $@ ..."
	@$(CCOMP) -o $@ $^ $(INCDIR) $(LIBDIR) $(LIBS)
%.cppout: %.cppo $(CPPFUNOBJS) $(CFUNOBJS) $(CDIR)/libASU_tools.a
	@echo "Updating: $@ ..."
	@$(CPPCOMP) -o $@ $^ $(INCDIR) $(LIBDIR) $(LIBS)
$(OUTDIR)/%.fout: %.f
	@echo "Updating: $@ ..."
	@$(FCOMP) -o $@ $^ $(INCDIR) $(LIBDIR) $(LIBS)

$(OUTDIR)/%.co: %.c
	@$(CCOMP) -MD -MP -c $< -o $@ $(INCDIR)
$(OUTDIR)/%.cppo: %.cpp
	@$(CPPCOMP) -MD -MP -c $< -o $@ $(INCDIR)

clean:
	@rm -f $(OUTDIR)/*out $(OUTDIR)/*o $(OUTDIR)/*.d
