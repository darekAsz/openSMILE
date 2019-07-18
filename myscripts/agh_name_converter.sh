#!/bin/bash
syntax='ls *.wav'
for file in $syntax
do

newname=""
#original syntax: AKA_IR_C.wav

#first 3 letters: male or female
#womens
if [ ${file:0:3} == "AKA" ]
then
   newname="fem1"
elif [ ${file:0:3} == "AKL" ]
then
   newname="fem2"
elif [ ${file:0:3} == "HKR" ]
then
   newname="fem3"
elif [ ${file:0:3} == "MMA" ]
then
   newname="fem4"
elif [ ${file:0:3} == "MIG" ]
then
   newname="fem5"
elif [ ${file:0:3} == "BTO" ]
then
   newname="fem6"
fi

#mens
if [ ${file:0:3} == "JMI" ]
then
   newname="mal1"
elif [ ${file:0:3} == "MCH" ]
then
   newname="mal2"
elif [ ${file:0:3} == "MGR" ]
then
   newname="mal3"
elif [ ${file:0:3} == "MPO" ]
then
   newname="mal4"
elif [ ${file:0:3} == "PJU" ]
then
   newname="mal5"
elif [ ${file:0:3} == "PKE" ]
then
   newname="mal6"
fi


#5-6 letters: emotion and record id
if [ ${file:4:2} == "IR" ]
then
   newname="${newname}iro1"
elif [ ${file:4:2} == "NE" ]
then
   newname="${newname}neu2"
elif [ ${file:4:2} == "RA" ]
then
   newname="${newname}hap3"
elif [ ${file:4:2} == "ZD" ]
then
   newname="${newname}sur4"
elif [ ${file:4:2} == "ST" ]
then
   newname="${newname}fea5"
elif [ ${file:4:2} == "SM" ]
then
   newname="${newname}sad6"
elif [ ${file:4:2} == "ZL" ]
then
   newname="${newname}ang7"
fi



#add info what type is this
if [ ${file:7:1} == "C" ]
then
   newname="${newname}dig"
elif [ ${file:7:1} == "P" ]
then
   newname="${newname}ord"
elif [ ${file:7:1} == "T" ]
then
   newname="${newname}tex"
elif [ ${file:7:1} == "Z" ]
then
   newname="${newname}sen"
fi

#add info about database version
newname="${newname}AGH"

#add wav extension
newname="${newname}.wav"

echo $newname

#rename
mv $file $newname

done
