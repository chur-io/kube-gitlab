FROM richarvey/nginx-nodejs

RUN npm install -g grunt-cli karma bower
RUN npm install -g bower
WORKDIR /app

ADD package.json /tmp/package.json
ADD bower.json /tmp/bower.json
RUN cd /tmp && npm install
RUN cd /tmp && bower install --allow-root
RUN cp -a /tmp/node_modules /app/
RUN cp -a /tmp/bower_components /app/
RUN mv /app/bower_components /app/vendor

ADD . /app
RUN grunt compile
RUN cp -a /app/bin /usr/share/nginx/html

CMD []

EXPOSE 80