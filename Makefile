CC = gcc
OPTIONS = 
EXECUTABLE = analyse_syntax
LEX = ANSI-C.l
YACC = miniC.y

# Define intermediate files generated by lex and yacc
LEX_OUTPUT = lex.yy.c
YACC_OUTPUT = y.tab.c
YACC_HEADER = y.tab.h

all: $(EXECUTABLE)

# Target to compile the final executable
$(EXECUTABLE): $(LEX_OUTPUT) $(YACC_OUTPUT)
	$(CC) $(OPTIONS) $(LEX_OUTPUT) $(YACC_OUTPUT) -o $(EXECUTABLE)
	rm -f $(LEX_OUTPUT) $(YACC_OUTPUT) $(YACC_HEADER)

# Rule for lex to generate lex.yy.c
$(LEX_OUTPUT): $(LEX)
	lex $(LEX)

# Rule for yacc to generate y.tab.c and y.tab.h
$(YACC_OUTPUT) $(YACC_HEADER): $(YACC)
	yacc -d $(YACC)

# Clean target to remove generated files
clean:
	rm -f $(EXECUTABLE)

