#!/bin/sh

# Wrapper script to run the OSG Probe report
# Example:  ./probereport_run.sh 

# This assumes you're running the reports from a virtualenv

TOPDIR=/home/sbhat/gracc-reporting
LOGFILE=/home/sbhat/gracc-reporting-IO/log/gracc-reporting/probereport_run.log     # Ideally should be in /var/log/gracc-reporting
CONFIGFILE=/home/sbhat/gracc-reporting-IO/config/osg.toml
VENVDIR=gracc_venv

function usage {
    echo "Usage:    ./probereport_run.sh"
    echo ""
    exit
}

# Initialize everything
# Check arguments
if [[ $# -ne 0 ]] || [[ $1 == "-h" ]] || [[ $1 == "--help" ]] ;
then
    usage
fi

# Activate the virtualenv
cd $TOPDIR
source $VENVDIR/bin/activate

# Run the Report
echo "START" `date` >> $LOGFILE

osgprobereport -c $CONFIGFILE 

# Error handling
if [ $? -ne 0 ]
then
	echo "Error sending report. Please investigate" >> $LOGFILE
else
	echo "Sent report" >> $LOGFILE
fi
 
echo "END" `date` >> $LOGFILE
