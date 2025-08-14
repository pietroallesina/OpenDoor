# Use PHP CLI image
FROM php:8.2-cli

# Install mysqli extension
RUN docker-php-ext-install mysqli

# Set working directory
WORKDIR /var/www/

# Run PHP's built-in server
CMD ["php", "-S", "0.0.0.0:8000", "-t", "public/"]
