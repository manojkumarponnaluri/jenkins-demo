FROM node:18

WORKDIR /app

RUN echo "console.log('Hello from inside Docker container')" > index.js

CMD ["node", "index.js"]

