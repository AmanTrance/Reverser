FROM debian:latest

RUN apt update

RUN apt install openssh-server sudo iptables curl nano -y

WORKDIR /

COPY ./sshd_config /etc/ssh

COPY ./startup.sh .

EXPOSE 22

CMD ["/bin/bash", "./startup.sh"]