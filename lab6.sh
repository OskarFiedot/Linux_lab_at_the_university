#!/bin/bash

re="^[0-7]{3}"
if [ "$1" == "-h" -o "$1" == "--help" ]; then		#if sprawdza, czy użytkownik prosił o wyświetlenie pomocy dla tego skryptu
echo "Składnia: ./zadanie2.sh NAZWA_FOLDERU NAZWA_PLIKU UPRAWNIENIA_FOLDERU UPRAWNIENIA_PLIKU"
echo "Opis:"
echo "Skrypt 'zadanie2.sh' tworzy folder o nazwie NAZWA_FOLDERU i uprawnieniach UPRAWNIENIA_FOLDERU, następnie tworzy w tym folderze plik o nazwie NAZWA_PLIKU, z uprawnieniami określonymi w UPRAWNIENIA_PLIKU."
echo "Uprawnienia należy podawać w fomie liczbowej, np. 770"
exit 0
elif [ $# -ne 4 ]; then		#Jeśli nie, to funkcja warunkowa sprawdza czy została przesłana odpowiednia ilość argumentów. Jeśli tak nie było, program zakończy swoje działanie. 
echo "Niepoprawna liczba argumentów, przesłanych do programu (powinno być ich 4)"
exit 1
elif ! [[ $3 =~ $re ]]; then	#ify, które sprawdzają, czy poprawnie podano uprawnienia
echo "Niepoprawnie podane uprawnienia dla folderu"
exit 1
elif ! [[ $4 =~ $re ]]; then
echo "Niepoprawnie podane uprawnienia dla pliku"
exit 1
fi
#Jeśli użytkownik nie prosił o wyświetlenie pomocy oraz jeśli liczba przesłanych argumentów i sposób wysłania uprawnień były prawidłowe, program wykonuje swoje zadanie
if ! [ -d $1 ]; then 
mkdir $1	#Utworzenie folderu o nazwie NAZWA_FOLDERU
echo "Utworzono folder $1"
else
echo "Folder $1 już istnieje"
fi
chmod $3 $1	#Nadanie uprawnień folderowi
echo "Nadano folderowi $1 uprawnienia $3"
re="^[37][0-7][0-7]"
if ! [[ $3 =~ $re ]]; then	#Sprawdzenie czy uprawnienia nadane folderowi pozwalają na stworzenie w nim folderu
echo "Uprawnienia folderu nie pozwalają na dokończenie operacji"
exit 0
fi
cd $1		#Wejście do utworzonego folderu
if ! [ -f $2 ]; then
touch $2	#Utworzenie pliku o nazwie takiej, jaka została przesłana do programu jako drugi parametr
echo "Stworzono plik $2 w folderze $1"
else
echo "Plik $2 już istnieje w folderze $1"
fi
chmod $4 $2	#Ustawienie wcześniej utworzonemu plikowu uprawnień dostępu, które zostały przesłane do programu jako czwarty parametr
echo "Nadano plikowi $2 w folderze $1 uprawnienia $4"
