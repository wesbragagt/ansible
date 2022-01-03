FROM ubuntu:focal AS base

WORKDIR /usr/local/bin
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get upgrade -y 
RUN apt-get install -y software-properties-common curl git build-essential 
RUN apt-add-repository -y ppa:ansible/ansible 
RUN apt-get update 
RUN apt-get install -y curl git ansible build-essential sudo
RUN apt-get clean autoclean 
RUN apt-get autoremove --yes 
RUN apt-get install vim --yes

RUN curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
 
FROM base AS wes
# Create ubuntu user with sudo privileges
RUN useradd -ms /bin/bash wesbragagt && \
    usermod -aG sudo wesbragagt
# New added for disable sudo password
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Set as default user
USER wesbragagt
ENV HOME="/home/wesbragagt"

ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"
RUN sudo chown -R wesbragagt /home/linuxbrew/.linuxbrew

WORKDIR /home/wesbragagt
