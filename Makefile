CC = gcc
CFLAGS = -Wall -Wextra -Wpedantic
# -fsanitize=address (option gcc pour voir les fuites mémoires)
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

# Pour exécuter avec valgrind et voir les fuites mémoires
VALGRIND = valgrind
VALGRIND_FLAGS = --leak-check=full --show-leak-kinds=all -s

# Pour générer les graphiques dot
DOT = dot
DOT_OUTPUT_FORMAT = pdf

# On récupère tous les fichiers utils/*.c
SRCS = $(wildcard utils/*.c)

# Pour générer les fichiers objets de ces fichiers
OBJECTS = $(SRCS:.c=.o)

# Pour afficher sur le terminal en couleur
RED     := \033[1;31m
GREEN   := \033[1;32m
YELLOW  := \033[1;33m
CYAN    := \033[1;36m
RESET   := \033[0m

.PHONY: all clean run debug valgrind-run run-error valgrind-run-error run-warning valgrind-run-warning

# Règle pour compiler
all: $(EXECUTABLE)

# Pour compiler l'exécutable
$(EXECUTABLE): $(LEX_OBJECT) $(YACC_OBJECT) $(OBJECTS)
	rm -f *.dot *.dot.$(DOT_OUTPUT_FORMAT) Tests/*.dot Tests/*.dot.$(DOT_OUTPUT_FORMAT) TestsWarning/*.dot TestsWarning/*.dot.$(DOT_OUTPUT_FORMAT)
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


VALGRIND_COMMAND =
TEST_DIRECTORY = Tests
ANAYLSE_EXEMPLEMINIC = true

# Règle qui compile et qui teste l'exécutable sur exempleminiC.c et tous les fichiers Tests/*.c
run: $(EXECUTABLE)
	@if [ ! -f $(EXECUTABLE) ]; then \
		echo "$(RED)[Error] Compilation échouée.$(RESET)"; \
		exit 1; \
	fi

	@echo "$(GREEN)Compilation réussie!$(RESET)\n"

	@if [ "$(ANAYLSE_EXEMPLEMINIC)" = "true" ]; then \
		echo "Analyse de exempleminiC.c :"; \
		( $(VALGRIND_COMMAND) ./$(EXECUTABLE) exempleminiC.c && ( $(DOT) -T$(DOT_OUTPUT_FORMAT) exempleminiC.dot -o exempleminiC.dot.$(DOT_OUTPUT_FORMAT) ; echo "Génération de exempleminiC.dot.$(DOT_OUTPUT_FORMAT) à partir de exempleminiC.dot avec la commande $(DOT)" )) || echo "$(RED)Code erreur : $$?$(RESET)" >&2; \
		echo ""; \
	fi

	@if [ ! -d "$(TEST_DIRECTORY)" ]; then \
		echo "$(RED)[Error] Le dossier '$(TEST_DIRECTORY)' n'existe pas.$(RESET)"; \
		exit 1; \
	fi

	@echo "Analyse des fichiers .c dans le dossier \"$(TEST_DIRECTORY)\"...\n"
	@for file in $(TEST_DIRECTORY)/*.c; do \
		echo "Analyse de $$file :"; \
		base=$$(basename $$file .c); \
		( $(VALGRIND_COMMAND) ./$(EXECUTABLE) $$file && ( $(DOT) -T$(DOT_OUTPUT_FORMAT) $(TEST_DIRECTORY)/$$base.dot -o $(TEST_DIRECTORY)/$$base.dot.$(DOT_OUTPUT_FORMAT) && echo "Génération de $(TEST_DIRECTORY)/$$base.dot.$(DOT_OUTPUT_FORMAT) à partir de $(TEST_DIRECTORY)/$$base.dot avec la commande $(DOT)" )) || echo "$(RED)Code erreur : $$?$(RESET)" >&2; \
		echo ""; \
	done

# Règle qui compile et qui teste l'exécutable avec valgrind sur exempleminiC.c et tous les fichiers Tests/*.c
valgrind-run: VALGRIND_COMMAND = $(VALGRIND) $(VALGRIND_FLAGS)
valgrind-run: run

# Règle qui compile et qui teste l'exécutable sur tous les fichiers TestsError/*.c
run-error: TEST_DIRECTORY = TestsError
run-error: ANAYLSE_EXEMPLEMINIC = false
run-error: run

# Règle qui compile et qui teste l'exécutable avec valgrind sur tous les fichiers TestsError/*.c
valgrind-run-error: VALGRIND_COMMAND = $(VALGRIND) $(VALGRIND_FLAGS)
valgrind-run-error: run-error

# Règle qui compile et qui teste l'exécutable sur tous les fichiers TestsWarning/*.c
run-warning: TEST_DIRECTORY = TestsWarning
run-warning: ANAYLSE_EXEMPLEMINIC = false
run-warning: run

# Règle qui compile et qui teste l'exécutable avec valgrind sur tous les fichiers TestsWarning/*.c
valgrind-run-warning: VALGRIND_COMMAND = $(VALGRIND) $(VALGRIND_FLAGS)
valgrind-run-warning: run-warning

# Règle pour compiler avec l'option -g de gcc afin de pouvoir débugger
debug: CFLAGS += -g
debug: $(EXECUTABLE)

# Règle pour supprimer l'exécutable et tous les fichiers intermédiaires
clean:
	rm -f *.dot *.dot.$(DOT_OUTPUT_FORMAT) Tests/*.dot Tests/*.dot.$(DOT_OUTPUT_FORMAT) TestsWarning/*.dot TestsWarning/*.dot.$(DOT_OUTPUT_FORMAT)
	rm -f $(EXECUTABLE) $(LEX_OUTPUT) $(YACC_OUTPUT) $(YACC_HEADER) $(LEX_OBJECT) $(YACC_OBJECT) $(OBJECTS)
