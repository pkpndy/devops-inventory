# slim version reduces the size more
# build stage
FROM node:22.12.0-bullseye-slim AS build

# specify the work directory
# for keeping things organised
WORKDIR /usr/src/app

# Copy only files required to install
# dependencies (better layer caching)
# the layers are cached and this layer 
# will only be invalidated once there 
# is change in dependencies 
COPY package*.json ./
RUN --mount=type=cache,target=/usr/src/app/.npm \
    npm set cache /usr/src/app/.npm && \
    npm install

COPY . .

RUN npm run build

# serving stage on production
FROM nginxinc/nginx-unprivileged:1.27-alpine-perl

# replace default config with custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# copy static build files to nginx serving directory
COPY --from=build usr/src/app/dist/ usr/share/nginx/html

# here we use 8080 since unpriviledged 
# users can't use ports below 1024
EXPOSE 8080

