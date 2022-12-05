FROM node:10.24.1-alpine AS build-stage

# create destination directory
RUN mkdir -p /src
WORKDIR /src

COPY package*.json ./
RUN npm ci && npm cache clean --force

COPY . .

RUN npm run build
RUN rm -Rf node_modules

FROM node:10.24.1-alpine AS production-stage

WORKDIR /app

COPY package*.json ./
RUN npm ci --omit=dev && npm cache clean --force
COPY --from=build-stage /src/ .

# start the app
RUN npm run build

#
# ---- Serve using nginx ----
FROM nginx:1.23-alpine AS production
COPY --from=production-stage /app/dist /usr/share/nginx/html
COPY --from=production-stage /app/nginx/default.conf /etc/nginx/conf.d/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
