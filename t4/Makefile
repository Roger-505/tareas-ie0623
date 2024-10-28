# Variables
ASSEMBLER = as12
FILE = ROGERDANIELPIOVETGARCIA_T4
PROCESSOR = 68hcs12
SIMULATOR = sim68cs12
SERIAL = $(shell ls /dev/ttyUSB* | head -n 1)	# Last serial port added must be Dragon12

# Default
all: ram run

# Load to board
ram: as load

# Targets
as:
	$(ASSEMBLER) $(FILE).asm -L$(FILE).lst -s$(FILE).sym -o$(FILE).s19 -p$(PROCESSOR)

sim:
	$(SIMULATOR) $(FILE).s19&

load:
	@echo "load\r" > $(SERIAL)
	@cat $(FILE).s19 > $(SERIAL)

run: 
	@sleep 3
	@echo "g 2000\r" > $(SERIAL)

clean:
	rm -f $(FILE).lst $(FILE).sym $(FILE).s19
