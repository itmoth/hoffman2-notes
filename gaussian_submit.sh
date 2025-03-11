### submit_gaussian.sh START ###
###################################################################################################
# THIS SCRIPT ASSUMES THAT YOU WILL SUBMIT IT AS FOLLOWS:
# qsub -N YOUR_GAUSSIAN_INPUT_FILE_NAME submit_gaussian.sh
# YOU CAN MODIFY RESOURCES BELOW OR MODIFY THEM AT SUBMISSION, E.G.:
# qsub -N YOUR_GAUSSIAN_INPUT_FILE_NAME -l h_data=8G,h_rt=24:00:00 -pe shared 8 submit_gaussian.sh
# MAKE SURE THAT YOUR INPUT FILE PROLOG HAS A LINE:
# %nprocshared=8
# WITH THE SAME (OR LESS) NUMBER OF CORES REQUESTED (I.E.: -pe shared 8)
#!/bin/bash
#$ -cwd
#$ -o $JOB_NAME.joblog.$JOB_ID
#$ -j y
#$ -M $USER@mail
#$ -m bea
# CHANGE THE RESOURCES BELOW AS NEEDED:
#$ -l h_data=4G,h_rt=24:00:00
# CHANGE THE NUMBER OF CORES AS NEEDED:
#$ -pe shared 8
###################################################################################################

# YOU GENERALLY WILL NOT NEED TO MODIFY THE LINES BELOW:

# echo job info on joblog:
echo "Job $JOB_ID started on:   " `hostname -s`
echo "Job $JOB_ID started on:   " `date `
echo " "

# set job environment and GAUSS_SCRDIR variable
. /u/local/Modules/default/init/modules.sh
module load gaussian
export GAUSS_SCRDIR=$TMPDIR
# echo in joblog
module li
echo "GAUSS_SCRDIR=$GAUSS_SCRDIR"
echo " "

echo "/usr/bin/time -v $g16root/g16 < ${JOB_NAME%.*}.gjf > ${JOB_NAME%.*}.out"
/usr/bin/time -v $g16root/g16 < ${JOB_NAME%.*}.gjf > ${JOB_NAME%.*}.out

# echo job info on joblog:
echo "Job $JOB_ID ended on:   " `hostname -s`
echo "Job $JOB_ID ended on:   " `date `
echo " "
echo "Input file START:"
cat ${JOB_NAME%.*}.gjf
echo "END of input file"
echo " "
### submit_gaussian.sh STOP ###
