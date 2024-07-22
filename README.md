# hoffman2-chem-notes

These are my notes for setting up and using Hoffman2 using windows subsystem for linux (WSL). i have not included the steps for getting an account or getting access to Gaussian.

## ssh customization 

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
nano /home/USERNAME/.ssh/config
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

Now, if you want to connect to Hoffman2, you can just type the following command.

```
ssh hoffman2
```

## GaussView

I use GaussView to help me create input files for Gaussian and to visualize molecules. The following section will be about how to access it on Hoffman2.



