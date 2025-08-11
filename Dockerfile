# Dockerfile para Angular con rutas corregidas
FROM node:20-alpine AS build

WORKDIR /app

# Copiar archivos de configuración
COPY package*.json ./
COPY .npmrc* ./

# Instalar dependencias
RUN npm config set legacy-peer-deps true && \
    npm install --legacy-peer-deps --no-audit --no-fund

# Copiar código fuente
COPY . .

# Construir aplicación
RUN npm run build

# Mostrar contenido del build para debugging
RUN echo "=== CONTENIDO DEL BUILD ===" && \
    find dist -type f -name "*.html" && \
    ls -la dist/

# Usar nginx oficial
FROM nginx:alpine

# Eliminar configuración por defecto
RUN rm /etc/nginx/conf.d/default.conf

# Copiar configuración personalizada de nginx
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Crear directorio correcto según nginx.conf
RUN mkdir -p /var/www/html

# Copiar archivos del build desde la ubicación correcta (proyecto/browser)
COPY --from=build /app/dist/proyecto/browser/ /var/www/html/

# Verificar archivos copiados
RUN echo "=== ARCHIVOS EN /var/www/html ===" && \
    ls -la /var/www/html/ && \
    find /var/www/html -name "*.html" -type f

# Verificar configuración de nginx
RUN nginx -t

# Dar permisos correctos
RUN chown -R nginx:nginx /var/www/html && \
    chmod -R 755 /var/www/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]