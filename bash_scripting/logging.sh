#!/bin/bash

STATUSFILE=x.out
LOGFILE=x.log

### All output to screen
### Do nothing, this is the default


### All Output to one file, nothing to the screen
#exec > ${LOGFILE} 2>&1


### All output to one file and all output to the screen
#exec > >(tee ${LOGFILE}) 2>&1


### All output to one file, STDOUT to the screen
#exec > >(tee -a ${LOGFILE}) 2> >(tee -a ${LOGFILE} >/dev/null)


### All output to one file, STDERR to the screen
### Note you need both of these lines for this to work
#exec 3>&1
#exec > >(tee -a ${LOGFILE} >/dev/null) 2> >(tee -a ${LOGFILE} >&3)


### STDOUT to STATUSFILE, stderr to LOGFILE, nothing to the screen
#exec > ${STATUSFILE} 2>${LOGFILE}


### STDOUT to STATUSFILE, stderr to LOGFILE and all output to the screen
#exec > >(tee ${STATUSFILE}) 2> >(tee ${LOGFILE} >&2)