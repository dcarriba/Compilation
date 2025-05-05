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

# Pour afficher sur le shell en couleur
RED     := \033[1;31m
GREEN   := \033[1;32m
YELLOW  := \033[1;33m
CYAN    := \033[1;36m
RESET   := \033[0m

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
		echo "$(RED)[Error] Compilation échouée.$(RESET)"; \
		exit 1; \
	fi

	@echo "$(GREEN)Compilation réussie!$(RESET)\n"

	@echo "Analyse de exempleminiC.c :"
	@./$(EXECUTABLE) exempleminiC.c || echo "$(RED)Error $$?$(RESET)" >&2;
	@echo "";

	@if [ ! -d "Tests" ]; then \
		echo "$(RED)[Error] Le dossier 'Tests' n'existe pas.$(RESET)"; \
		exit 1; \
	fi

	@echo "Analyse des fichiers .c dans le dossier \"Tests\"...\n"
	@for file in Tests/*.c; do \
		echo "Analyse de $$file :"; \
		./$(EXECUTABLE) $$file || echo "$(RED)Error $$?$(RESET)" >&2; \
		echo ""; \
	done

# Règle pour compiler avec l'option -g de gcc afin de pouvoir débugger avec gdb
gdb: CFLAGS += -g
gdb: $(EXECUTABLE)

# Règle pour supprimer l'exécutable et tous les fichiers intermédiaires
clean:
	rm -f $(EXECUTABLE) $(LEX_OUTPUT) $(YACC_OUTPUT) $(YACC_HEADER) $(LEX_OBJECT) $(YACC_OBJECT) $(OBJECTS)