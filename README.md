# MVS TK4- running in Docker container on AARCH64
This repository contains all required files to build and run a docker container running ***TK4-, Update 8*** 

## Components
Running TK4- Update 8 in a docker container requires serveral updates to the default configuration supplied as part of the default installation of TK4- as available on https://github.com/patrickraths/sdl-hercules-390-aarch64.git

Both components, ***SDL Hercules*** and ***TK4-*** will be installed into the following directories:
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

- Build the image using `docker build -t tk4:latest .` This creates a new image called ***TK4***
- Create a volume called tk4-dasd. This volume can be used to store persistent dasd files.
- Run the container using `docker run --name tk4 -it --mount src=tk4-dasd,target=/opt/tk4/dasd.usr -p 3270:3270 -p 8038:8038 tk4:latest` This creates a new container named ***tk4*** based on the previously created image, exposes ports 3270 and 8038 to the host and starts Hercules with MVS 3.8j

<img width="570" alt="TK4 Console" src="https://user-images.githubusercontent.com/43680256/227548975-a5a90c92-13dc-48e7-93d6-0ab0f453cb63.png">

## Starting the container and accessing the console
When starting the container MVS 3.8j is automatically started using the mvs startup script. However, the console is not normally shown and can only be accessed using the web interface using http://localhost:8038. To "export" the console start the container using 
```
docker start -i tk4
```


## Customizing TK4-

### Changing the Timezone
To change the timezone modify ***SYS1.PARMLIB(PARMTZ)
<img width="1120" alt="image" src="https://user-images.githubusercontent.com/43680256/228867399-c9d08e02-9851-4f09-939c-f7aff5a65d82.png">

### Enabling the CBT Catalogue

