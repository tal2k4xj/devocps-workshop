FROM node:10
RUN git clone https://github.com/tal2k4xj/node-s2i-openshift.git
WORKDIR node-s2i-openshift/site
RUN npm install
CMD npm start