#!/bin/bash

SCRIPTPATH=/home/darek/Desktop/skrypt

java -classpath /usr/share/java/weka.jar weka.classifiers.trees.J48  -t $SCRIPTPATH/output.arff -d $SCRIPTPATH/output.model -no-cv -i


