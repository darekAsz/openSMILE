#!/bin/bash
syntax='ls *.wav'
for file in $syntax
do

newname=""
#syntax: f1ang1zdLUB.wav

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

#3-5 letters: emotion
emotion="${file:2:3}"
if [ $emotion == "joy" ]
then
   newname="${newname}hap"
else
   newname="$newname$emotion"
fi

#6th letter: record id"
newname="$newname${file:5:1}"

#add info that this is sentence
newname="${newname}sen"

#add info about database version
newname="${newname}LUB"

#add wav extension
newname="${newname}.wav"

echo $newname

#rename
mv $file $newname

done
