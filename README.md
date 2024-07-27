# hoffman2-chem-notes

These are my notes for setting up and using Hoffman2 using Windows Subsystem for Linux (WSL). I have not included the steps for getting an account or getting access to G*ussian. If this is your first time using any form of Linux this should also be easy to follow along with!

## Table of Contents
- [SSH Customization](#ssh-customization)

G*uss\*an
- [G\*ussV*ew](#gaussview)
  * [Opening G\*ussVi*w](#opening-gaussview)
  * [Using G*ussView](#using-gaussview)
- [Running Your Job](#running-your-job)
  * [Making a Submission Script](#making-a-submission-script)
  * [Submitting Your Job](#submitting-your-job)
- [Getting the Output Files](#getting-the-output-files)

Q-Chem
- [Q-Chem](#Q-Chem)
  * [Getting and Using IQmol](#getting-and-using-iqmol)
  * [Making the Submission Script and Submitting Your Job](#making-the-submission-script-and-submitting-your-job)

## G*us\sian

### SSH Customization 

We are able to remotely connect to Hoffman2 using SSH. To make our experience easier moving forward, it's best to customize SSH. 

Find where your .ssh folder is, for me it was

```
\\wsl.localhost\Ubuntu\home\USERNAME\.ssh
```

To customize ssh, you want to create a config file if you haven't already. To do this, use the following command in your terminal. 

```
$ touch /home/USERNAME/.ssh/config 
```

Followed by this next command, which will make sure only the owner (you) will have full read and write access to the file.

```
$ chmod 600 /home/USERNAME/.ssh/config
```

You can now start customizing your ssh by editing this config file. I used nano to edit the file. If this is your first time using nano, Ctrl-O, or 'write-out', saves the file, and Ctrl-X is used to exit.

```
$ nano /home/USERNAME/.ssh/config
```

Copy and paste the following text into the file. These customizations  will make logging in easier, prevent connection dropping, and allow X11 forwarding (which allows you to use software like GaussView on the cluster).

```
Host hoffman2
  HostName hoffman2.idre.ucla.edu
  User PUT-YOUR-HOFFMAN2-ID-HERE
  ServerAliveInterval 30
  ServerAliveCountMax 5
  IPQoS throughput
  ForwardX11Trusted yes
  ForwardX11 yes
```

Now, if you want to connect to Hoffman2, you can just type the following command into your terminal and enter your password when prompted.

```
$ ssh hoffman2
```

### GaussView

I use GaussView to help me create input files for Gaussian and to visualize molecules. The following section will be about how to access it and use it on Hoffman2.

#### Opening GaussView

When you login to the cluster, you will be in a login node, and you don't want to open GaussView here. (You can verify you are in a login node because next to your username on your terminal, it will say @login1 or @login2 or @login3, and so on.) Instead you want to start an "interactive session". To do this, you want to use the following command 

```
$ qrsh
```

However, it's better to customize this command to suit your needs. I often use this next command, which requests 3 hours of runtime and 4 GB of memory.

```
$ qrsh -l h_rt=3:00:00,h_data=4G
```

After entering this command, wait a bit and you will be in the interactive session once you see something that resembles [username@n#### ~] in your terminal, where # represents numbers. 

At this point, you can now open GaussView using the following command

```
$ gaussview
```

#### Using Ga*ssView

You can now start creating molecules and setting up your molecules for the type of calculation you want to run. I won't be going over this because I don't know what calculation you want to run lol! There are a lot of youtube videos out there to help. I will instead skip to setting up your calculations with G*ussV\*ew.

Once you are done setting up everything for your molecule, you want to click the inquiry button, which looks like this: 

<img src="https://github.com/itmoth/hoffman2-chem-notes/blob/main/screenshots/inquirybutton.png" width="350">

Then, click Calculate on the top bar, and then Ga*ssian Calculation Setup. A new window will pop up. At this point you can select your job type. 

Here are some notes regarding the job types:
- If you want to run a transition state calculation, you will need to select Optimize, and then select whatever transition state calculation you want to run under the "Optimize To" option.
- If you want to run a scan, you will need to have specified which bonds/angles/dihedrals you want to scan in the redundant coordinate editor.

After, you should select your method. Note that all the available functionals are not in the drop down menu. If the functional you want to use is not in the menu, then you can just pick a random functional at this point and then change your input file later. 

Once you finish picking your method, move to "Link 0" to choose your memory and amount of processors. The values you want to set depend on the functional you choose. For something like B3LYP, 4 GB and 8 Processors should be just fine. For something like M06-2x, I typically do 12 processors and 8 GB. 

Once you are done, you can save your file by clicking edit. After doing so, your input file will show up in a new window. If the functional you wanted to use was not in the drop-down menu, you can now change it to your chosen one by replacing the functional you initally selected. Save the file again and you should be good! You can now exit GaussView. If it asks you if you want to submit your job, *say no*.

### Running Your Job

We want to be submitting our file as a batch job, which takes two steps: writing your submission script, and actually submitting the job.

#### Making a Submission Script

You will first need to use a text editor to make your submission script. I recommend a command-line-interface one so that you don't need to open another window! I personally recommend nano because it's probably already installed and it's easy to use. If it's your first time using nano, I will also be including how to use it as we move forward.

Open nano.

```
$ nano
```

Copy and paste the following code:

```
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
```

Save this file as 'gaussian_submit.sh' or a similar name.

If you saved the file to your local machine and not to your account on your cluster, you want to move it from your computer to the cluster. You can do this by using the following command:

```
$ scp gaussian_submit.sh HOFFMAN2-USERNAME@dtn.hoffman2.idre.ucla.edu:.
```

To check if the file is actually on your account, be logged into the cluster, and use the following command:

```
$ ls
```

This lists the files in the current directory you are in. gaussian_submit.sh should be listed. At this point, I recommend learning other commands that are used to navigate around the filesystem. This will make using Hoffman2 easier, and help you keep organized with your files. The first command I recommend using is mkdir, which makes a directory. Since your output will be in the same folder as your input files, I like to make a new folder for each job. We can start by making a folder. 

```
$ mkdir folder-name
```

Now, to move your g*ussian input file into the folder:

```
$ mv input-file-name.gjf folder-name
```

To copy your submission script into the folder,

```
$ cp gaussian_submit.sh folder-name
```

We now want to change our directory to the folder you just made. 

```
$ cd folder-name
```

#### Submitting Your Job

Before actually submitting the job, we want to make sure that gaussian_submit.sh is an executable script. This can be done with the following command

```
$ chmod u+x gaussian_submit.sh
```

We can now submit our job! To do this, we will be using the qsub command

```
$ qsub -N input-file-name -pe shared number-of-processors -l h_rt=24:00:00,h_data=number-of-gb gaussian_submit.sh
```

The number of processors you specify in the command should match what is in your input file. The number of gigabytes in your command should be a tiny bit higher than what's in your input file. (2 gigabytes more is fine)

You should see that your job has submitted! To get the status of your job, use the following command:

```
$ qstat -u HOFFMAN2-USERNAME
```

If your job is waiting to run, you should see 'qw'. If it is running, it should say 'r'. If your job is finished, nothing will show up. If you want to go back to your home directory, just type and enter cd into your terminal. 

If you'd like, you can open your joblog once your job is finished to make sure nothing went wrong, such as a segmentation violation. To do this, use the following command

```
$ cat input-file-name.joblog.joblog-number
```

### Getting the Output Files

There are a few ways to get the output files from the cluster to your computer. The Hoffman2 Documentation page has a lot of information about that. I tried setting up Google Drive to get my files but that didn't work for me. Box works for me though! The instructions are pretty complex so I will not be going over them.  



## Q-Chem 

I use IQmol to create my input files for Q-Chem, as it's made for that.

### Getting and Using IQmol

If you are using windows subsystem for linux, you can download the Windows version straight from their website. However, if you are using Linux, I recommend running IQmol with [Wine](https://www.winehq.org), which will allow you to run Windows applications on Linux. There are also official Linux versions of IQmol, but they are much older versions, and only for Ubuntu, Fedora, and CentOS.

I will not be going over the steps of using IQmol, but it's just like GaussView. Build your molecule, then hit Calculate and get your input file. Once you have the input file, you can then send it to your Hoffman2 account using the aforementioned command: 

```
$ scp FILE-NAME HOFFMAN2-USERNAME@dtn.hoffman2.idre.ucla.edu:.
```

### Making the Submission Script and Submitting Your Job

Make an .sh file and copy paste the following code:

```
### qchem_submit.sh START ###
#!/bin/bash
#$ -cwd
# error = Merged with joblog
#$ -o joblog.$JOB_ID
#$ -j y
# Edit the line below to request the appropriate runtime and memory
# (or to add any other resource) as needed:
#$ -l h_rt=24:00:00,h_data=8G
# Change the number of cores/nodes as needed:
#$ -pe dc* 12
# Email address to notify
#$ -M $USER@mail
# Notify when
#$ -m bea

# echo job info on joblog:
echo "Job $JOB_ID started on:   " `hostname -s`
echo "Job $JOB_ID started on:   " `date `
echo " "

# load the job environment:
. /u/local/Modules/default/init/modules.sh
module load qchem/current_mpi
module li
echo " "

# substitute the command to run the needed Q-Chem command below
# (in particular the name of the input and output files):
echo "/usr/bin/time -apv qchem -mpi -np $NSLOTS sample.inp sample.out_$JOB_ID"
/usr/bin/time -apv qchem -mpi -np $NSLOTS sample.inp sample.out_$JOB_ID

# echo job info on joblog:
echo " "
echo "Job $JOB_ID ended on:   " `hostname -s`
echo "Job $JOB_ID ended on:   " `date `
echo " "
### qchem_submit.sh STOP ###
```
Where it says $NSLOTS, specify the number of processors you want to use. Wherever it says sample, replace it with your input file name.

To submit your job, use the command:

```
qsub -pe dc* number-of-processors -l h_rt=24:00:00,h_data=number-of-gigs qchem_submit.sh
```

Note that for the processor number we did -pe dc* instad of -pe shared

Once your job is finished, I recommend using IQmol to look at the output!



