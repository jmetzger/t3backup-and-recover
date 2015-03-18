#!/bin/bash

if [ "$1" == "" ]
then
  echo "Sorry, no destdir. Giving up"
  exit 1
fi

DESTDIR=$1

if [ ! -d $DESTDIR ]
then
  echo "Destination ${DESTDIR} Directory does not exist"
  exit 1
fi

if [ -d $DESTDIR/typo3temp/Cache ]
then
   echo "Cache directory detected (typo3 6.x)"
   echo 'Deleting $DESTDIR/typo3temp/Cache/*'
   rm -fR $DESTDIR/typo3temp/Cache/*
fi
