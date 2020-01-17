# Deaconu Andreea-Carina 334CC

build: 
	lex xml_parser.l
	gcc lex.yy.c 

clean:
	rm a.out lex.yy.c
