SHELL=/usr/bin/env sh

source_cpp_to_object=$(addprefix $(2)/,$(patsubst %.cpp,%.o,$(notdir $(1))))

project_TAG:=gotoglobe
project_DIR:=$(CURDIR)

target_TAG:=debian-8.3_m32

tmp_DIR:=$(project_DIR)/build/$(target_TAG)/tmp
lib_DIR:=$(project_DIR)/build/$(target_TAG)/lib
bin_DIR:=$(project_DIR)/build/$(target_TAG)/bin

src_DIR:=./src

CPPC:=g++
CPPFLAGS:=-std=c++11 -pedantic -Wall -Wno-missing-braces -Winline \
	-m32 -g -fPIC -fno-strict-aliasing -O2 -I./include

src_LST:=$(wildcard $(src_DIR)/*.cpp)
obj_LST:=$(call source_cpp_to_object,$(src_LST),$(tmp_DIR))

dynamic_LIB:=$(lib_DIR)/lib$(project_TAG).so
static_LIB:=$(lib_DIR)/lib$(project_TAG).a

.PHONY: preface postface create_dir clean all

all: preface $(dynamic_LIB) $(static_LIB) postface

$(tmp_DIR)/%.o:$(src_DIR)/%.cpp
	@echo "compile. $(notdir $@)"
	@$(CPPC) -c $(CPPFLAGS) $< -o $@

$(dynamic_LIB): $(obj_LST)
	@echo "link. $(notdir $@)"
	@$(CPPC) $(CPPFLAGS) -shared -o $@ -Wl,--whole-archive $^ -Wl,--no-whole-archive

$(static_LIB): $(obj_LST)
	@echo "archive. $(notdir $@)"
	@ar rsu $@ $?

preface: create_dir
	@echo -e "\n>>>  BUILD  >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  $(project_DATE)  >>>\n"
	@echo -e "\tproject: $(project_TAG)\n"
	@echo -e "\ttarget: $(target_TAG)"
	@echo -e "\n=====================================================================\n"

postface:
	@echo -e "\n=====================================================================\n"
	@echo -e "products:"
	@echo -e "\t$(dynamic_LIB)"
	@echo -e "\t$(static_LIB)"
	@echo -e "\n<<<  $(target_TAG)  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<  END  <<<\n"

create_dir:
	@mkdir --parents $(tmp_DIR)
	@mkdir --parents $(lib_DIR)
	@mkdir --parents $(bin_DIR)

clean:
	-@rm --recursive --force $(tmp_DIR)
	-@rm $(dynamic_LIB)
	-@rm $(static_LIB)
	@echo -e "\ncleaned ... \n"
