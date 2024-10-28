# Variables
ASSEMBLER = as12
FILE = RogerPiovet_T4
PROCESSOR = 68hcs12
SIMULATOR = sim68cs12
SERIAL = $(shell ls /dev/ttyUSB* | head -n 1)  # Last serial port added must be Dragon12

# Default target
all: ram run

# Load to board
ram: as load

# Targets
as:
	@echo "Assembling $(FILE).asm for $(PROCESSOR) processor..."
	@$(ASSEMBLER) $(FILE).asm -L$(FILE).lst -s$(FILE).sym -o$(FILE).s19 -p$(PROCESSOR) > /dev/null
	@echo "Assembly complete. Generated files: $(FILE).lst, $(FILE).sym, and $(FILE).s19."

sim:
	@echo "Starting simulation of $(FILE).s19 on $(SIMULATOR)..."
	@$(SIMULATOR) $(FILE).s19&
	@echo "Simulation launched successfully."

load:
	@echo "Loading program to Dragon12 board via $(SERIAL)..."
	@echo "load\r" > $(SERIAL)
	@cat $(FILE).s19 > $(SERIAL)
	@echo "Program loaded to Dragon12 board successfully."

run: 
	@echo "Running program on Dragon12 board..."
	@sleep 3
	@echo "g 2000\r" > $(SERIAL)
	@echo "Program execution started at address 0x2000."

clean:
	@echo "Cleaning up generated files..."
	@rm -f $(FILE).lst $(FILE).sym $(FILE).s19
	@echo "Cleanup complete."
