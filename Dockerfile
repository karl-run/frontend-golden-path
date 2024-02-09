FROM node:20@sha256:fd0115473b293460df5b217ea73ff216928f2b0bb7650c5e7aa56aae4c028426 AS builder

WORKDIR /app

RUN --mount=type=secret,id=NODE_AUTH_TOKEN \
    npm config set //npm.pkg.github.com/:_authToken=$(cat /run/secrets/NODE_AUTH_TOKEN)

RUN npm config set @navikt:registry=https://npm.pkg.github.com

COPY package*.json next.config.js tsconfig.json ./
COPY pages/ /app/pages
COPY styles/ /app/styles
COPY public/ /app/public

RUN npm ci
RUN npm run build

FROM gcr.io/distroless/nodejs20-debian11@sha256:8cf9967ae9ba1e64089f853abac42b41f2af95ff3aa00d08c26e5f75714605d4 as runtime

WORKDIR /app

COPY --from=builder /app/.next/standalone /app/
COPY --from=builder /app/public /app/public

EXPOSE 3000

ENV NODE_ENV=production

CMD ["server.js"]