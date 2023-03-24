#**********************************************************************
#***                                                                ***
#*** Dockerfile:    TK4-, Update 8 running on Hercules 4.5          ***
#***                                                                ***
#*** Updated:       24 March 2023                                   ***
#***                                                                ***
#**********************************************************************
#
# Use Ubuntu container as foundation
#
FROM ubuntu:lunar
#
# Install required packages
#
RUN apt-get -y update
RUN apt-get -y install apt-utils wget time htop
RUN apt-get -y install libcap2-bin
#
# Copy TK4- and Hercules 
#
COPY ./tk4      /opt/tk4
COPY ./hercules /opt/hercules
#
# Make Hercules web Interface available inside TK4- as reference by
# the default configuration scripts
#
RUN ln -s /opt/hercules/share/hercules /opt/tk4/hercules/httproot
#
# Make required Ports available
#
EXPOSE 3270/tcp
EXPOSE 8038/tcp
#
# Set working directory and define the default entrypoint into the
# container to luanch TK4- when starting the container
WORKDIR /opt/tk4
ENTRYPOINT [ "./mvs" ]