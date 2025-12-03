FROM debian:bookworm-slim AS builder-neovim
  
RUN apt-get update && apt-get install -y \
    ninja-build gettext cmake unzip curl build-essential git

RUN git clone https://github.com/neovim/neovim.git /neovim
WORKDIR /neovim
RUN git checkout stable

RUN make CMAKE_BUILD_TYPE=RelWithDebInfo \
    CMAKE_INSTALL_PREFIX=/opt/nvim install

FROM debian:bookworm-slim
ARG TARGETARCH

RUN apt-get update && apt-get install -y \
  git \
  tmux \
  sudo \
  curl \
  fzf \
  ripgrep \
  man \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder-neovim /opt/nvim /opt/nvim
RUN ln -s /opt/nvim/bin/nvim /usr/local/bin/nvim

ADD https://github.com/tsl0922/ttyd/releases/download/1.7.7/ttyd.${TARGETARCH} /usr/local/bin/ttyd
RUN chmod +x /usr/local/bin/ttyd

ADD https://github.com/extrawurst/gitui/releases/download/v0.27.0/gitui-linux-${TARGETARCH}.tar.gz /tmp/gitui.tar.gz
RUN tar -xzf /tmp/gitui.tar.gz -C /usr/local/bin && rm /tmp/gitui.tar.gz

COPY ./script/yank /usr/local/bin/yank
RUN chmod +x /usr/local/bin/yank
RUN ln -s /usr/local/bin/yank /usr/local/bin/clip.exe

RUN useradd -ms /bin/bash dev \
  && echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER dev
WORKDIR /home/dev

RUN git config --global --add safe.directory *
RUN git config --global core.editor nvim

RUN git clone -b personal --single-branch https://github.com/azamaulanaaa/nvim ~/.config/nvim 

RUN mkdir -p ~/.config/gitui \
  && curl -o .config/gitui/key_bindings.ron https://raw.githubusercontent.com/gitui-org/gitui/refs/heads/master/vim_style_key_config.ron

CMD ["ttyd", "-W", "-t", "titleFixed=dev-container", "-p", "8080", "tmux", "new", "-A", "-s", "ttyd"]
