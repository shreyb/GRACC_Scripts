#!/bin/sh

# Wrapper script to run the OSG Project report (OSGReporter)
# Example:  ./project_run.sh weekly
# This assumes you're running the reports from a virtualenv

TOPDIR=/home/sbhat/gracc-reporting
LOGFILE=/home/sbhat/gracc-reporting-IO/log/gracc-reporting/project_run.log  # Ideally should be in /var/log/gracc-reporting
CONFIGFILE=/home/sbhat/gracc-reporting-IO/config/osg.toml
TEMPLATEFILE=/home/sbhat/gracc-reporting-IO/html_templates/template_project.html
VENVDIR=gracc_venv


function usage {
    echo "Usage:    ./project_run.sh <time period>"
    echo ""
    echo "Time periods are: daily, weekly, bimonthly, monthly, yearly"
    exit
}

function set_dates {
        case $1 in
                "daily") starttime=`date --date='1 day ago' +"%F %T"`;;
                "weekly") starttime=`date --date='1 week ago' +"%F %T"`;;
                "bimonthly") starttime=`date --date='2 month ago' +"%F %T"`;;
                "monthly") starttime=`date --date='1 month ago' +"%F %T"`;;
                "yearly") starttime=`date --date='1 year ago' +"%F %T"`;;
                *) echo "Error: unknown period $1. Use weekly, monthly or yearly"
                         exit 1;;
        esac
        echo $starttime
}

# Initialize everything
# Check arguments
if [[ $# -ne 1 ]] || [[ $1 == "-h" ]] || [[ $1 == "--help" ]] ;
then
    usage
fi

set_dates $1
endtime=`date +"%F %T"`
REPORT_TYPES="XD OSG OSG-Connect"

# Activate the virtualenv
cd $TOPDIR
source $VENVDIR/bin/activate

# Run the report
echo "START" `date` >> $LOGFILE

for TYPE in ${REPORT_TYPES}
do
    echo $TYPE
    osgreport -s "$starttime" -e "$endtime" -r $TYPE -c $CONFIGFILE -T $TEMPLATEFILE

    # Error handling
    if [ $? -ne 0 ]
    then
        echo "Error sending $TYPE report. Please investigate" >> $LOGFILE
    else
        echo "Sent $TYPE report" >> $LOGFILE
    fi
done

 
echo "END" `date` >> $LOGFILE

