FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
  git \
  tmux

RUN useradd -ms /bin/bash dev
USER dev
WORKDIR /home/dev

CMD ["tmux", "new-session", "-A", "-s", "dev"]
