FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
  git \
  tmux \
  sudo \
  curl \
  file \
  procps \
  build-essential

RUN useradd -ms /bin/bash dev \
  && echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER dev
WORKDIR /home/dev

RUN /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
RUN echo "eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"" >> ~/.bashrc
RUN echo "export HOMEBREW_NO_ENV_HINTS=1" >> ~/.bashrc

RUN eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)" && brew install \
  neovim 

CMD ["tmux", "new-session", "-A", "-s", "dev"]
