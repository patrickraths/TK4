#!/bin/sh
docker run --name tk4 -it --mount src=tk4-dasd,target=/opt/tk4/dasd.usr -p 3270:3270 -p 8038:8038 tk4:update8