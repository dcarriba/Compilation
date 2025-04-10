CC = gcc
OPTIONS = 
EXECUTABLE = analyse_syntax
LEX = ANSI-C.l
YACC = miniC.y

LEX_OUTPUT = lex.yy.c
YACC_OUTPUT = y.tab.c
YACC_HEADER = y.tab.h

.PHONY: all clean run

# Règle pour compiler
all: $(EXECUTABLE)

$(EXECUTABLE): $(LEX_OUTPUT) $(YACC_OUTPUT)
	$(CC) $(OPTIONS) $(LEX_OUTPUT) $(YACC_OUTPUT) -o $(EXECUTABLE)
	rm -f $(LEX_OUTPUT) $(YACC_OUTPUT) $(YACC_HEADER)

$(LEX_OUTPUT): $(YACC_HEADER) $(LEX)
	lex -o $(LEX_OUTPUT) $(LEX)

$(YACC_OUTPUT) $(YACC_HEADER): $(YACC)
	yacc -d -o $(YACC_OUTPUT) $(YACC)

# Règle pour compiler, exécuter et analyser tous les fichiers .c
run: $(EXECUTABLE)
	@if [ ! -f analyse_syntax ]; then \
		echo "[ERREUR] compilation échouée."; \
		exit 1; \
	fi

	@echo "Compilation réussie!\n"

	@echo "Analyse de exempleminiC.c :"
	@./$(EXECUTABLE) < "exempleminiC.c" || continue
	@echo "";

	@if [ ! -d "Tests" ]; then \
		echo "Erreur: Le dossier 'Tests' n'existe pas."; \
		exit 1; \
	fi

	@echo "Analyse des fichiers .c dans le dossier \"Tests\"...\n"
	@for file in Tests/*.c; do \
		echo "Analyse de $$file :"; \
		./$(EXECUTABLE) < $$file || continue; \
		echo ""; \
	done

# Règle pour supprimer l'exécutable et les fichiers intermédiaires
clean:
	rm -f $(EXECUTABLE) $(LEX_OUTPUT) $(YACC_OUTPUT) $(YACC_HEADER)
