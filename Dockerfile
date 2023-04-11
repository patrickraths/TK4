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
FROM praths/sdl-hercules-390:latest
#
# Set environment
#
ENV TK4 /opt/tk4
#
# Copy TK4- and Hercules 
#
COPY ./tk4      $TK4
RUN mkdir -p $TK4/log $TK4/pch $TK4/prt $TK4/rdr $TK4/tapes $TK4/hercules
#
# Make Hercules web Interface available inside TK4- as reference by
# the default configuration scripts
#
RUN ln -s $HERCULES/share/hercules $TK4/hercules/httproot
#
# Make required Ports available
#
EXPOSE 3270/tcp
EXPOSE 8038/tcp
#
# Set working directory and define the default entrypoint into the
# container to luanch TK4- when starting the container
VOLUME /opt/tk4/dasd.usr
WORKDIR $TK4
ENTRYPOINT [ "./mvs" ]