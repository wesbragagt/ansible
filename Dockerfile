FROM sickcodes/docker-osx:latest

RUN curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh | bash
ENV PATH="/home/linuxbrew/.linuxbrew/bin:$PATH"

RUN brew update
RUN brew install ansible
ARG TAGS

COPY . ./
RUN mkdir $HOME/.ssh
CMD ["sh", "-c", "ansible-playbook $TAGS local.yml"]
