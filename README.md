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

Please note that for the model 3350 the following Addresses are already in use:
| Address | Volume |
| :------ | :----- |
| 0140 | WORK00 |
| 0148 | MVSRES |
| 0149 | SMP001 |
| 014A | SMP002 |
| 014B | SMP003 |
| 014C | SMP004 |
| 0240 | PUB000 |
| 0241 | PUB010 |
| 0248 | MVSDLB |
| 0340 | CBT000 |
| 0341 | CBT001 |
| 0342 | CBT002 |
| 0343 | CBTCAT |






1. Create DASD Image<br>
   To create the DASD image, you will need to execute the dasdinit program in the terminal window. The dasdinit executable is included in the Hercules distribution package
   ```
   /opt/hercules/bin/dasdinit -z -a /opt/tk4/dasd.usr/usr000.242 3350 USR000
   ````
   >HHC02499I Hercules utility dasdinit - DASD image file creation program - version 4.5.0.10830-SDL-g58578601-modified<br>
   >HHC01414I (C) Copyright 1999-2022 by Roger Bowler, Jan Jaeger, and others<br>
   >HHC01417I ** The SoftDevLabs version of Hercules **<br>
   >HHC01415I Build date: Mar 28 2023 at 10:51:26<br
   >HHC00462I 0:0000 CKD file /opt/tk4/dasd.usr/usr000.242: creating 3350 volume USR000: 560 cyls, 30 trks/cyl, 19456 bytes/track
   >HHC00460I 0:0000 CKD file /opt/tk4/dasd.usr/usr000.242: 560 cylinders successfully written<br>
   >HHC02423I DASD operation completed<br>
