# This seems to be borken, but considering that I am probably not going to use this, I will not fix the errors. 

ARG VERSION=focal
FROM ubuntu:${VERSION}
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update --fix-missing
RUN apt-get install -y \
    ubuntu-server \
    build-essential \
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
ENV HOMEBREW_PREFIX="/home/${UNAME}/.linuxbrew"
ENV HOMEBREW_CELLAR="/home/${UNAME}/.linuxbrew/Cellar"
ENV HOMEBREW_REPOSITORY="/home/${UNAME}/.linuxbrew"
ENV PATH="/home/${UNAME}/.linuxbrew/bin:/home/${UNAME}/.linuxbrew/sbin:${PATH}"
ENV MANPATH="/home/${UNAME}/.linuxbrew/share/man:${MANPATH}:"
ENV INFOPATH="/home/${UNAME}/.linuxbrew/share/info:${INFOPATH}"

COPY .zshrc .zshrc
COPY .p10k.zsh .p10k.zsh
COPY setup.sh setup.sh
RUN ./setup.sh 

USER root
RUN rm -rf /etc/sudoers
RUN apt-get install -y sudo 
RUN echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers
RUN yes | unminimize 
RUN apt-get install -y man 
USER $UNAME

