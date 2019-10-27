FROM nginx

LABEL maintainer="e-gk@qq.com"

RUN apt-get update

RUN apt-get install -y git

RUN rm -rf  /usr/share/nginx/html

RUN git clone https://github.com/akun2014/akun2014.github.io.git /usr/share/nginx/html/

EXPOSE 80