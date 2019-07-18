#!/bin/bash

DBPATH=/home/darek/Desktop/baza_skrypt/test
SCRIPTPATH=/home/darek/Desktop/skrypt
OPENSMILE=/home/darek/Desktop/opensmile-2.3.0/config
cd $DBPATH
syntax='ls *.wav'
COUNTER=1

for file in $syntax
do

if [[ $file == "ls" ]]
then
continue
fi

#check which emotion represents this file
emotion="${file:4:3}"
if [[ $emotion == "ang" ]]
then
emoext="anger"
elif [[ $emotion == "neu" ]]
then
emoext="neutral"
elif [[ $emotion == "hap" ]]
then
emoext="happy"
elif [[ $emotion == "sad" ]]
then
emoext="sadness"
elif [[ $emotion == "fea" ]]
then
emoext="fear"
elif [[ $emotion == "sur" ]]
then
emoext="surprised"
fi

emotions="{neutral,happy,sadness,fear,anger,surprised}"

sleep 0.4
#create arff from audio file
/home/darek/Desktop/opensmile-2.3.0/inst/bin/SMILExtract -C $OPENSMILE/emobase.conf -I $file -O $SCRIPTPATH/test.arff -classes $emotions -classlabel $emoext

grep -v "@attribute name string" $SCRIPTPATH/test.arff > $SCRIPTPATH/dsadas.arff
grep -v "@attribute frameTime numeric" $SCRIPTPATH/dsadas.arff > $SCRIPTPATH/test.arff
sed -e "s/'liveturn_0',0.012500,//g" $SCRIPTPATH/test.arff > $SCRIPTPATH/outtest.arff
rm $SCRIPTPATH/test.arff
rm $SCRIPTPATH/dsadas.arff
sleep 0.4
java -classpath /usr/share/java/weka.jar weka.classifiers.trees.J48  -l $SCRIPTPATH/output.model -T $SCRIPTPATH/outtest.arff -p 0
rm $SCRIPTPATH/outtest.arff

done

