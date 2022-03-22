#!/bin/bash

re_indeks="^s[0-9]{6}$"	#zmienna wykorzystywana do weryfikowania poprawności wpisywania indeksu
sciezka=""	#zmienna przechowująca ścieżkę do pliku z danymi
wybor=0		#zmienna przechowująca wybór użytkownika
touch /tmp/wyniki.txt	#utworzenie pliku w folderze plików tymczasowych, w którym zapisywanie będą wyniki poszczególnych operacji
echo "Plik wynikowy działania programu:" > /tmp/wyniki.txt #plik jest nadpisywany na wszelki wypadek, gdyby poprzednie uruchomienie programu, nie zostało zakończone przez polecenie numer 8, przez co plik wynikowi nie zostałby usunięty z folderu /tmp
if [ $# -gt 1 ]; then	#warunek, sprawdzający, czy użytkownik nie przesłał więcej niż jeden parametr
echo "Niepoprawna liczba parametrów"
exit 1
else
if [[ $1 =~ $re_indeks ]]; then		#warunek sprawdzający, czy pierwszy parametr jest poprawnie wpisanym indeksem
indeks="$1"
elif [ "$1" == "-v" ]; then		#warunek sprawdzający, czy użytkownik wywołał programu z parametrem -v
echo "Wersja programu: 1.0"
echo "Ostatnia aktualizacja: 20.01.2022 r."
exit 0
elif [ "$1" == "" ]; then	#jeśli żaden parametr nie został przesłany, to pobierany jest indeks użytkownika uruchamiającego program
indeks=$(whoami)
echo "Pobrano numer indeksu osoby uruchamiającej"
else	#w każdym innym wypadku program został wywołany nieprawidłowo i zakończy się jego działanie 
echo "Niepoprawnie przesłany parametr"
exit 1
fi
fi
echo ""
echo "Wpisz numer polecenia bez kropki, aby wybrać co chcesz zrobić:"
while [ $wybor -ne 8 ]; do	#program będzie się powtarzał, dopóki użytkownik nie wyjdzie z niego poleceniem nr 8
echo ""
echo ""
echo "1. Numer indeksu: $indeks"
echo "2. Ścieżka do pliku z danymi: $sciezka"
echo "3. Zweryfikuj informacje w pliku z danymi"
echo "4. Wyświetl całkowitą liczbę studentów"
echo "5. Wyświetl całkowity czas bycia zalogowanym od początku semestru"
echo "6. Wyświetl w formie liczbowej uprawnienia folderów domowych aktualnie zalogowanych użytkowników"
echo "7. Zapisz uzyskane wyniki do pliku tekstowego"
echo "8. Wyjdź z programu"
echo "Wpisz numer polecenia, które chcesz wykonać:"
read wybor	#pobranie wyboru użytkownika, co do wywoływanego polecenia
re="^[1-8]$"
echo ""
while ! [[ $wybor =~ $re ]]; do
echo "Niepoprawnie podano polecenie, spróbuj jeszcze raz:"
read wybor
done
echo ""
echo ""
case $wybor in		#case, który wybiera odpowiednie polecenia na podstawie numeru polecenia, podanego przez użytkownika	
1)
echo "Podaj nowy numer indeksu: "
read i
if [[ $i =~ $re_indeks ]]; then	#indeks nie zostanie ustawiony, jeśli zostanie wpisany w nieprawidłowy sposób
indeks="$i"
else
echo "Niepoprawnie podany indeks"
fi
;;
2)
echo "Podaj ścieżke do pliku z danymi:"
read s
if [ -f $s ]; then	#ścieżka nie zostanie ustawiona, jeśli podany plik nie istnieje lub jeśli nie jest zwykłym plikiem
sciezka="$s"
else
echo "Taki plik nie istnieje"
fi
;;
3)
if [ "$sciezka" != "" ]; then	#plik zostanie wyświetlony tylko, jeśli wcześniej została podana prawidłowa ścieżka do tego pliku
echo "Zawartość pliku:" | tee -a /tmp/wyniki.txt	#tee -a przy niektórych komendach zapisuje wynik od razu do pliku /tmp/wyniki.txt utworzonego na początku programu
cat $sciezka | tee -a /tmp/wyniki.txt
echo ""
if [ "$(cat $sciezka | egrep '^[dlcbsp-][rwx-]{9}')" != "" ]; then	#instrukcja warunkowa określa czy w pliku znajduje się spis plików z atrybutami na podstawie tego, czy są w nim podane uprawnienia 
echo "W pliku znajduje się spis plików z atrybutami" | tee -a /tmp/wyniki.txt
else
echo "W pliku nie ma informacji na temat atrybutów plików" | tee -a /tmp/wyniki.txt
fi
if [ "$(cat $sciezka | egrep '(^\..*$)|( \..*$)')" != "" ]; then #instrukcja warunkowa określa, czy w pliku znajduje się spis plików wraz z plikami ukrytymi, na podstawie tego czy są w nim nazwy zaczynające się od kropki
echo "W pliku uwzględnione są pliki ukryte:" | tee -a /tmp/wyniki.txt
cat $sciezka | egrep '(^\..*$)|( \..*$)' | tee -a /tmp/wyniki.txt
else
echo "W pliku nie ma informacji na temat plików ukrytych" | tee -a /tmp/wyniki.txt
fi
else
echo "Nie podano ścieżki do pliku" 
fi
;;
4)
l_studentow=$(ls -l /home | egrep -c 's[0-9]{6}')	#liczba studentów jest określana na podstawie liczby folderów z indeksami studentów w folderze /home
echo "Liczba studentów to $l_studentow" | tee -a /tmp/wyniki.txt
;;
5)
h=0	#zmienne przechowujące sumaryczną liczbę godzin i minut
m=0
for czas in $(last -s'2021-10-01' $indeks | egrep '\([0-9]{2}:[0-9]{2}\)' | cut -d'(' -f2 | cut -d')' -f1); do	#pętla, w której jako zmienna występuje czas, wyciągnięty z nawiasów na końcach linii, po wywołaniu komendy last
hours=${czas:0:2}	#czas ten jest dzielony na zmienną przechowującą liczbe godzin i zmienną przechowująca liczbę minut
minutes=${czas:3:2}
re="^0[0-9]$"
if [[ $hours =~ $re ]]; then	#Jeśli liczba godzin lub minut jest na przykład w postaci 05, to te intrukcje warunkowe, zamieniają te wartość na samo 5
hours=${hours:1:1}
fi
if [[ $minutes =~ $re ]]; then
minutes=${minutes:1:1}
fi
h=$(($h+$hours))	#czas z każdej iteracji pętli jest dodawany do zmiennych, przechowujących sumaryczną liczbę godzin i minut
m=$(($m+$minutes))
if [ $m -ge 60 ]; then	#jeśli liczba minut jest równa lub przekracza 60, to dodawana jest jedna godzina, a od liczby minut odejmuje się 60, aby ten czas był zapisany po ludzki
h=$(($h+1))
m=$(($m-60))
fi
done
echo "Całkowity czas zalogowania użytkownika o indeksie $indeks to $h godzin i $m minut" | tee -a /tmp/wyniki.txt
;;
6)
for uzytkownik in $(who | cut -d' ' -f1); do	#pętla, w której jako zmienna występuje nazwa użytkownika, spośród zalogowanych użytkowników, wylistowanych komendą who
uprawnienia=$(ls -l /home | grep "$uzytkownik" | cut -d' ' -f1)	#dla użytkownika w danej iteracji pętli, wyciągane są uprawnienia jego folderu domowego
uprawnienia_liczbowo=""		#zmienna, która będzie przechowywać liczbowy zapis uprawnień folderu domowego użytkownika
for (( i=1; i<=7; i=i+3 )); do	#pętla, w której pod uwagę będą brane osobno wszystkie trzy grupy uprawnień (dla właściciela, dla grupy oraz dla reszty użytkowników)
upr=${uprawnienia:$i:3}
ul=0
if [ "${upr:0:1}" == "r" ]; then	#na podstawie poszczególnych uprawnień, obliczana jest liczba, określająca uprawnienia dla właściciela, grupy lub reszty 
ul=$(($ul+4))
fi
if [ "${upr:1:1}" == "w" ]; then
ul=$(($ul+2))
fi
if [ "${upr:2:1}" == "x" ]; then
ul=$(($ul+1))
fi
uprawnienia_liczbowo="${uprawnienia_liczbowo}${ul}"	#na koniec każdej iteracji tej zagnieżdżonej pętli, obliczona liczba jest dołączana do zmiennej, przechowującej liczbowy zapis uprawnień folderu
done
echo "/home/$uzytkownik --> $uprawnienia_liczbowo" | tee -a /tmp/wyniki.txt	#na koniec, wyświetlana jest ścieżka folderu domowego oraz jego uprawnienia dla każdego zalogowanego użytkownika
done
;;
7)
cp /tmp/wyniki.txt $(pwd)	#jeśli użytkownik wybierze numer 7, to plik wynikowy z folderu /tmp zostanie skopiowany do bieżącego folderu, w którym znajduje się użytkownik
echo "Plik wynikowi zapisano w folderze: $(pwd)/wyniki.txt"
;;
8)
rm /tmp/wyniki.txt	#podczas wyłączania programu, usuwany jest plik wyniki.txt z folderu /tmp
;;
esac
done
