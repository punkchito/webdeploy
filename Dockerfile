# Dockerfile para Angular 18 con Ubuntu 22
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

# Instalar Node.js 20 (requerido para Angular 18)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs

# Verificar versiones
RUN node --version && npm --version

# Establecer directorio de trabajo
WORKDIR /app

# Copiar archivos de configuración
COPY package*.json ./
COPY .npmrc* ./

# Configurar npm para Angular 18
RUN npm config set legacy-peer-deps true && \
    npm config set audit-level moderate && \
    npm config set fund false && \
    npm cache clean --force && \
    rm -rf package-lock.json node_modules

# Instalar dependencias
RUN npm install --legacy-peer-deps --no-audit --no-fund

# Copiar código fuente
COPY . .

# Construir la aplicación para producción
RUN npm run build

# Etapa de producción con nginx
FROM ubuntu:22.04

# Instalar nginx
RUN apt-get update && apt-get install -y \
    nginx \
    && rm -rf /var/lib/apt/lists/*

# Copiar archivos construidos desde la etapa de build
COPY --from=build /app/dist/proyecto /var/www/html/

# Copiar configuración personalizada de nginx
COPY nginx.conf /etc/nginx/sites-available/default

# Exponer puerto 80
EXPOSE 80

# Iniciar nginx
CMD ["nginx", "-g", "daemon off;"]