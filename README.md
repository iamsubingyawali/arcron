# arcron
Shell script to atuomate backups in Linux. 

<img src="https://user-images.githubusercontent.com/45819206/121506169-36522d80-ca03-11eb-8af0-3ecae868ff39.png" width=500>

## What does this script do?

In the Archive management section you can set up archives and automate backups of your files and folders using cron jobs. You need to have basic knowledge of setting up cron jobs to use this program.

<img src="https://user-images.githubusercontent.com/45819206/121506232-42d68600-ca03-11eb-8570-439b8f79b2e8.png" width=500>

A detailed user guide is available within the script file at the beginning of the script. Go through it if something seems confusing.

## Dependencies

The script depends on some linux packages which you need to install before you run the script. Use your system package manager to install the following packages:

1. zenity
2. libnotify-bin

For Debian based distros with apt, use the following command:

```
sudo apt-get install zenity libnotify-bin
```

## Run

After all dependencies are installed, to run the script simply clone this repo using the commend below in your Linux terminal.

```
https://github.com/iamsubingyawali/arcron.git
```

Navigate to the script directory and run the file using commands below. You may need to change the permissions for the file to run, use **chmod** accordingly.

```
cd arcron
./run.sh
```

_Note: I am not responsible for any damange caused to your system with incorrect use of this script. Do not proceed with any options in the script unless you know what you are doing. Distributing your own copy of this script is not allowed. Read the license file carefully before proceeding._

_Bugs are expected. Open issues or pull requests if you found some._
