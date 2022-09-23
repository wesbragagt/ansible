FROM linuxbrew/brew

RUN apt-get update && \
    apt-get install -y -q --allow-unauthenticated \
    git \
    sudo \ 
    vim \
    curl
RUN echo "Defaults env_editor,editor=/usr/bin/vi:/usr/bin/nano:/usr/bin/vim" >> /etc/sudoers

RUN apt-get install build-essential -y
RUN apt-add-repository -y ppa:ansible/ansible
RUN apt-get update -y
RUN apt-get install -y ansible


# Create ubuntu user with sudo privileges
RUN useradd -ms /bin/bash wesbragagt && \
    usermod -aG sudo wesbragagt
# New added for disable sudo password
RUN echo 'wesbragagt ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Set as default user
USER wesbragagt
ENV HOME="/home/wesbragagt"

ENV PATH="/home/linuxbrew/.linuxbrew/bin:${PATH}"

RUN sudo chown -R wesbragagt /home/linuxbrew/.linuxbrew

WORKDIR /home/wesbragagt
