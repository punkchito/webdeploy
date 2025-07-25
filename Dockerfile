# Dockerfile para Angular 16 con Ubuntu 22
FROM ubuntu:22.04 as build

# Evitar prompts interactivos durante la instalación
ENV DEBIAN_FRONTEND=noninteractive

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    curl \
    wget \
    gnupg \
    lsb-release \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Instalar Node.js 18 (recomendado para Angular 16)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Verificar versiones
RUN node --version && npm --version

# Establecer directorio de trabajo
WORKDIR /app

# Copiar package.json y package-lock.json
COPY package*.json ./

# Instalar dependencias
RUN npm ci --only=production

# Copiar código fuente
COPY . .

# Construir la aplicación para producción
RUN npm run build --prod

# Etapa de producción con nginx
FROM ubuntu:22.04

# Instalar nginx
RUN apt-get update && apt-get install -y \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Copiar archivos construidos desde la etapa de build
COPY --from=build /app/dist/* /var/www/html/

# Copiar configuración personalizada de nginx
COPY nginx.conf /etc/nginx/sites-available/default

# Exponer puerto 80
EXPOSE 80

# Iniciar nginx
CMD ["nginx", "-g", "daemon off;"]