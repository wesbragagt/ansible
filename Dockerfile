FROM ubuntu:focal AS base

RUN apt-get update && \
    apt-get install -y -q --allow-unauthenticated \
    git \
    sudo \ 
    vim \
    curl

RUN echo "Defaults env_editor,editor=/usr/bin/vi:/usr/bin/nano:/usr/bin/vim" >> /etc/sudoers

# Create ubuntu user with sudo privileges
RUN useradd -ms /bin/bash wesbragagt && \
    usermod -aG sudo wesbragagt
# New added for disable sudo password
RUN echo 'wesbragagt ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Set as default user
USER wesbragagt
ENV HOME="/home/wesbragagt"

WORKDIR /home/wesbragagt
