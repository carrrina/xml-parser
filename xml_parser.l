/* Deaconu Andreea-Carina 334CC */

%{
	#include <stdio.h>
	#define CAPACITY 2000
	#define NUMBER_SIZE 20 
	#define SIZE 100
	char **tree; int indx; // retine output-ul final, linie cu linie
	char **tags; int tags_indx; // vector folosit sub forma de stiva, adaug un tag parinte si il scot cand se inchide, ca sa stiu cand decrementez adancimea
	char *aux, *current_tag, *first_tag, *last_tag;
	int depth, i, j, list_indx;
%}

%option noyywrap
%option stack

start_first_line "<?" 
end_first_line "?>" 
start_comm "<!--"
end_comm "-->"
valid_name [-_,a-zA-Z0-9]+
valid_text [^<\n\t ][^<]*
valid_value [^"]+

%x FIRST_LINE
%x COMMENT
%x ATTRIBUTE_TAG

%%

{start_first_line} yy_push_state(FIRST_LINE); 
<FIRST_LINE>{end_first_line} yy_pop_state(); 
<FIRST_LINE>. {	}

{start_comm} yy_push_state(COMMENT);
<COMMENT>{end_comm} yy_pop_state();
<COMMENT>.|\n {	}


"<"{valid_name}">" { // tag fara atribute

	if (first_tag == NULL) { // daca e primul tag de dupa <root>, il retin
		tree = malloc(CAPACITY * sizeof(char*)); 
		indx = -1;
		tree[++indx] = malloc(strlen("<root>") + 1);
		strcpy(tree[indx], "<root>");
		depth = 1;

		tags = malloc(CAPACITY * sizeof(char*));
		tags_indx = -1;
		list_indx = 0;
		aux = NULL; 
		current_tag = NULL;
		last_tag = NULL;

		first_tag = calloc(yyleng - 2 + 1, 1); 
		strncpy(first_tag, yytext + 1, yyleng - 2);
	}

	if (current_tag != NULL) { // este vorba despre un tag imbricat, afisez tag-ul parinte sub forma: <nume_tag>
		 tags[++tags_indx] = malloc(strlen(current_tag) + 1); 
		 strcpy(tags[tags_indx], current_tag); // intai retin tag-ul in vectorul folosit sub forma de stiva, pentru momentul cand se va inchide tag-ul

		 tree[++indx] = calloc(strlen(current_tag) + 2 + depth, 1);
		 for (i = 0; i < depth; i++) 
		 	tree[indx][i] = '\t'; // adaug atatea '/t' in functie de adancimea curenta

		 strcat(tree[indx], "<"); 
		 if (list_indx > 0) { // daca sunt intr-o lista
		 	free(current_tag); 
			current_tag = calloc(SIZE, 1);
		 	sprintf(current_tag, "%d", list_indx); // afisez indexul, nu numele tag-ului
		 }
		 strcat(tree[indx], current_tag); 
		 strcat(tree[indx], ">");

		 free(current_tag); current_tag = NULL; 
		 depth++; 
	}

	current_tag = malloc(yyleng - 2 + 1); 
	strncpy(current_tag, yytext + 1, yyleng - 2); // retin tag-ul acum citit
	current_tag[yyleng - 2] = '\0';

	if (last_tag != NULL && !strcmp(current_tag, last_tag)) { // tagul e identic cu cel precedent, deci este vorba despre o lista
		if (list_indx == 0) { // sunt la elementul cu indexul 1, trebuie sa modific afisarea tag-ului precedent (cu indexul 0)
			i = indx; // pornesc de la ultima linie scrisa in tree[]
			char *tmp;
			tmp = calloc(strlen(last_tag) + 2, 1);
			strcpy(tmp, last_tag); 
			tmp[strlen(last_tag)] = '>'; 
			while (strcmp(tree[i] + depth + 1, tmp)) { // pana ajung la inceputul tag-ului
				tree[i + 1] = malloc(strlen(tree[i]) + 1);
				tree[i + 1][0] = '\t'; // adaug cate un tab la fiecare linie
				strcpy(tree[i + 1] + 1, tree[i]); // si mut fiecare linie cu o linie mai jos, facand loc pentru linia pe care voi afisa "<0>"
				free(tree[i]);
				i--;
			}
			tree[i + 1] = malloc(strlen("<0>") + depth + 1 + 1); // acum sunt la inceputul tag-ului
			for (j = 0; j < depth + 1; j++) 
				tree[i + 1][j] = '\t';
			strcpy(tree[i + 1] + depth + 1, "<0>"); // scriu "<0>"
			indx++;
			list_indx++;
			depth++;
		} else { // sunt la elementul cu indexul 2 sau mai mare, doar cresc indexul
			list_indx++;
		}
	} 
}

"</"{valid_name}">" { // inchiderea unui tag

	if (last_tag) 
		free(last_tag);
	last_tag = calloc(yyleng - 3 + 1, 1);
	strncpy(last_tag, yytext + 2, yyleng - 3); // retin tagul care s-a inchis

	if (!strcmp(first_tag, last_tag)) { // daca s-a inchis primul tag de dupa root (nu mai sunt taguri imbricate), afisez output-ul retinut in tree[]
		for (i = 0; i <= indx; i++)
			printf("%s\n", tree[i]);
		for (i = 0; i <= indx; i++)
			free(tree[i]);
		free(tree);
		free(first_tag);
		first_tag = NULL;
	}
	if (!strcmp(last_tag, tags[tags_indx])) { // verific daca trebuie sa decrementez depth
		free(tags[tags_indx]); 
		tags_indx--;
		depth--;
	}
	if (current_tag) {	
		free(current_tag);
		current_tag = NULL;
	}
}

"<"{valid_name}" " { // tag cu atribute

	yy_push_state(ATTRIBUTE_TAG); 

	if (first_tag == NULL) { // daca e primul tag de dupa <root>, il retin
		tree = malloc(CAPACITY * sizeof(char*)); 
		indx = -1;
		tree[++indx] = malloc(strlen("<root>") + 1);
		strcpy(tree[indx], "<root>");
		depth = 1;

		tags = malloc(CAPACITY * sizeof(char*));
		tags_indx = -1;
		list_indx = 0;
		aux = NULL; 
		current_tag = NULL;
		last_tag = NULL;

		first_tag = calloc(yyleng - 2 + 1, 1); 
		strncpy(first_tag, yytext + 1, yyleng - 2);
	}

	if (current_tag != NULL) { // este vorba despre un tag imbricat, afisez tag-ul parinte sub forma: <nume_tag>
		tags[++tags_indx] = malloc(strlen(current_tag) + 1); // intai retin tag-ul in vectorul folosit sub forma de stiva, pentru momentul cand se va inchide tag-ul
		strcpy(tags[tags_indx], current_tag);

		tree[++indx] = calloc(strlen(current_tag) + 2 + depth, 1);
		for (i = 0; i < depth; i++) 
			tree[indx][i] = '\t'; // adaug atatea '/t' in functie de adancimea curenta

		strcat(tree[indx], "<"); 
		if (list_indx > 0) { // daca sunt intr-o lista
		 	free(current_tag); 
			current_tag = calloc(SIZE, 1); 
		 	sprintf(current_tag, "%d", list_indx); // afisez indexul, nu numele tag-ului
		}
		strcat(tree[indx], current_tag); 
		strcat(tree[indx], ">");

		depth++; 
		free(current_tag); 
		current_tag = NULL;
	}
	
	current_tag = malloc(yyleng - 2 + 1); 
	strncpy(current_tag, yytext + 1, yyleng - 2); // retin tag-ul acum citit
	current_tag[yyleng - 2] = '\0'; 

	if (last_tag != NULL && !strcmp(current_tag, last_tag)) { // tagul e identic cu cel precedent, deci este vorba despre o lista
		if (list_indx == 0) { // sunt la elementul cu indexul 1, trebuie sa modific afisarea tag-ului precedent (cu indexul 0)
			i = indx; // pornesc de la ultima linie scrisa in tree[]
			char *tmp;
			tmp = calloc(strlen(last_tag) + 2, 1);
			strcpy(tmp, last_tag); 
			tmp[strlen(last_tag)] = '>';
			while (strcmp(tree[i] + depth + 1, tmp)) { // pana ajung la inceputul tag-ului
				tree[i + 1] = malloc(strlen(tree[i]) + 1);
				tree[i + 1][0] = '\t'; // adaug cate un tab la fiecare linie
				strcpy(tree[i + 1] + 1, tree[i]); // si mut fiecare linie cu o linie mai jos, facand loc pentru linia pe care voi afisa "<0>"
				free(tree[i]);
				i--;
			}
			tree[i + 1] = malloc(strlen("<0>") + depth + 1 + 1); // acum sunt la inceputul tag-ului
			for (j = 0; j < depth + 1; j++) 
				tree[i + 1][j] = '\t';
			strcpy(tree[i + 1] + depth + 1, "<0>"); // scriu "<0>"
			indx++;
			list_indx++;
			depth++;
		} else { // sunt la elementul cu indexul 2 sau mai mare, doar cresc indexul
			list_indx++;
		}
	}  

	tags[++tags_indx] = malloc(strlen(current_tag)); 
	strcpy(tags[tags_indx], current_tag); // retin tag-ul in stiva pentru momentul cand se va inchide

	// vreau sa afisez tag-ul curent sub forma <nume_tag>
	tree[++indx] = calloc(strlen(current_tag) + 2 + depth, 1); 
	for (i = 0; i < depth; i++) 
		tree[indx][i] = '\t';
	strcat(tree[indx], "<");
	if (list_indx > 0 && last_tag != NULL && !strcmp(last_tag, current_tag)) { // daca sunt intr-o lista
		free(current_tag); 
		current_tag = calloc(SIZE, 1);
	 	sprintf(current_tag, "%d", list_indx); // afisez indexul, nu numele tag-ului
	}
	strcat(tree[indx], current_tag);
	strcat(tree[indx], ">");
	free(current_tag);
	current_tag = NULL;
	depth++;
}

<ATTRIBUTE_TAG>{valid_name}= { // un nume de atribut
	aux = calloc(SIZE, 1); 
	for (i = 0; i < depth; i++) 
		aux[i] = '\t';
	strcat(aux, "_");
	strncat(aux, yytext, strlen(yytext) - 1);
	strcat(aux, " : ");
}

<ATTRIBUTE_TAG>["]{valid_value}["]" " { // valoarea unui atribut
	strncat(aux, yytext + 1, strlen(yytext) - 3);
	tree[++indx] = malloc(strlen(aux));
	strcpy(tree[indx], aux);
	free(aux); 
	aux = NULL;
}

<ATTRIBUTE_TAG>["]{valid_value}["]">" { // valoarea ultimului atribut al unui element care nu e gol
	strncat(aux, yytext + 1, strlen(yytext) - 3);
	tree[++indx] = malloc(strlen(aux));
	strcpy(tree[indx], aux);
	free(aux); 
	aux = NULL; 

	yy_pop_state();
}

<ATTRIBUTE_TAG>["]{valid_value}["]"/>" { // valoarea ultimului atribut al unui element gol
	strncat(aux, yytext + 1, strlen(yytext) - 4);
	tree[++indx] = malloc(strlen(aux));
	strcpy(tree[indx], aux);
	free(aux); 
	aux = NULL;

	depth--; 
	yy_pop_state();
}

{valid_text} { // text al unui element
	if (current_tag != NULL) { // afisare sub forma "nume_tag : text"
		tree[++indx] = calloc(depth + strlen(current_tag) + 3 + yyleng + 1, 1);
		for (i = 0; i < depth; i++) 
			tree[indx][i] = '\t';
		if (list_indx > 0 && last_tag != NULL && !strcmp(last_tag, current_tag)) { // daca face parte dintr-o lista, afisez indexul, nu numele tag-ului
			free(current_tag); 
			current_tag = calloc(SIZE, 1);
			sprintf(current_tag, "%d", list_indx);
		}
		strcat(tree[indx], current_tag);
		strcat(tree[indx], " : ");
  		strcat(tree[indx], yytext); 
		free(current_tag); 
		current_tag = NULL;
         } 
	 else {  // afisare sub forma "__text : text"
		tree[++indx] = calloc(depth + strlen("__text") + 3 + yyleng + 1, 1);
		for (i = 0; i < depth; i++) 
			tree[indx][i] = '\t';
		strcat(tree[indx], "__text");
		strcat(tree[indx], " : ");
  		strcat(tree[indx], yytext); 
	}
}

.|\n {	}
%%


int main (int argc, char **argv) {

	yyin = fopen(argv[1], "r");
	if (!yyin) {
		printf("eroare la deschiderea fisierului");
		exit(1);
	}
	yylex();
	return 0;
}
