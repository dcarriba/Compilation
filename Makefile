CC = gcc
CFLAGS = -Wall -Wextra -Wpedantic
LEX = flex
YACC = bison
EXECUTABLE = compilateur

LEX_INPUT = ANSI-C.l
YACC_INPUT = miniC.y

LEX_OUTPUT = lex.yy.c
YACC_OUTPUT = y.tab.c
YACC_HEADER = $(YACC_OUTPUT:.c=.h)

LEX_OBJECT = $(LEX_OUTPUT:.c=.o)
YACC_OBJECT = $(YACC_OUTPUT:.c=.o)

# On récupère tous les fichiers utils/*.c
SRCS = $(wildcard utils/*.c)

# Pour générer les fichiers objets de ces fichiers
OBJECTS = $(SRCS:.c=.o)

.PHONY: all clean run

# Règle pour compiler
all: $(EXECUTABLE)

# Pour compiler l'exécutable
$(EXECUTABLE): $(LEX_OBJECT) $(YACC_OBJECT) $(OBJECTS)
	$(CC) $(CFLAGS) $(OBJECTS) $(LEX_OBJECT) $(YACC_OBJECT) -o $(EXECUTABLE)
	rm -f $(LEX_OUTPUT) $(YACC_OUTPUT) $(YACC_HEADER) $(LEX_OBJECT) $(YACC_OBJECT) $(OBJECTS)

# Pour générer le fichier objet de lex.yy.c
$(LEX_OBJECT): $(LEX_OUTPUT)
	$(CC) $(CFLAGS) -c $(LEX_OUTPUT) -o $(LEX_OBJECT)

# Pour générer le fichier objet de y.tab.c
$(YACC_OBJECT): $(YACC_OUTPUT)
	$(CC) $(CFLAGS) -c $(YACC_OUTPUT) -o $(YACC_OBJECT)

# Pour compiler et générer les fichiers objets de tous les fichers utils/*.c
$(OBJECTS): utils/%.o: utils/%.c
	$(CC) $(CFLAGS) -c $< -o $@

# Pour compiler le lex
$(LEX_OUTPUT): $(YACC_HEADER) $(LEX_INPUT)
	$(LEX) -o $(LEX_OUTPUT) $(LEX_INPUT)

# Pour compiler le yacc
$(YACC_OUTPUT) $(YACC_HEADER): $(YACC_INPUT)
	$(YACC) -d -o $(YACC_OUTPUT) $(YACC_INPUT)

# Règle qui compile et qui teste l'exécutable sur exempleminiC.c et tous les fichiers Tests/*.c
run: $(EXECUTABLE)
	@if [ ! -f $(EXECUTABLE) ]; then \
		echo "[ERREUR] compilation échouée."; \
		exit 1; \
	fi

	@echo "Compilation réussie!\n"

	@echo "Analyse de exempleminiC.c :"
	@./$(EXECUTABLE) exempleminiC.c 2>&1 || echo "Error $$?" >&2;
	@echo "";

	@if [ ! -d "Tests" ]; then \
		echo "Erreur: Le dossier 'Tests' n'existe pas."; \
		exit 1; \
	fi

	@echo "Analyse des fichiers .c dans le dossier \"Tests\"...\n"
	@for file in Tests/*.c; do \
		echo "Analyse de $$file :"; \
		./$(EXECUTABLE) $$file 2>&1 || echo "Error $$?" >&2; \
		echo ""; \
	done

# Règle pour supprimer l'exécutable et tous les fichiers intermédiaires
clean:
	rm -f $(EXECUTABLE) $(LEX_OUTPUT) $(YACC_OUTPUT) $(YACC_HEADER) $(LEX_OBJECT) $(YACC_OBJECT) $(OBJECTS)
