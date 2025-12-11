# Use Node.js 20 Debian-based image (glibc included)
FROM node:20-bullseye

# Set working directory
WORKDIR /usr/src/app

# Install system dependencies for building native modules
RUN apt-get update && apt-get install -y \
    build-essential \
    python3 \
    git \
    bash \
    libc6-dev \
 && rm -rf /var/lib/apt/lists/*

# Copy package.json and package-lock.json first (for caching)
COPY package*.json ./

# Install Node dependencies
RUN npm install

# Copy project files
COPY . .

# Expose Strapi default port
EXPOSE 1337

# Start Strapi
CMD ["npm", "start"]
