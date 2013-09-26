####################################################################################
#
# PCRE <-> SML# binding
#
####################################################################################

SMLSHARP = smlsharp
OBJDIR = obj

VPATH = .:/usr/include

LIBS := $(shell pkg-config --libs libpcre)
SMLSHARPFLAGS = $(INCDIR)

SRCS = either.sml \
	   pcre_raw.sml \
	   pcre.sml \
	   test.sml

OBJS = $(SRCS:.sml=.o)

all: test pcre.o

test: %: %.smi %.o $(OBJS)
	$(SMLSHARP) $(SMLSHARPFLAGS) -o $@ $< $(LIBS)

%.d: %.sml
	@echo "generate [$@] from [$*]"
	@$(SHELL) -ec '$(SMLSHARP) -MM $(SMLSHARPFLAGS) $< \
		| sed "s/\($*\)\.o[ :]*/\1.o $@ : /g" > $@; \
		[ -s $@ ] || rm -rf $@'

%.o: %.sml
	$(SMLSHARP) $(SMLSHARPFLAGS) -c $<

ifeq (,$(findstring $(MAKECMDGOALS),clean))
include $(SRCS:.sml=.d)
endif

clean:
	rm -rf test
	rm -rf $(OBJS)
	rm -rf $(SRCS:.sml=.d)

