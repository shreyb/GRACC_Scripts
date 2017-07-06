#!/bin/sh

# VARIABLES
SYMLINKNAME=${HOME}/gracc-reporting
GREPGRACCSTRING="^gracc-reporting-[0-9]\.[0-9]+(\.[0-9]+)?$"
ARCHIVEDIR=${HOME}/gracc-reporting-old
VENVNAME=gracc_venv

# Part 1:  Setup of dir structure
cd $HOME

# Remove old installation
if [[ -L $SYMLINKNAME ]];
then
	rm $SYMLINKNAME
fi

ORIGDIR=`ls | egrep -e ${GREPGRACCSTRING}` 
if [[ $? -eq 0 ]]; 
then
	mv $ORIGDIR ${ORIGDIR}-old

	if [[ -d ${ARCHIVEDIR}/${ORIGDIR}-old ]]; 
	then
		rm -Rf ${ARCHIVEDIR}/${ORIGDIR}-old
	fi

	mv ${ORIGDIR}-old ${ARCHIVEDIR}/${ORIGDIR}-old
	
	if [[ $? -ne 0 ]]; 
	then
		echo "Could not archive old installation.  Exiting."
		exit 1
	fi
fi
echo "Moved old installation to archive folder"


# Make sure we grab the latest tarball in case the old ones weren't deleted
AR=(`ls -t gracc-reporting*.tar.gz`)
TARBALLPATH=${HOME}/${AR[0]}
echo -e "\nUnpacking this tarball:"
ls -l $TARBALLPATH
sleep 1

# Unpack tarball, create symlink to it
tar -xzf $TARBALLPATH

if [[ $? -ne 0 ]];
then
	
	echo -e "\nError unpacking tar archive.  Exiting"
	exit 1
fi

INSTALLDIR=`ls | egrep -e ${GREPGRACCSTRING}` 
ln -s $INSTALLDIR $SYMLINKNAME
echo -e "\nDirectory created and linked"
sleep 1

# Part 2:  Create virtualenv and install package inside it
echo -e "\nInstalling gracc-reporting"
cd $SYMLINKNAME
virtualenv $VENVNAME
source ${VENVNAME}/bin/activate
pip install -U pip

if [[ -f "requirements.txt" ]]; 
then
	pip install -r requirements.txt
fi

python setup.py install

# Part 3:  Cleanup

cd $HOME
LASTINDEX=`expr ${#AR[@]} - 1`

for i in `seq 0 $LASTINDEX`; 
do 
	if [[ $i -ne 0 ]]; 
	then 
		RMFILE=${AR[$i]}
		rm $RMFILE
		echo "$RMFILE removed"
	fi
done

exit 0
