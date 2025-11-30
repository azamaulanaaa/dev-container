FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y \
  git

RUN useradd -ms /bin/bash dev
USER dev
WORKDIR /home/dev

CMD ["/bin/bash"]
