FROM node:18-slim@sha256:f9ab18e354e6855ae56ef2b290dd225c1e51a564f87584b9bd21dd651838830e

# add curl for healthcheck
RUN apt-get update && \
    apt-get install -y --no-install-recommends curl tini && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local/app
RUN useradd --create-home --uid 10001 appuser

# have nodemon available for local dev use (file watching)
RUN npm install -g nodemon --fetch-timeout=120000 --fetch-retries=10

COPY package*.json ./

RUN npm ci && \
 npm cache clean --force && \
 mv /usr/local/app/node_modules /node_modules

COPY . .
RUN chown -R appuser:appuser /usr/local/app
USER 10001:10001

ENV PORT=8080
EXPOSE 8080

ENTRYPOINT ["/usr/bin/tini", "--"]
CMD ["node", "server.js"]
