#!/bin/bash
FILECOUNT="$(find /home/darek/Desktop/baza_skrypt/* -maxdepth 1 -type f  -name '*.wav' -printf x | wc -c)"
PART=$(( FILECOUNT / 5 ))

for i in 1 2 3 4
do
shuf -n $PART -e /home/darek/Desktop/baza_skrypt/*.wav | xargs -i mv {} /home/darek/Desktop/baza_skrypt/$i/
done

mv /home/darek/Desktop/baza_skrypt/*.wav /home/darek/Desktop/baza_skrypt/5/

#shuf -n 60 -e /home/darek/Desktop/baza_skrypt/*.wav | xargs -i mv {} /home/darek/Desktop/baza_skrypt/test/
#mv /home/darek/Desktop/baza_skrypt/*.wav /home/darek/Desktop/baza_skrypt/training/

