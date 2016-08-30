This is the Dockerfile for the sample application described in the
OpenIG Gateway guide
 https://forgerock.org/openig/doc/bootstrap/gateway-guide/index.html#chap-quickstart
 
 
Example of how to build this:
 

docker build -t forgerock/openig-sample:latest .

Example of how to run it - mapping local port 18081 to the image internal 8081

docker run -p 18081:8081 -it  forgerock/openig-sample-server
 
 

This image is currently hosted on the docker hub:

https://hub.docker.com/r/forgerock/openig-sample-server/


You can pull the current 5.x build using

docker pull  forgerock/openig-sample-server:5.0-alpine



