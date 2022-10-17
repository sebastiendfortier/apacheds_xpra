FROM ubuntu:20.04 as build

ENV DEBIAN_FRONTEND noninteractive
ENV SUDO_FORCE_REMOVE yes

SHELL ["/bin/bash", "-c"]

COPY ApacheDirectoryStudio-2.0.0.v20210717-M17-linux.gtk.x86_64.tar.gz /ApacheDirectoryStudio.tar.gz

RUN mkdir -p /ApacheDirectoryStudio && \
    tar -xvf /ApacheDirectoryStudio.tar.gz && \
    rm -rf /ApacheDirectoryStudio.tar.gz


FROM ubuntu:20.04

COPY --from=build /ApacheDirectoryStudio /ApacheDirectoryStudio

EXPOSE 8080

ENV DEBIAN_FRONTEND noninteractive
ENV TZ Etc/UTC

RUN apt-get update && \
    apt-get install -y --no-install-recommends tzdata \
    default-jdk \
    libswt-gtk-4-java \
    wget \
    gnupg \
    xvfb \
    x11-xserver-utils \
    python3-pip && \
    pip3 install pyinotify && \
    echo "deb [arch=amd64] https://xpra.org/ focal main" > /etc/apt/sources.list.d/xpra.list && \
    wget -q https://xpra.org/gpg.asc -O- | apt-key add - && \
    apt update && \
    dpkg-reconfigure --frontend noninteractive tzdata && \
    apt install -y xpra && \
    mkdir -p /run/user/0/xpra && \
    chmod 700 /run/user/0/xpra && \
    mkdir -p /tmp/80 && \
    chmod 700 /tmp/80 && \
    apt-get remove -y \
    wget \
    gnupg \
    python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /root/.cache/* && \
    find -name '*.a' -delete && \
    find -name '__pycache__' -type d -exec rm -rf '{}' '+' && \ 
    find /usr/lib/ -name 'tests' -type d -exec rm -rf '{}' '+' && \
    apt autoremove -y
      

ENTRYPOINT ["xpra", "start", ":80", "--bind-tcp=0.0.0.0:8080", \
            "--mdns=no", "--webcam=no", "--no-daemon", \
            "--start-on-connect=/ApacheDirectoryStudio/ApacheDirectoryStudio", \
            "--start=xhost +"]

 

