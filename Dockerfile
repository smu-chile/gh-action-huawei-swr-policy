FROM docker:19.03.4

RUN apk update \
  && apk upgrade \
  && apk add --no-cache --update openssl coreutils bash \
  && rm -rf /var/cache/apk/* 

# ADD entrypoint.sh /entrypoint.sh

# RUN ["chmod", "+x", "/entrypoint.sh"]

# ENTRYPOINT ["sh","/entrypoint.sh"]

