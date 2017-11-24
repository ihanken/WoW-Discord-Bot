FROM alpine:3.6

MAINTAINER Ian Hanken: ihanken@bellsouth.net

RUN apk update && apk upgrade && apk add curl python3

RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3

# Clean APK cache
RUN rm -rf /var/cache/apk/*

# Add the bot files
ADD . /bot
WORKDIR /bot

# Install PIP dependencies
RUN pip3 install -r requirements.txt

# Run the bot
CMD python3 bot.py