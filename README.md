# XML parser
Output-ul este pastrat linie cu linie in tree[], urmand sa fac afisarea la inchiderea primului tag de dupa root.

Ca stari am considerat:
- FIRST_LINE, pentru a trece peste prima linie dintr-un fisier XML (exemplu <?xml version="1.0"?>), ea e marcata la inceput de "<?" si la final de "?>"
Cand ajung la final, scot starea din stiva.
- COMMENT pentru a trece peste comentarii, la inceput sunt marcate cu "<!--", iar la final cu "-->"
Cand ajung la final, scot starea din stiva.
- ATTRIBUTE_TAG, care citeste tag-ul unui element cu atribute, gol sau nu. Il identific pentru ca e de forma: "<nume " (are un spatiu dupa nume) si stiu ca se termina cu ">".
Numele atributelor sunt de forma "nume=" (au un egal), iar valoarea lor este intre ghilimele. Cand am gasit un nume, il pastrez in aux, urmand sa concatenez apoi valoarea. Cand am gasit ultimul atribut (se termina cu ">"), scot starea din stiva. Daca atributul era gol ("/>"), scad si adancimea.


De fiecare data cand incepe un tag nou, intai verific daca tag-ul precedent a fost inchis sau nu (current_tag != NULL). Daca nu a fost inchis, inseamna ca este vorba despre un tag imbricat si il afisez sub forma <nume>. Tin cont si daca sunt intr-o lista, caz in care afisez indexul, nu numele.
In continuare, verific daca tag-ul acum citit face parte dintr-o lista (mai devreme era vorba despre tag-ul parinte). Daca sunt abia la elementul cu indexul 1, trebuie sa parcurg tree[] ca sa modific afisarea tag-ului precedent (adaug un tab in plus la fiecare linie si o linie pentru "<0>"). Daca sunt la un element cu un index mai mare, doar increment indexul listei. 
Pastrez tag-urile imbricate si intr-un vector folosit pe post de stiva, tags[], ca sa stiu daca trebuie sa decrementez adancimea la inchiderea lor.

Inchiderea unui tag:
- actualizez variabila last_tag
- vad daca s-a inchis first_tag, caz in care fac afisarea
- compar cu varful vectorului-stiva tags[], pentru a modifica adancimea

Tratarea textului dintr-un tag - 2 cazuri:
- tag-ul are atribute sau alte tag-uri imbricate, caz in care afisez sub forma "__text : ..."
- cazul opus, cand afisez sub forma "nume_tag : ..."
Verificarea o fac folosind variabila current_tag, ce pastreaza numele tag-ului daca acesta nu are atribute sau alte tag-uri imbricate.
