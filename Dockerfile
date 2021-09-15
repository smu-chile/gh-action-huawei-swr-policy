FROM docker:19.03.4

RUN apk update \
  && apk upgrade 
  
ADD entrypoint.sh /entrypoint.sh

RUN ["chmod", "+x", "/entrypoint.sh"]

ENTRYPOINT ["/entrypoint.sh"]

