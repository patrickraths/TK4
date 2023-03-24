FROM ubuntu:lunar

ARG email="patrick@raths.net"
LABEL "maintainer"=$email

RUN apt-get -y update
RUN apt-get -y install apt-utils wget time htop
RUN apt-get -y install libcap2-bin

COPY ./tk4      /opt/tk4
COPY ./hercules /opt/hercules
RUN ln -s /opt/hercules/share/hercules /opt/tk4/hercules/httproot

EXPOSE 3270/tcp
EXPOSE 8038/tcp
WORKDIR /opt/tk4
ENTRYPOINT [ "./mvs" ]