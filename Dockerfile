FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
  git \
  tmux \
  sudo

RUN useradd -ms /bin/bash dev \
  && echo "dev ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
USER dev
WORKDIR /home/dev

CMD ["tmux", "new-session", "-A", "-s", "dev"]
