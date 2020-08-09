FROM alpine:latest

LABEL maintainer Melvin Cheng <melvin.cheng.ecs-digital.co.uk>

RUN apk add --update \
    python3 \
    python3-dev \
    --no-cache bash \
    --no-cache py-pip  \
    --no-cache curl \
    build-base && \
    pip install --upgrade pip && \
    pip install  mkdocs && \
    rm -rf /var/lib/apt/lists/* 

EXPOSE 8000

WORKDIR /mkdocs-site

HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8000/ || exit 1

ENTRYPOINT ["mkdocs"]
