#!/bin/bash

#
#
# DESCRIPTION
# First, we make k-fold cross validation, where we:
# 1.we go through directories which contains audio files and for every file with wav extension in directory $dir_number we calculate metrics and save them in arff file
# 2.create model
# 3. make tests and save output for every k-fold step in another file 
# 4.perform data, create confusion matrix,  calculation recall and precision

#####################################################################################

AUDIOPATH=/home/darek/Desktop/baza_skrypt
SCRIPTPATH=/home/darek/Desktop/skrypt
OPENSMILE=/home/darek/Desktop/opensmile-2.3.0/config
#emotions="{neutral,happy,sadness,fear,anger,surprised,boredom,disgust,ironic}" #our emotions #NEED CHANGE HERE
emotions="{neutral,happy,sadness,fear,anger,surprised}"
result="wynik"
syntax='ls *.wav'
DB_TEST_ID=0 #info which directory (numerated since 1 to 5) is testig directory
emotions_number=6 #NEED CHANGE HERE
CONF_NAME="emo_large.conf"


#####################################################################################

#create key-value pair (number-emotion)
declare -A emotion
emotion=( [1]="neutral" [2]="happy" [3]="sadness"  [4]="fear" [5]="anger" [6]="surprised") #NEED CHANGE HERE
#emotion=( [1]="happy" [2]="sadness"  [3]="fear" [4]="anger" )
#emotion=( [1]="neutral" [2]="happy" [3]="sadness"  [4]="fear" [5]="anger" [6]="surprised" [7]="boredom" [8]="disgust" [9]="ironic")
#function to print spaces (needed while print matrix)
function print_with_tab() {
	length=10
	text=$1
	spaces_to_print=$(expr $length - ${#text})
	echo -n $text
	for nr in $( eval echo {0..$spaces_to_print} )
	do 
		echo -n " "
	done 
}



#####################################################################################


#k fold cross validation (make model and test)
for k_fold_iter in 1 2 3 4 5 #loop which makes k-fold cross validation (k iterations)
do
	COUNTER=1
	for dir_number in 1 2 3 4 5 # we go through directories which contains audio files - CREATE ARFF FILE
	do

		if [[ $k_fold_iter -eq $dir_number ]] #we suppose that in k-fold directory k is testing directory
		then 
			DB_TEST_ID=$dir_number
			continue
		fi

		cd $AUDIOPATH/$dir_number
		
		for file in $syntax #for every file with wav extension in directory $dir_number we calculate metrics and save them in arff file
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
			elif [[ $emotion == "bor" ]]
				then
				emotion="boredom"
			elif [[ $emotion == "dis" ]]
				then
				emotion="disgust"
			elif [[ $emotion == "iro" ]]
				then
				emotion="ironic"
			fi

			#create arff file with data from processing all files from training directories

			if [[ $COUNTER -eq 1 ]] # create main arff file only once
				then
				sleep 0.4
				/home/darek/Desktop/opensmile-2.3.0/inst/bin/SMILExtract -C $OPENSMILE/$CONF_NAME -I $file -O $SCRIPTPATH/output.arff -classes $emotions -classlabel $emotion
				sed -i '/@attribute name string/d' $SCRIPTPATH/output.arff #delete unecessary lines
				sed -i '/@attribute frameTime numeric/d' $SCRIPTPATH/output.arff
				if [[ $CONF_NAME = "emobase.conf" ]]
					then
					sed -i "s/'liveturn_0',0.012500,//g" $SCRIPTPATH/output.arff
				elif [[ $CONF_NAME = "emo_large.conf" ]]
					then
					sed -i "s/'noname',0.012500,//g" $SCRIPTPATH/output.arff				
				fi				
				sleep 0.4
			else
				sleep 0.6
				/home/darek/Desktop/opensmile-2.3.0/inst/bin/SMILExtract -C $OPENSMILE/$CONF_NAME -I $file -O $SCRIPTPATH/temp.arff -classes $emotions -classlabel $emotion
				sleep 0.6
				tail -n 1 $SCRIPTPATH/temp.arff | cut -c23- >> $SCRIPTPATH/output.arff #ignore 1. and 2. parameters and join last line at end of main arff
			fi
			let COUNTER++
		
		done #for with syntax
		
	done #for with dir_number - END CREATE ARFF FILE


#####################################################################################


	#CREATE MODEL
	java -classpath /usr/share/java/weka.jar weka.classifiers.trees.J48  -t $SCRIPTPATH/output.arff -d $SCRIPTPATH/output.model -no-cv -i

	
#####################################################################################

	#MAKE TESTS
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
			elif [[ $emotion == "bor" ]]
				then
				emotion="boredom"
			elif [[ $emotion == "dis" ]]
				then
				emotion="disgust"
			elif [[ $emotion == "iro" ]]
				then
				emotion="ironic"
			fi
			sleep 0.6
			#create arff from audio file
			/home/darek/Desktop/opensmile-2.3.0/inst/bin/SMILExtract -C $OPENSMILE/$CONF_NAME -I $file -O $SCRIPTPATH/test.arff -classes $emotions -classlabel $emotion

			grep -v "@attribute name string" $SCRIPTPATH/test.arff > $SCRIPTPATH/dsadas.arff
			grep -v "@attribute frameTime numeric" $SCRIPTPATH/dsadas.arff > $SCRIPTPATH/test.arff
			if [[ $CONF_NAME = "emobase.conf" ]]
				then
				sed -i "s/'liveturn_0',0.012500,//g" $SCRIPTPATH/test.arff
			elif [[ $CONF_NAME = "emo_large.conf"	]]
				then
				sed -i "s/'noname',0.012500,//g" $SCRIPTPATH/test.arff				
			fi
			rm $SCRIPTPATH/dsadas.arff
			sleep 0.6
			name="$result$DB_TEST_ID"
			java -classpath /usr/share/java/weka.jar weka.classifiers.trees.J48  -l $SCRIPTPATH/output.model -T $SCRIPTPATH/test.arff -p 0 >> $SCRIPTPATH/$name
			rm $SCRIPTPATH/test.arff

	
	done #test done - END MAKE TESTS


done # end loop which makes k-fold cross validation

#####################################################################################

# CONFUSION MATRIX - RECALL AND PRECISION
##after tests we need to perform data and create confusion  matrix

#
#
# example prediction output
#
# === Predictions on test data ===
#
# inst#     actual  predicted error prediction
#     1     4:fear    5:anger   +   1 
#
#
syntax='ls *wynik*'
cd $SCRIPTPATH

#confusion matrix

#create array for confusion matrix and fill first row and column with emotion names (row - real, columns - predicted), others are 0
declare -A matrix
matrix[0,0]="real\pred"
for ((i=1;i<=$emotions_number;i++)) do
    for ((j=1;j<=$emotions_number;j++)) do
        matrix[$i,$j]=0
    done
done
END=$emotions_number
for x in $( eval echo {1..$emotions_number} )
do
	matrix[$x,0]=${emotion[$x]}
	matrix[0,$x]=${emotion[$x]}
done

#go through all result files (with name "wynikx" where x is number of test)
for file in $syntax #for every ile with wav extension in directory $dir_number
do
	if [[ $file == "ls" ]]
		then
		continue
	fi

	while IFS= read -r line
	do
		if [[ $line == *"1"* ]] # get only lines with prediction results
		then
			#get numbers of real/predicted emotion
			number_actual=( $line ) 
			number_actual=${number_actual[1]}
			number_actual=${number_actual:0:1}
			number_predicted=( $line )
			number_predicted=${number_predicted[2]}
			number_predicted=${number_predicted:0:1}
			(( matrix[$number_actual,$number_predicted]++ )) #increment by 1
		fi 
	done < "$file"			
done

#sum of rows and columns
matrix[0,$(expr $emotions_number + 1)]="Sum"
matrix[$(expr $emotions_number + 1),0]="Sum"
##sum rows
for ((main=1;main<=$emotions_number;main++)) do
	sumCol=0
	sumRow=0
	for ((iter=1;iter<=$emotions_number;iter++)) do
		sumCol=$(expr $sumCol + ${matrix[$main,$iter]})
		sumRow=$(expr $sumRow + ${matrix[$iter,$main]})
	done
	matrix[$main,$(expr $emotions_number + 1)]=$sumCol
	matrix[$(expr $emotions_number + 1),$main]=$sumRow	
done


#print matrix
for ((row=0;row<=$(expr $emotions_number + 1);row++)) do
    for ((col=0;col<=$(expr $emotions_number + 1);col++)) do
	print_with_tab ${matrix[$row,$col]}
    done
echo
done



#print precision and recall for each emotion
echo
print_with_tab "emotion"
print_with_tab "recall"
print_with_tab "precision"
echo

sum_id=$(expr $emotions_number + 1)
for ((count=1;count<=$(expr $emotions_number);count++)) do
	print_with_tab ${matrix[$count,0]}	
	#recall
	x1=${matrix[$count,$count]}
	x2=${matrix[$count,$sum_id]}
	recall=$(awk "BEGIN {printf \"%.4f\",${x1}/${x2}}")
	print_with_tab $recall
	

	#precision
	x1=${matrix[$count,$count]}
	x2=${matrix[$sum_id,$count]}
	precision=$(awk "BEGIN {printf \"%.4f\",${x1}/${x2}}")
	print_with_tab $precision
	echo
done


#####################################################################################




