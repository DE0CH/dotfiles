ARG VERSION=focal
FROM ubuntu:${VERSION}
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
  && apt-get install -y --no-install-recommends software-properties-common \
  && add-apt-repository -y ppa:git-core/ppa \
  && apt-get update \
  && apt-get install -y --no-install-recommends \
    bzip2 \
    ca-certificates \
    curl \
    file \
    fonts-dejavu-core \
    g++ \
    gawk \
    git \
    less \
    libz-dev \
    locales \
    make \
    netbase \
    openssh-client \
    patch \
    sudo \
    uuid-runtime \
    tzdata \
  && rm -rf /var/lib/apt/lists/* \
  && localedef -i en_US -f UTF-8 en_US.UTF-8

ARG UNAME=ubuntu
ARG UID=1000
ARG GID=1000
RUN groupadd -g ${GID} ${UNAME}
RUN useradd -m -u ${UID} -g ${GID} -s /bin/bash ${UNAME}
RUN echo "${UNAME} ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers
RUN chsh -s $(which zsh) ${UNAME}


USER $UNAME
WORKDIR /home/${UNAME}
COPY --chown=${UNAME}:${UNAME} homebrew .linuxbrew
RUN mkdir -p \
     .linuxbrew/bin \
     .linuxbrew/etc \
     .linuxbrew/include \
     .linuxbrew/lib \
     .linuxbrew/opt \
     .linuxbrew/sbin \
     .linuxbrew/share \
     .linuxbrew/var/homebrew/linked \
     .linuxbrew/Cellar \
  && ln -s ../Homebrew/bin/brew .linuxbrew/bin/brew \
  && git -C .linuxbrew/Homebrew remote set-url origin https://github.com/Homebrew/brew \
  && git -C .linuxbrew/Homebrew fetch origin \
  && HOMEBREW_NO_ANALYTICS=1 HOMEBREW_NO_AUTO_UPDATE=1 brew tap homebrew/core \
  && brew install-bundler-gems \
  && brew cleanup \
  && { git -C .linuxbrew/Homebrew config --unset gc.auto; true; } \
  && { git -C .linuxbrew/Homebrew config --unset homebrew.devcmdrun; true; } \
  && rm -rf .cache
RUN .linuxbrew/bin/brew update --force --quiet
ENV PATH="/home/${UNAME}/.linuxbrew/bin:${PATH}"
RUN echo 'eval "$(/home/${UNAME}/.linuxbrew/bin/brew shellenv)"' >> .profile

COPY .zshrc .zshrc
COPY .p10k.zsh .p10k.zsh
COPY setup.sh setup.sh
RUN setup.sh 
