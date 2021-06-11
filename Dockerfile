# syntax=docker/dockerfile:1

FROM ubuntu
RUN apt update && apt install --no-install-recommends -y ssh python3.8 python3-pip python3.8-dev
WORKDIR /server
COPY python/app/requirements.txt .
RUN pip install -r requirements.txt
RUN pip install gunicorn
#COPY python/app/src/ . #Uncomment in production!!!!
RUN echo 'root:clobber' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

RUN useradd -ms /bin/bash clobber
RUN echo 'clobber:clobber' | chpasswd
RUN mkdir -p /scripts
#ENTRYPOINT service ssh start && gunicorn --bind 0.0.0.0:5000 main:app --log-level warning && echo "done" #Swap comments for production
ENTRYPOINT service ssh start && mkdir /home/clobber/cdata/commands && chown -R clobber:clobber /home/clobber/cdata/ && gunicorn --reload --bind 0.0.0.0:5000 main:app --log-level debug && echo "done"
