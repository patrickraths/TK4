# MVS TK4- running in Docker container on AARCH64
This repository contains all required files to build and run a docker container running **TK4-, Update 8** 

## Components
Running TK4- Update 8 in a docker container requires serveral updates to the default configuration supplied as part of the default installation of TK4- as available on https://github.com/patrickraths/sdl-hercules-390-aarch64.git

Both components, **SDL Hercules** and **TK4-** will be installed into the following directories:
- /opt/hercules
- /opt/tk4-

### SDL-Hercules 4.5
The Hercules version embedded as part of TK4- does not current support AARCH64 architecture. To support this architecture Hercules has to be compiled from source. Compilinng and building the binaries and libraries for Hecules 4.5 is achieved using a different Docker container. For details refers to https://github.com/patrickraths/sdl-hercules-390-aarch64.git

### TK4-
The following changes are requied to run TK4- with SDL Hercules 4.5

- Remove embedded Hercules (multiple platform support)
- Install SDL Hercules 4.5 for AARCH64
- Remove all Windows related startup files
- Remove Readme and Documentation files
- Remove support to run Hercules in unattended (daemon) mode
- Modifed startup files

#### Change log of modification to TK4-
| File/Directory | Changes |
| :--- | :--- |
| [conf] | Modifed tk4-.cnf to add support for user added DASD stored in Docker Volume and mounted as ./dasd.usr |
| [ctca_demon] | no changes |
| [dasd] | Added TK4- CBT DASD |
| [doc] | Directory removed |
| [hercules] | All files removed, but directory retained as it is reference in the configuration files for the hercules monitoring web interface. Sumbolic link for httproot subdirectory inside this directory will be created to access SDL Hercules 4.5 monitoring web interface. |
| [jcl] | no changes |
| [local_conf] | no changes |
| [local_scripts] | no changes |
| [log] | no changes |
| [pch] | no changes |
| [rdr] | no changes |
| [scripts] | no changes |
| [tapes] | no changes |
| [unattended] | removed |
| README_MVS*.txt | removed |
| mvs.bat | removed |
| start_herc.bat | removed |
| mvs | modified |
| startup_herc | modified |

## Building the Docker image and running it as container
Building the container is controlled through the Dockerfile found in the root directory of this repository. To access the system using a 3270 Terminal Emulator as well as the SDL Hercules Web-Interface ports 3270 and 8038 must be made available on the host.

- Build the image using `docker build -t tk4:latest .` This creates a new image called **TK4**
- Create a volume called tk4-dasd. This volume can be used to store persistent dasd files.
- Run the container using `docker run --name tk4 -it --mount src=tk4-dasd,target=/opt/tk4/dasd.usr -p 3270:3270 -p 8038:8038 tk4:latest` This creates a new container named **tk4** based on the previously created image, exposes ports 3270 and 8038 to the host and starts Hercules with MVS 3.8j

<img width="570" alt="TK4 Console" src="https://user-images.githubusercontent.com/43680256/227548975-a5a90c92-13dc-48e7-93d6-0ab0f453cb63.png">

## Starting the container and accessing the console
When starting the container MVS 3.8j is automatically started using the mvs startup script. However, the console is not normally shown and can only be accessed using the web interface using http://localhost:8038. To "export" the console start the container using 
```
docker start -i tk4
```


## Customizing TK4-

### Changing the Timezone
To change the timezone modify **SYS1.PARMLIB(PARMTZ)**

*†Syntax*<br>
The member consists of one record
The member uses the syntax  D,HH[.MM[.SS]]

*Parameters*<br>
D is either "E" or "W" to specify a time zone east or west or Greenwich Mean Time (GMT)
HH specifies the number of hours deviation from GMT (00-12)
MM specifies the number of minutes. Optional parameter. (00-59)
SS specifies the number of seconds. Optional parameter (00-59)

<img width="1120" alt="image" src="https://user-images.githubusercontent.com/43680256/228867399-c9d08e02-9851-4f09-939c-f7aff5a65d82.png">

### Enabling the CBT Catalogue
To make the CBT Volumes **CBTCAT**, **CBT000**, **CBT001**, **CBT002** accessible through catalog search the respective user catalogs need to be connected and the high level qualifer aliases pointing to them need to be defined. 

To make the CBT Volumes accessibles submit job **SYS1.SETUP.CNTL(MVS0170) [issue **sub** on the Command line when viewing/editing the dataset]. This connects the SYS1.UCAT.CBT user catalog and defines the CBT, CBTCOV, CBT072, CBT129, CBT249, CBT429 HLQ aliases.

Recommendation:<br>
Change MSGCLASS from 'A' to 'H' so that the result of the job can be viewed

<img width="585" alt="image" src="https://user-images.githubusercontent.com/43680256/229275001-82b5c4a7-8b9e-4284-83f3-9deddf85ce1c.png">

### Creating, cataloging, and using user DASD
It is recommended to create a separate DASD (Direct Access Storage Device) to store data on MVS that is not part of the TK4- standard configuration. By default all DASD are stored in [dasd] directory inside the TK4 folder structure. However, since the storage inside a docker container is not persistent, user DASD should be placed into the folder [dasd.usr] that is mounted as docker volume. 

#### Creating and catagoling a new DASD
There are different DASD types that vary in capacity; typical models as 3330, 3340, 3350, 3380, 3390, etc. However, TK4- odes not support DASD models after 3350, thus we will be using the model 3350 which provides a capacity of approximately 300MB.

MVS communicates to DASD devices through addresses. TK4- has assigned the following address ranges for DASD devices:
<img width="640" alt="image" src="https://user-images.githubusercontent.com/43680256/229289077-eb87138d-e61f-4190-968b-8ba2e0680f48.png">

In TK4- the following addresses for DASD Model 3350 are in use:
| Address | Volume |
| :------ | :----- |
| 0140 | WORK00 |
| 0148 | MVSRES |
| 0149-014A | SMP001, SMP002 |
| 014B-014C | SMP003, SMP004 |
| 0240-0241 | PUB000, PUB010 |
| 0248 | MVSDLB |
| 0340-0342 | CBT000, CBT001, CBT002 |
| 0343 | CBTCAT |

For the actual use of addresses refer to the **conf/tk4-.cnf** file

1. Create DASD Image<br>
   For our purpose we want to create the following volume to store user data:
   | Address | Model | Volume |
   | :------ | :---- | :----- |
   | 034A | 3350 | USR000 |
   
   To create the DASD image, you will need to execute the dasdinit program in the terminal window. 
   
   ```
   /opt/hercules/bin/dasdinit -z -a /opt/tk4/dasd.usr/usr000.34a 3350 USR000
   ````
   >HHC02499I Hercules utility dasdinit - DASD image file creation program - version 4.5.0.10830-SDL-g58578601-modified<br>
   >HHC01414I (C) Copyright 1999-2022 by Roger Bowler, Jan Jaeger, and others<br>
   >HHC01417I ** The SoftDevLabs version of Hercules **<br>
   >HHC01415I Build date: Mar 28 2023 at 10:51:26<br>
   >HHC00462I 0:0000 CKD file /opt/tk4/dasd.usr/usr000.34a: creating 3350 volume USR000: 560 cyls, 30 trks/cyl, 19456 bytes/track<br>
   >HHC00460I 0:0000 CKD file /opt/tk4/dasd.usr/usr000.34a: 560 cylinders successfully written<br>
   >HHC02423I DASD operation completed<br>

2. Attach the newly creased DASD<br>
   In order to attach an emulated device to Hercules while it is running, you will need to be in the text console display because there is no equivalent command in the graphical display.  The command syntax is:

   `attach <address> <devtype> <filename> [cu=3880]`

   To attach the previously created dasd use the following command in the MVS console:
   ```
   attach 034a 3350 dasd.usr/usr000.34a
   ```
   <img width="569" alt="image" src="https://user-images.githubusercontent.com/43680256/229291338-b4438109-14fa-4a1e-a3f8-041459a4ef02.png">
   
3. Initalize the DASD Image for use by MVS
   Although the dasdinit program creates the raw DASD image, MVS requires additional information that is not written by dasdinit. The following JCL initalizes newly created DASD as Volume **USR000** using address **34A**, and assigns 1 Cylinder (30 Tracks) for the VTOC.
   
   ```
   //ICKDSF  JOB (1),ICKDSF,CLASS=A,MSGCLASS=H
   //ICKDSF EXEC PGM=ICKDSF,REGION=4096K
   //SYSPRINT DD  SYSOUT=*
   //SYSIN    DD  *
   INIT UNITADDRESS(34A) NOVERIFY VOLID(USR000) OWNER(HERCULES) -
                VTOC(0,1,30)
   /*
   //
   ```
   
   You will be asked to confirm that you actually want to initialize the volume at the address specified:
   >*00 ICK003D REPLY U TO ALTER VOLUME 34A CONTENTS, ELSE T

   The reply of U allows the initialization to proceed.  There will be a number of informational messages printed in the SYSPRINT output during the executing of ICKDSF.  The most important thing to verify is that the return code for the job is 0000.
   
   <img width="564" alt="image" src="https://user-images.githubusercontent.com/43680256/229292813-f8b2b471-e8b8-4bad-ae3c-8aabebefaf3b.png">

4. Set the volume online and mount it with the appropriate storage use class<br>
   After the volume is initialized, it must be placed online before MVS will be able to allocate the volume to allow jobs to create datasets on it.  On the MVS console issue the command `v <address>,online`
   
   <img width="566" alt="image" src="https://user-images.githubusercontent.com/43680256/229293847-bbf79122-eec8-4ea6-b7eb-0a6f9cd8faa3.png">

   After the volume is set online it must be mounted.
   ```
   /m 34a,vol=(sl,usr000),use=private
   ```
   <img width="563" alt="image" src="https://user-images.githubusercontent.com/43680256/229294052-0bf92643-5ae9-4a40-b6b0-e710d8375f1d.png">
   
   By using use=private new datasets will be created on this volume only if the user (via JCL or the TSO ALLOCATE command) specifies the volume serial of this disk volume.
   
5. Add the new volume to the MVS & Hercules configuration so it will be mounted automatically
   - Edit MVS Configuration<br>
     By modifying **SYS1.PARMLIB(VATLST00)** MVS will be instructed to automatically mount the volume, if accessible, and assign storage class 2 (Private)
     ```
     USR000,0,2,3350    ,N                  User Volume 1 
     ```
     <img width="636" alt="image" src="https://user-images.githubusercontent.com/43680256/229294781-e78fd5d8-e0f8-4d2e-8155-c4d65568ddcf.png">

   - Edit Hercules Configuration<br>
     Modify the file /opt/tk4/dasd.usr/usr_dasd.cnf to automatically attach the newly created dasd at address 34a. This file is referenced as include in the TK4- base configuration file (/opt/tk4/conf/tk4-.cnf)
     ```
     #
     # User Added DASD
     #
     034a 3350 dasd.usr/usr000.34a
     ```

