#!/bin/bash

AUDIOPATH=/home/darek/Desktop/baza_skrypt
SCRIPTPATH=/home/darek/Desktop/skrypt
OPENSMILE=/home/darek/Desktop/opensmile-2.3.0/config
emotions="{neutral,happy,sadness,fear,anger,surprised}" #our emotions
result="wynik"
syntax='ls *.wav'
DB_TEST_ID=0 #info which directory (numerated since 1 to 5) is testig directory

for k_fold_iter in 1 2 3 4 5 #loop which makes k-fold cross validation (k iterations)
do
	COUNTER=1
	for dir_number in 1 2 3 4 5 # we go through directories which contains audio files
	do

		if [[ $k_fold_iter -eq $dir_number ]] #we suppose that in k-fold directory k is testing directory
		then 
			DB_TEST_ID=$dir_number
			continue
		fi

		cd $AUDIOPATH/$dir_number
		
		for file in $syntax #for every ile with wav extension in directory $dir_number
		do
			if [[ $file == "ls" ]]
				then
				continue
			fi

			#check which emotion represents this file
			emotion="${file:4:3}"
			if [[ $emotion == "ang" ]]
				then
				emotion="anger"
			elif [[ $emotion == "neu" ]]
				then
				emotion="neutral"
			elif [[ $emotion == "hap" ]]
				then
				emotion="happy"
			elif [[ $emotion == "sad" ]]
				then
				emotion="sadness"
			elif [[ $emotion == "fea" ]]
				then
				emotion="fear"
			elif [[ $emotion == "sur" ]]
				then
				emotion="surprised"
			fi

			#create arff file with data from processing all files from training directories

			if [[ $COUNTER -eq 1 ]]
				then
				sleep 0.2
				/home/darek/Desktop/opensmile-2.3.0/inst/bin/SMILExtract -C $OPENSMILE/emobase.conf -I $file -O $SCRIPTPATH/output.arff -classes $emotions -classlabel $emotion
				sed -i '/@attribute name string/d' $SCRIPTPATH/output.arff #delete unecessary lines
				sed -i '/@attribute frameTime numeric/d' $SCRIPTPATH/output.arff
				sed -i "s/'liveturn_0',0.012500,//g" $SCRIPTPATH/output.arff
				sleep 0.2
			else
				sleep 0.4
				/home/darek/Desktop/opensmile-2.3.0/inst/bin/SMILExtract -C $OPENSMILE/emobase.conf -I $file -O $SCRIPTPATH/temp.arff -classes $emotions -classlabel $emotion
				sleep 0.4
				tail -n 1 $SCRIPTPATH/temp.arff | cut -c23- >> $SCRIPTPATH/output.arff #ignore 1. and 2. parameters and join last line at end of main arff
			fi
			let COUNTER++
		
		done #for with syntax
		
	done #for with dir_number

	#create model
	java -classpath /usr/share/java/weka.jar weka.classifiers.trees.J48  -t $SCRIPTPATH/output.arff -d $SCRIPTPATH/output.model -no-cv -i

	
	#make tests
	cd $AUDIOPATH/$DB_TEST_ID
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
				emotion="anger"
			elif [[ $emotion == "neu" ]]
				then
				emotion="neutral"
			elif [[ $emotion == "hap" ]]
				then
				emotion="happy"
			elif [[ $emotion == "sad" ]]
				then
				emotion="sadness"
			elif [[ $emotion == "fea" ]]
				then
				emotion="fear"
			elif [[ $emotion == "sur" ]]
				then
				emotion="surprised"
			fi
			sleep 0.4
			#create arff from audio file
			/home/darek/Desktop/opensmile-2.3.0/inst/bin/SMILExtract -C $OPENSMILE/emobase.conf -I $file -O $SCRIPTPATH/test.arff -classes $emotions -classlabel $emotion

			grep -v "@attribute name string" $SCRIPTPATH/test.arff > $SCRIPTPATH/dsadas.arff
			grep -v "@attribute frameTime numeric" $SCRIPTPATH/dsadas.arff > $SCRIPTPATH/test.arff
			sed -e "s/'liveturn_0',0.012500,//g" $SCRIPTPATH/test.arff > $SCRIPTPATH/outtest.arff
			rm $SCRIPTPATH/test.arff
			rm $SCRIPTPATH/dsadas.arff
			sleep 0.4
			name="$result$DB_TEST_ID"
			java -classpath /usr/share/java/weka.jar weka.classifiers.trees.J48  -l $SCRIPTPATH/output.model -T $SCRIPTPATH/outtest.arff -p 0 >> $SCRIPTPATH/$name
			rm $SCRIPTPATH/outtest.arff


	done #test done

done









