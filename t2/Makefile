# Variables
ASSEMBLER = as12
FILE = problema3
PROCESSOR = 68hcs12
SIMULATOR = sim68cs12

# Default
all: as sim

# Targets
as:
	$(ASSEMBLER) $(FILE).asm -L$(FILE).lst -s$(FILE).sym -o$(FILE).s19 -p$(PROCESSOR)

sim: 
	$(SIMULATOR) $(FILE).s19&

clean:
	rm -f $(FILE).lst $(FILE).sym $(FILE).s19
