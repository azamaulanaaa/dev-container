FROM debian:bookworm-slim

RUN useradd -ms /bin/bash dev
USER dev
WORKDIR /home/dev

CMD ["/bin/bash"]
