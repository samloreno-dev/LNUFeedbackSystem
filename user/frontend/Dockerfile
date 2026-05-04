# -------- STAGE 1: Build Flutter Web --------
FROM ghcr.io/cirruslabs/flutter:stable AS build

WORKDIR /app

# Copy everything
COPY . .

# Enable web
RUN flutter config --enable-web

# Get dependencies
RUN flutter pub get

# Build web
RUN flutter build web

# -------- STAGE 2: Serve with Nginx --------
FROM nginx:alpine

# Remove default nginx site
RUN rm -rf /usr/share/nginx/html/*

# Copy built Flutter web files
COPY --from=build /app/build/web /usr/share/nginx/html

# Expose port
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]