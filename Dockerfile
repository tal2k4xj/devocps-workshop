FROM node:10
WORKDIR /site
ADD . https://github.com/tal2k4xj/node-s2i-openshift
RUN npm install
CMD npm start