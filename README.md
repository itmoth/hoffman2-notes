# hoffman2-notes

These are my notes for setting up and using Hoffman2

Documentation website for Hoffman2 ([https://www.hoffman2.idre.ucla.edu/](https://www.hoffman2.idre.ucla.edu/)) because this might have out of date information

Also these notes are lowkey a mess because I switched from Windows to Linux soon after writing part of this lol

## Table of Contents
- [SSH Customization](#ssh-customization)

Gaussian
- [GaussView](#gaussview)
  * [Opening GaussView](#opening-gaussview)
  * [Using GaussView](#using-gaussview)
- [Running Your Job](#running-your-job)
  * [Making a Submission Script](#making-a-submission-script)
  * [Submitting Your Job](#submitting-your-job)
- [Getting the Output Files](#getting-the-output-files)

- [Running Jupyter](#jupyter)

## Gaussian

### SSH Customization 

*I am assuming that if you are on Linux or MacOS you are just connecting/logging onto Hoffman2 using a terminal emulator of your choice, and if you are on Windows, you are using something like WSL*

We are able to remotely connect to Hoffman2 using SSH. To make our experience easier moving forward, it's best to customize SSH first. 

Find where your .ssh folder is, for me it was

```
\\wsl.localhost\Ubuntu\home\USERNAME\.ssh
```

On Linux and MacOS it should just be at 

```~/.ssh```

To customize ssh, you want to create a config file if you haven't already. To do this, use the following command in your terminal. 

```
$ touch ~/.ssh/config 
```

Followed by this next command, which will make sure only the owner (you) will have full read and write access to the file.

```
$ chmod 600 ~/.ssh/config
```

You can now start customizing your ssh by editing this config file. I used nano to edit the file. If this is your first time using nano, Ctrl-O, or 'write-out', saves the file, and Ctrl-X is used to exit.

```
$ nano /home/USERNAME/.ssh/config
```

Copy and paste the following text into the file. These customizations  will make logging in easier, prevent connection dropping, and allow X11 forwarding (which allows you to use software like GaussView).

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

GaussView is extremely helpful for building molecules and especially helpful for creating Gaussian input files. The following section will be about how to access and use it on Hoffman2.

#### Opening GaussView

When you login to the cluster, you will be in a login node. You **do not** want to open GaussView here. (You can verify you are in a login node because next to your username on your terminal, it will say @login1 or @login2, and so on.) Instead you want to start an "interactive session". To do this, you want to use the following command 

```
$ qrsh
```

However, it's better to customize this command to suit your needs. For example, you can use this command, which requests 3 hours of runtime and 4 GB of memory.

```
$ qrsh -l h_rt=3:00:00,h_data=4G
```

After entering this command, wait a bit and you will be in the interactive session once you see something that resembles [username@n#### ~] in your terminal, where # represents numbers. You are now at a compute node! 

At this point, you can now open GaussView using the following command

```
$ gaussview
```

#### Using GaussView

You can now start creating molecules and setting up your molecules for the type of calculation you want to run. I won't be going over this because I don't know what calculation you want to run lol! There are a lot of guides out there to help. I will instead skip to setting up your calculations with GaussView.

Once you are done setting up everything for your molecule, you want to click the inquiry button, which looks like this: 

<img src="https://github.com/itmoth/hoffman2-chem-notes/blob/main/screenshots/inquirybutton.png" width="350">

Then, click Calculate on the top bar, and then Gaussian Calculation Setup. A new window will pop up. At this point you can select your job type. 

After, you should select your method. Note that all the available methods, functionals, or basis sets are not in the drop-down menu. If the functional you want to use is not in the menu, then you can just pick a random functional at this point and then edit your input file later. To find the full list of functionals and methods, you can go to Gaussian's website.

Once you finish picking your method, move to "Link 0" to choose your memory and amount of processors. The values you want to set depend on the functional you choose. For something like B3LYP, 4 GB and 8 Processors should be just fine. For something like M06-2x, I typically do 12 processors and 8 GB.

Once you are done, you can save your file by clicking edit. After doing so, your input file will show up in a new window. If the functional you wanted to use was not in the drop-down menu, you can now change it to your chosen one by replacing the functional you initally selected. Save the file again and you should be good! You can now exit GaussView. If it asks you if you want to submit your job, *say no*, as we need to submit through the command line.

### Running Your Job

We need to send our job to the job scheduler! We first need to make a submission script, and then actually submit the job.

#### Making a Submission Script

You will first need to use a text editor to make your submission script. I recommend a command-line-interface (CLI) one so that you don't need to open another window lol. I personally recommend Vim!

Open vim with:

```
$ vim YOURFILENAME.sh
```

You want to first enter insert mode. This is done by pressing the i key. After doing so, it should say "-- INSERT --" at the bottom of your window. Now, paste the following code with ctrl+shift+v:

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

We now want to save the file. To do so, we want to first exit insert mode by pressing the esc key. Now, press the colon key and type wq, then enter. To make sure you actually did this step right, you can use the following command

```
$ cat YOURFILENAME.sh
```

The output of this command should be what you pasted.

If you saved the file to your local machine and not to your account on the cluster, you want to move it from your computer to the cluster. You can do this by using the following command:

```
$ scp gaussian_submit.sh HOFFMAN2-USERNAME@dtn.hoffman2.idre.ucla.edu:.
```
P.S. you could've just cloned this repo and taken the submission script because I have it uploaded

To check if the file is actually on your account, be logged into the cluster, and use the following command:

```
$ ls
```

This lists the files in the current directory you are in. gaussian_submit.sh should be listed. At this point, I recommend learning other commands that are used to navigate around the filesystem. This will make using Hoffman2 easier, and help you keep organized with your files. One extremely important command is mkdir, which makes a directory (also known as a folder). Since your output will be in the same directory as your input files, I like to make a new directory for each job. We can start by making a directory. 

```
$ mkdir directory-name
```

Now, to move your Gaussian input file into the directory:

```
$ mv input-file-name.gjf directory-name
```

To copy your submission script into the directory,

```
$ cp gaussian_submit.sh directory-name
```

We now want to change our directory to the directory you just made. 

```
$ cd folder-name
```

To check what directory you are currently in, you can use the ```pwd``` command (aka print working directory). So far we've already used the ```cat```, ```ls```, ```mkdir```, ```mv```, ```cp```, ```cd```, and ```touch``` commands! Some other important and basic commands that you must learn are ```rm```, ```head```, ```tail```. I also highly recommend learning [wildcards](https://tldp.org/LDP/GNU-Linux-Tools-Summary/html/x11655.htm). These will be extremely helpful!

#### Submitting Your Job

Before actually submitting the job, we want to make sure that gaussian_submit.sh is an executable script. This can be done with the following command

```
$ chmod u+x gaussian_submit.sh
```

We can now submit our job! To do this, we will be using the qsub command

```
$ qsub -N input-file-name -pe shared number-of-processors -l h_rt=24:00:00,h_data=number-of-gigabytesG gaussian_submit.sh
```

The number of processors you specify in the command should match what is in your input file. The number of gigabytes in your command should be a tiny bit higher than what's in your input file. (2 gigabytes more is fine)

As an example, we have:

```
$ qsub -N water -pe shared 12 -l h_rt=24:00:00,h_data=16G gaussian_submit.sh
```

We should first have a file named water.gjf in the working directory. This command requests 12 cores, 24 hours of runtime (our maximum runtime), and 16 gigabytes of memory. 

You should see that your job has submitted! To get the status of your job, use the following command:

```
$ qstat -u HOFFMAN2-USERNAME
```

If your job is waiting to run, you should see 'qw'. If it is running, it should say 'r'. If all your jobs are finished, nothing will show up. If you want to go back to your home directory, just type and enter cd into your terminal. 

If you'd like, you can open your joblog once your job is finished to make sure nothing went wrong, such as a segmentation violation. To do this, use the following command

```
$ cat input-file-name.joblog.joblog-number
```

### Getting the Output Files

I will not be going over this lol! 

## Jupyter

If you want to run Jupyter, you want to first get this script made by the folks who manage Hoffman2. Make sure you put this command onto your local machine, not while you're connected to Hoffman2.

```
$ wget https://raw.githubusercontent.com/rdauria/jupyter-notebook/main/h2jupynb
```

The name of the script is h2jupynb. To make it executable ```chmod u+x``` it.

Now, to start a session, run: (replace USERNAME with your Hoffman2 username)

```
$ ./h2jupynb -u USERNAME
```

You'll then need to type your password, and you'll need to type it again a few moments after you type it the first time. Check your browser and you should find an open Jupyter Notebook. If you want to switch to Jupyter Lab, just go to the URL, and change the 'tree' in the URL to 'lab'.
