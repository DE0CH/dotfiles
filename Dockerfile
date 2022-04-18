FROM ubuntu:focal
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update --fix-missing
RUN apt-get update
RUN apt-get install -y \
	ubuntu-server \
	build-essential \
	zsh \
	python3-pip \
	ca-certificates \
	curl \
	gnupg \
	lsb-release

ARG UNAME=ubuntu
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} ${UNAME}
RUN useradd -m -u ${UID} -g ${GID} -s /bin/bash ${UNAME}
RUN echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers
RUN chsh -s $(which zsh) ${UNAME}


USER $UNAME
WORKDIR /home/${UNAME}
COPY homebrew .linuxbrew
RUN .linuxbrew/bin/brew update --force --quiet
ENV PATH="/home/${UNAME}/.linuxbrew/bin:${PATH}"
RUN echo 'eval "$(/home/${UNAME}/.linuxbrew/bin/brew shellenv)"' >> .profile

COPY .zshrc .zshrc
COPY .p10k.zsh .p10k.zsh
COPY setup.sh setup.sh
RUN setup.sh 