ARG VERSION=focal
FROM ubuntu:${VERSION}
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update --fix-missing
RUN apt-get install -y \
    ubuntu-server \
    zsh 

ARG UNAME=ubuntu
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} ${UNAME}
RUN useradd -m -u ${UID} -g ${GID} -s /bin/bash ${UNAME}
RUN echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers
RUN chsh -s $(which zsh) ${UNAME}

USER $UNAME
WORKDIR /home/${UNAME}
RUN git clone https://github.com/Homebrew/brew .linuxbrew
RUN .linuxbrew/bin/brew update --force --quiet
ENV PATH="/home/${UNAME}/.linuxbrew/bin:${PATH}"
RUN echo 'eval "$(/home/${UNAME}/.linuxbrew/bin/brew shellenv)"' >> .profile

COPY .zshrc .zshrc
COPY .p10k.zsh .p10k.zsh
COPY setup.sh setup.sh
RUN setup.sh 
