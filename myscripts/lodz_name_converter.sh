#!/bin/bash
syntax='ls *.wav'
for file in $syntax
do

newname=""
#original syntax: f1_1a.wav

#first letter: male or female
if [ ${file:0:1} == "m" ]
then
   newname="mal"
elif [ ${file:0:1} == "f" ]
then
   newname="fem"
fi

#second letter: speaker id
newname="$newname${file:1:1}"

#5th letter: emotion
emotion="${file:4:1}"
if [ $emotion == "a" ]
then
   newname="${newname}ang"
elif [ $emotion == "d" ]
then
   newname="${newname}dis"
elif [ $emotion == "f" ]
then
   newname="${newname}fea"
elif [ $emotion == "h" ]
then
   newname="${newname}hap"
elif [ $emotion == "n" ]
then
   newname="${newname}neu"
elif [ $emotion == "s" ]
then
   newname="${newname}sad"
elif [ $emotion == "u" ]
then
   newname="${newname}sur"
fi

#4th letter: record id
newname="$newname${file:3:1}"

#add info that this is sentence
newname="${newname}sen"

#add info about database version
newname="${newname}LODZ"

#add wav extension
newname="${newname}.wav"

echo $newname

#rename
mv $file $newname

done
