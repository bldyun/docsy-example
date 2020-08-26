FROM registry-1.docker.io/bldyun/website:builder-3f480 as builder
COPY . /src
WORKDIR /src
RUN git clone --recurse-submodules --depth 1 https://github.com/google/docsy.git \
 && npm install \
 &&  hugo --minify

FROM node:12.10.0-alpine

RUN apk update \
 && apk add --no-cache bash tzdata nginx\
 && cp -r -f /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
 && mkdir -p /run/nginx

WORKDIR /src
COPY --from=builder /src/public /src/public
COPY --from=builder /src/docker /docker
RUN mv /docker/default.conf /etc/nginx/conf.d \
 && chmod +x /docker/docker-entrypoint.sh \
 && mkdir -p /src/public

ENTRYPOINT ["/docker/docker-entrypoint.sh"]
EXPOSE 1313

