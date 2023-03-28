### SDL-Hercules 4.5
The Hercules version embedded as part of TK4- does not current support AARCH64 architecture. To support this architecture Hercules has to be compiled from source. Compilinng and building the binaries and libraries for Hecules 4.5 is achieved using a different Docker container. For details refers to https://github.com/patrickraths/sdl-hercules-390-aarch64.git

### TK4-
The [hercules] directory inside TK4- must be retained as it is reference by the 
configuration files for the hercules monitoring web interface. Sumbolic link for httproot subdirectory inside this directory will be created to access SDL Hercules 4.5 monitoring web interface.