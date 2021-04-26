FROM ubuntu:20.04
RUN apt update
RUN apt-get install -y curl
COPY test-app.sh /
RUN chmod 755 /test-app.sh
CMD bash /test-app.sh