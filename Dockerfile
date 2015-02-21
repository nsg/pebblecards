FROM ubuntu:14.04

RUN apt-get update && apt-get install -y nginx python python-pip python-dev
RUN pip install Flask==0.10.1 && pip install gunicorn

ADD nginx.conf /etc/nginx/nginx.conf
ADD app.py /usr/share/nginx/html/
ADD entrypoint /usr/local/bin/entrypoint
ADD debug /usr/local/bin/debug
RUN chmod +x /usr/local/bin/entrypoint /usr/local/bin/debug

ENTRYPOINT /usr/local/bin/entrypoint
