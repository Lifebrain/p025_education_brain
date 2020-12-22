#!/bin/bash
#------------------------------------------------------------------------------
# First check whether qdec.table.dat file exists in a current working directory
#------------------------------------------------------------------------------
qdec_dir="${QDEC_DATA_DIR}"

ln -s $qdec_dir/qdec.table.dat
if [[ ! -f qdec.table.dat ]]; then
    echo "ERROR: qdec.table.dat file does not exist."
    exit 1
fi

module load matlab/R2017a
#-------------------------------------------------
# Sort longitudinal Qdec table using matlab script
#-------------------------------------------------
echo -n "> Sorting longitudinal QDEC table... "
matlab -nodisplay -nojvm -nosplash -nodesktop -r "try, run('sort.m'), catch, exit(1), end, exit(0);" > /dev/null

if [[ $? != 0 ]]; then
    echo "ERROR: something went wrong in the sort.m script."
else
    mv sorted.qdec.table.dat $qdec_dir/.
    mv ni.mat $qdec_dir/.
    rm qdec.table.dat
    echo "DONE."
    echo "> sorted.qdec.table.dat and ni.mat files have been created"
fi
