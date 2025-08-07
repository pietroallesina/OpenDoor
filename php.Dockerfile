# Use PHP CLI image
FROM php:8.2-cli

# Install system packages
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install mysqli extension
RUN docker-php-ext-install mysqli

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www/

# Install Google API Client
RUN composer require google/apiclient:^2.0

# Run PHP's built-in server
CMD ["php", "-S", "0.0.0.0:8000", "-t", "public/"]
