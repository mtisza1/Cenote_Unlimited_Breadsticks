#!/bin/bash

echo "Cenote_Unlimited_Breadsticks installing now"
MDYT=$( date +"%m-%d-%y---%T" )
echo "time update, cloning git repo: " $MDYT

if [ -s Cenote_Unlimited_Breadsticks/unlimited_breadsticks.py ] ; then
	cd Cenote_Unlimited_Breadsticks
	git pull
else
	git clone https://github.com/mtisza1/Cenote_Unlimited_Breadsticks.git

	cd Cenote_Unlimited_Breadsticks
fi

MDYT=$( date +"%m-%d-%y---%T" )
echo "time update, downloading LAST: " $MDYT
if [ -s last-1047/README.txt ] ; then
	echo "last already present"
else
	wget http://last.cbrc.jp/last-1047.zip
	unzip last-1047.zip
	cd last-1047/
	make
	cd ..
	rm last-1047.zip
fi

MDYT=$( date +"%m-%d-%y---%T" )
echo "time update, creating conda environment: " $MDYT
eval "$(conda shell.bash hook)"
conda info --envs | if grep -q "unlimited_breadsticks_env" ; then
	conda env remove --name unlimited_breadsticks_env
fi
conda env create --file unlimited_breadsticks_env.yml
conda activate unlimited_breadsticks_env

conda info --envs | sed 's/ \+/ /g' | if grep -q "unlimited_breadsticks_env \*" ; then 
	echo "unlimited_breadsticks_env loaded" ; 
else 
	echo "unlimited_breadsticks_env not loaded correctly" ;
	exit 
fi


CT2_DIR=$PWD
MDYT=$( date +"%m-%d-%y---%T" )
echo "time update, downloading and formatting HMM database: " $MDYT
#wget hmmer DBs
if [ -s hmmscan_DBs/useful_hmms_baits_and_not2a.h3p ] ; then
	echo "HMM databases appear to be already present"
else
	wget https://zenodo.org/record/3759823/files/hmmscan_DBs.tgz
	tar -xvf hmmscan_DBs.tgz
	rm hmmscan_DBs.tgz
fi

MDYT=$( date +"%m-%d-%y---%T" )
echo "time update, downloading and formatting CDD RPSBLAST database: " $MDYT
#wget cdd rpsblast db
if [ -s cdd_rps_db/Cdd.rps ] ; then
	echo "RPSBLAST CDD databases appear to be already present"
else
	mkdir cdd_rps_db && cd cdd_rps_db
	wget ftp://ftp.ncbi.nih.gov/pub/mmdb/cdd/little_endian/Cdd_LE.tar.gz
	tar -xvf Cdd_LE.tar.gz
	rm Cdd_LE.tar.gz
	cd ..
fi

echo "unlimited_breadsticks should now run. Use: python /path/to/Cenote_Unlimited_Breadsticks/unlimited_breadsticks_env.py"
MDYT=$( date +"%m-%d-%y---%T" )
echo "time update, FINISHED: " $MDYT
