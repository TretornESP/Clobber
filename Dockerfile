# syntax=docker/dockerfile:1

FROM ubuntu
RUN apt update && apt install --no-install-recommends -y ssh python3.8 python3-pip python3.8-dev
WORKDIR /server
COPY python/app/requirements.txt .
RUN pip install -r requirements.txt
COPY python/app/src/ .
RUN echo 'root:clobber' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN useradd -ms /bin/bash clobber
RUN echo 'clobber:clobber' | chpasswd
RUN mkdir /home/clobber/cdata
ENTRYPOINT service ssh start && mount /dev/vhd /home/clobber/cdata && chown -R clobber:clobber /home/clobber/cdata && python3 main.py
