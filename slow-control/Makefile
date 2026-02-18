#!/usr/bin/make

src_dir		:= src
include_dir	:= include
bin_dir		:= bin
build_dir	:= $(src_dir)/build

CXX		:= g++
CXXFLAGS	+= -Wall -g -MMD -O3 -fPIC
CXXFLAGS	+= -std=c++17
CXXFLAGS	+= -I$(include_dir)
LDFLAGS		+= -lz

sources		:= $(wildcard $(src_dir)/*.cc)
objects		:= $(sources:$(src_dir)/%.cc=$(build_dir)/%.o)
dependencies	:= $(sources:$(src_dir)/%.cc=$(build_dir)/%.d)

cores		:= $(filter-out $(src_dir)/User%,$(sources))
core_objs	:= $(cores:$(src_dir)/%.cc=$(build_dir)/%.o)

users		:= $(filter $(src_dir)/User%,$(sources))
targets		:= $(users:$(src_dir)/User%.cc=$(bin_dir)/%)

color		:= 1

ifeq ($(color),1)
default_color	= \033[0m
black		= \033[0;30;1m
red		= \033[0;31;1m
green		= \033[0;32;1m
yellow		= \033[0;33;1m
blue		= \033[0;34;1m
magenta		= \033[0;35;1m
cyan		= \033[0;36;1m
white		= \033[0;37;1m
endif

#______________________________________________________________________________
.PHONY: all clean core
.SECONDARY:

all: $(targets)

$(bin_dir)/%: $(build_dir)/User%.o $(core_objs)
	@ echo "$(magenta)=== Linking $@$(default_color)"
	@ mkdir -p $(bin_dir)
	$(CXX) -o $@ $< $(core_objs) $(LDFLAGS)

$(build_dir)/%.o: $(src_dir)/%.cc
	@ echo "$(green)=== Compiling $@$(default_color)"
	@ mkdir -p $(build_dir)
	$(CXX) -o $@ -c $< $(CXXFLAGS)

clean:
	@ echo "$(green)=== Cleaning...$(default_color)"
	@ rm -rfv $(bin_dir)/* $(build_dir) *~ *.swp
	@ find . \( -name ".*.swp" -o -name "*~" \) -exec rm -fv \{\} \;

-include $(dependencies)
