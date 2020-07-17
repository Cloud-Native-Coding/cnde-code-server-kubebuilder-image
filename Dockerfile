FROM eu.gcr.io/cloud-native-coding/code-server-example:latest

USER root

RUN apt-get update; \
    apt-get install -y apt-transport-https ca-certificates gnupg-agent software-properties-common; \
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -; \
    add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"; \
    apt-get update && apt-get install -y docker-ce-cli; \
    rm -rf /var/lib/apt/lists/*

RUN curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -; \
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee -a /etc/apt/sources.list.d/kubernetes.list; \
    apt-get update; apt-get install -y kubectl; \
    rm -rf /var/lib/apt/lists/*

RUN curl -L https://github.com/wercker/stern/releases/download/1.11.0/stern_linux_amd64 -o /usr/local/bin/stern; \
    chmod +x /usr/local/bin/stern

RUN apt-get update; apt-get install -y zsh; rm -rf /var/lib/apt/lists/*; \
    chsh -s /bin/zsh
COPY settings.json /home/cnde/.local/share/code-server/User/settings.json
ENV SHELL=/bin/zsh

RUN curl https://raw.githubusercontent.com/blendle/kns/master/bin/kns -o /usr/local/bin/kns; \ 
    chmod +x /usr/local/bin/kns

#####

RUN apt update && apt install -y build-essential ; rm -rf /var/lib/apt/lists/* ; \
    curl -L https://golang.org/dl/go1.14.4.linux-amd64.tar.gz | tar -C /usr/local -xzf - ; \
    curl -L https://go.kubebuilder.io/dl/2.3.1/linux/amd64 | tar -xz -C /tmp/ ; \
    mv /tmp/kubebuilder_2.3.1_linux_amd64 /usr/local/kubebuilder ; \
    cd /usr/local/bin ; curl -s "https://raw.githubusercontent.com/kubernetes-sigs/kustomize/master/hack/install_kustomize.sh"  | bash

RUN apt update && apt install -y libarchive-tools ; rm -rf /var/lib/apt/lists/* ; \
    mkdir -p /home/cnde/.local/share/code-server/extensions ; \
    curl -JL https://marketplace.visualstudio.com/_apis/public/gallery/publishers/golang/vsextensions/Go/0.15.1/vspackage | bsdtar -xf - extension ; \
    mv extension /home/cnde/.local/share/code-server/extensions/ms-vscode.go-0.15.1

#####

USER cnde
WORKDIR /home/cnde

ENV DOCKER_HOST tcp://0.0.0.0:2375

RUN sudo chown -R cnde .

RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
COPY --chown=cnde:cnde .zshrc .
RUN sudo chown -R cnde .
RUN git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf ; ~/.fzf/install

WORKDIR /home/cnde/project

#####

RUN git clone https://github.com/Cloud-Native-Coding/operator-with-kubebuilder.git example/operators/cronjob
