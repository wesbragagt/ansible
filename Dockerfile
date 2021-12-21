FROM linuxbrew/linuxbrew AS base
WORKDIR /usr/local/bin
ENV DEBIAN_FRONTEND=noninteractive
RUN brew update
RUN brew install ansible
ARG TAGS
RUN addgroup --gid 1000 wesbragagt
RUN adduser --gecos wesbragagt --uid 1000 --gid 1000 --disabled-password wesbragagt
USER wesbragagt
WORKDIR /home/wesbragagt

COPY . ./

CMD ["sh", "-c", "ansible-playbook $TAGS local.yml"]
