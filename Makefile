PRERELEASE_VERSION ?= "01"

ifdef RELEASE_VERSION
	VERSION_DEFINE="-DRELEASE_VERSION=$(RELEASE_VERSION)"
else
	ifdef PRERELEASE_VERSION
		VERSION_DEFINE="-DPRERELEASE_VERSION=$(PRERELEASE_VERSION)"
	endif
endif

CC		   = cc65
AS		   = ca65
LD		   = ld65

# global includes
ASFLAGS	 += -I inc
ASFLAGS	 += $(VERSION_DEFINE)
ASFLAGS	 += -g
ASFLAGS	 += --cpu 6502
ASFLAGS	 += --relax-checks

BUILD_DIR=build/c64
C64U_ADDRESS=192.168.0.39
#Set your C64U password here:
#C64U_PASSWORD=******** 	
CFG_DIR=$(BUILD_DIR)/cfg

MAIN_ROOT = reumalloc

# Define sources for the main program and overlays
MAIN_SOURCES = 	src/main.s \
				src/print.s \
				src/math.s \
				src/file.s \
				src/reu.s \
				src/malloc.s

# Define output binaries
MAIN_BIN = $(BUILD_DIR)/$(MAIN_ROOT).prg

# Define object files
MAIN_OBJS = $(addprefix $(BUILD_DIR)/, $(MAIN_SOURCES:.s=.o))

# Define configuration templates and generated configs
MAIN_CFG_TPL = cfg/$(MAIN_ROOT).cfgtpl

MAIN_CFG = $(CFG_DIR)/$(MAIN_ROOT).cfg

# Default target
all: $(MAIN_BIN)

install: all
	@echo "Uploading $(MAIN_BIN) to C64U ..."	
	curl -u "user:$(C64U_Password)" --ftp-create-dirs -T "$(MAIN_BIN)" "ftp://$(C64U_ADDRESS)/USB2/HDD/$(MAIN_ROOT).prg"

checkbreakpoint:
	@curl -X GET -H X-Password:$(C64U_Password) http://$(C64U_ADDRESS)/v1/machine:debugreg

resume:
	@curl -X PUT -H X-Password:$(C64U_Password) http://$(C64U_ADDRESS)/v1/machine:debugreg?value=ff

# You can set watches here.  It will look in your .sym file for the address of the label you provide and use the C64U API to read memory 
# at that location.
debug:
	@rm -f $(BUILD_DIR)/debug_output.txt
	@scripts/debug.sh $(BUILD_DIR) $(MAIN_ROOT) $(C64U_ADDRESS) $(C64U_Password) .p_malloc_1 3 >> $(BUILD_DIR)/debug_output.txt
	@scripts/debug.sh $(BUILD_DIR) $(MAIN_ROOT) $(C64U_ADDRESS) $(C64U_Password) .p_malloc_2 3 >> $(BUILD_DIR)/debug_output.txt
	@scripts/debug.sh $(BUILD_DIR) $(MAIN_ROOT) $(C64U_ADDRESS) $(C64U_Password) .p_malloc_3 3 >> $(BUILD_DIR)/debug_output.txt	
	@scripts/debug.sh $(BUILD_DIR) $(MAIN_ROOT) $(C64U_ADDRESS) $(C64U_Password) .p_current 3 >> $(BUILD_DIR)/debug_output.txt
	@scripts/debug.sh $(BUILD_DIR) $(MAIN_ROOT) $(C64U_ADDRESS) $(C64U_Password) .p_new 3 >> $(BUILD_DIR)/debug_output.txt
	@scripts/debug.sh $(BUILD_DIR) $(MAIN_ROOT) $(C64U_ADDRESS) $(C64U_Password) .l_size 2 >> $(BUILD_DIR)/debug_output.txt
	@scripts/debug.sh $(BUILD_DIR) $(MAIN_ROOT) $(C64U_ADDRESS) $(C64U_Password) .block_buffer_1 8 >> $(BUILD_DIR)/debug_output.txt
	@scripts/debug.sh $(BUILD_DIR) $(MAIN_ROOT) $(C64U_ADDRESS) $(C64U_Password) .block_buffer_2 8 >> $(BUILD_DIR)/debug_output.txt
	@scripts/debug2.sh $(BUILD_DIR) $(MAIN_ROOT) $(C64U_ADDRESS) $(C64U_Password) fb 2 PTR1 >> $(BUILD_DIR)/debug_output.txt
	@scripts/debug2.sh $(BUILD_DIR) $(MAIN_ROOT) $(C64U_ADDRESS) $(C64U_Password) fd 2 PTR2 >> $(BUILD_DIR)/debug_output.txt
	@scripts/debug2.sh $(BUILD_DIR) $(MAIN_ROOT) $(C64U_ADDRESS) $(C64U_Password) 02 2 R0 >> $(BUILD_DIR)/debug_output.txt
	@scripts/debug2.sh $(BUILD_DIR) $(MAIN_ROOT) $(C64U_ADDRESS) $(C64U_Password) 04 2 R1 >> $(BUILD_DIR)/debug_output.txt
	@scripts/debug2.sh $(BUILD_DIR) $(MAIN_ROOT) $(C64U_ADDRESS) $(C64U_Password) 06 2 R2 >> $(BUILD_DIR)/debug_output.txt
	@scripts/debug2.sh $(BUILD_DIR) $(MAIN_ROOT) $(C64U_ADDRESS) $(C64U_Password) 08 2 R3 >> $(BUILD_DIR)/debug_output.txt

test: all
	@echo "Running $(MAIN_BIN) on C64U ..."
	curl -X POST http://$(C64U_ADDRESS)/v1/runners:load_prg -H "Content-Type: application/json" -H "X-Password: $(C64U_Password)" -d '{"path": "$(MAIN_BIN)"}'

# Clean target
clean:
	rm -rf $(BUILD_DIR)
	#rm -rf $(EMU_DIR1)/$(MAIN_BIN)	

# Generate configuration files
$(CFG_DIR)/%.cfg: cfg/%.cfgtpl
	@mkdir -p $$(dirname $@)
	$(CC) -E $< -o $@
	cat $@ | sed "s!@BUILD_DIR@!$(BUILD_DIR)!" > $@.tmp
	mv $@.tmp $@	

# Compile assembly files
$(BUILD_DIR)/%.o: %.s
	@mkdir -p $$(dirname $@)
	$(AS) $(ASFLAGS) -l $(BUILD_DIR)/$*.lst $< -o $@

# Link main program
$(MAIN_BIN): $(MAIN_OBJS) $(MAIN_CFG) 
	@mkdir -p $$(dirname $@)
	$(LD) -C $(MAIN_CFG) $(MAIN_OBJS) -o $@ -m $(BUILD_DIR)/$(MAIN_ROOT).map -Ln $(BUILD_DIR)/$(MAIN_ROOT).sym 