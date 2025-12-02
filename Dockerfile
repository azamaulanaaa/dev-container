FROM debian:bookworm-slim as builder-neovim
  
RUN apt-get update && apt-get install -y \
    ninja-build gettext cmake unzip curl build-essential git

RUN git clone https://github.com/neovim/neovim.git /neovim
WORKDIR /neovim
RUN git checkout stable

RUN make CMAKE_BUILD_TYPE=RelWithDebInfo \
    CMAKE_INSTALL_PREFIX=/opt/nvim install

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
  git \
  tmux \
  sudo \
  curl \
  file \
  procps \
  build-essential \
  && rm -rf /var/lib/apt/lists/*

COPY --from=builder-neovim /opt/nvim /opt/nvim

RUN useradd -ms /bin/bash dev \
  && echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER dev
WORKDIR /home/dev

RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
RUN echo "eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"" >> ~/.bashrc
ENV HOMEBREW_NO_ENV_HINTS=1
ENV HOMEBREW_FORCE_BOTTLE=1

RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && brew install \
  fzf \
  ripgrep \
  gitui \
  ttyd

RUN git clone -b personal --single-branch https://github.com/azamaulanaaa/nvim ~/.config/nvim 
RUN mkdir -p ~/.config/gitui \
  && curl -o .config/gitui/key_bindings.ron https://raw.githubusercontent.com/gitui-org/gitui/refs/heads/master/vim_style_key_config.ron

RUN git config --global --add safe.directory *
RUN git config --global core.editor nvim

ENV PATH="/opt/nvim/bin:/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"
CMD ["ttyd", "-W", "-t", "titleFixed=dev-container", "-p", "8080", "tmux", "new", "-A", "-s", "ttyd"]
