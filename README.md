# hoffman2-chem-notes

These are my notes for setting up and using Hoffman2 using Windows Subsystem for Linux (WSL). I have not included the steps for getting an account or getting access to Gaussian.

## SSH Customization 

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

You can now start customizing your ssh by editing this config file. I used nano to edit the file.

```
$ nano /home/USERNAME/.ssh/config
```

Copy and paste the following text into the file. These customizations  will make logging in easier, prevent connection dropping, and allow X11 forwarding, which allows you to use software like GaussView.

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

Now, if you want to connect to Hoffman2, you can just type the following command into your terminal.

```
$ ssh hoffman2
```

## GaussView

I use GaussView to help me create input files for Gaussian and to visualize molecules. The following section will be about how to access it and use it on Hoffman2.

### Opening GaussView

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

### Using GaussView

You can now start creating molecules and setting up your molecules for the type of calculation you want to run. I won't be going over this because I don't know what calculation you want to run lol! There are a lot of youtube videos out there to help. I will instead skip to setting up your calculations with GaussView.

Once you are done setting up everything for your molecule, you want to click the inquiry button, which looks like this: 

<img src="https://github.com/itmoth/hoffman2-chem-notes/blob/main/screenshots/inquirybutton.png" width="350">

Then, click Calculate on the top bar, and then Gaussian Calculation Setup. A new window will pop up. At this point you can select your job type. 

Here are some notes regarding the job types:
- If you want to run a transition state calculation, you will need to select Optimize, and then select whatever transition state calculation you want to run under the "Optimize To" option.
- If you want to run a scan, you will need to have specified which bonds/angles/dihedrals you want to scan in the redundant coordinate editor.

After, you should select your method. Note that all the available functionals are not in the drop down menu. If the functional you want to use is not in the menu, then you can just pick a random functional at this point and then change your input file later. 

Once you finish picking your method, move to "Link 0" to choose your memory and amount of processors. The values you want to set depend on the functional you choose. For something like B3LYP, 4 GB and 8 Processors should be just fine. For something like M06-2x, I typically do 12 processors and 8 GB. 

Once you are done, you can save your file by clicking edit. After doing so, your input file will show up in a new window. If the functional you wanted to use was not in the drop-down menu, you can now change it to your chosen one by replacing the functional you initally selected. Save the file again and you should be good! You can now exit GaussView. If it asks you if you want to submit your job, *say no*.








