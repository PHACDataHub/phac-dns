FROM mcr.microsoft.com/vscode/devcontainers/base:buster AS main_devcontainer

# [Option] Install zsh
ARG INSTALL_ZSH="true"
# [Option] Upgrade OS packages to their latest versions
ARG UPGRADE_PACKAGES="false"
# [Option] Enable non-root Docker access in container
ARG ENABLE_NONROOT_DOCKER="true"

# Install needed packages and setup non-root user. Use a separate RUN statement to add your own dependencies.
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN apt-get update
RUN apt-get install -y google-cloud-cli

# # [Optional] If you need kubectl command.
RUN apt-get install kubectl -y

# [Optional] If you need KPT command 
RUN apt-get install google-cloud-cli-kpt

# Let's get neovim!
RUN apt update
RUN apt install neovim

# [Optional] If you need vim and unuse nano.
# RUN apt-get install vim -y && \
#     unlink /etc/alternatives/editor && \
#     ln -s /usr/bin/vim.basic /etc/alternatives/editor && \
#     apt remove nano -y

# Switch to non-root user
USER ${USERNAME}

COPY library-scripts/zsh-append.sh /tmp/library-scripts/
# Append to .bashrc for the vscode user
RUN /bin/zsh /tmp/library-scripts/zsh-append.sh 

# Need sudo to delete the shell script we copied.
RUN sudo rm -rf /tmp/library-scripts/
