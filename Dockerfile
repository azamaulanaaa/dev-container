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

RUN useradd -ms /bin/bash dev \
  && echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER dev
WORKDIR /home/dev

RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
RUN echo "eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"" >> ~/.bashrc
ENV HOMEBREW_NO_ENV_HINTS=1
ENV HOMEBREW_FORCE_BOTTLE=1

RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && brew install -v \
  neovim \
  fzf \
  ripgrep \
  gitui \
  ttyd

RUN git clone -b personal --single-branch https://github.com/azamaulanaaa/nvim ~/.config/nvim 
RUN mkdir -p ~/.config/gitui \
  && curl -o .config/gitui/key_bindings.ron https://raw.githubusercontent.com/gitui-org/gitui/refs/heads/master/vim_style_key_config.ron

RUN git config --global --add safe.directory *

ENV PATH="/home/linuxbrew/.linuxbrew/bin:/home/linuxbrew/.linuxbrew/sbin:${PATH}"
CMD ["ttyd", "-W", "-p", "8080", "tmux", "new", "-A", "-s", "ttyd"]
