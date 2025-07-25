# Dockerfile simplificado para debugging
FROM node:20-alpine as build

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

# Copiar todos los archivos del build
COPY --from=build /app/dist/ /usr/share/nginx/html/

# Crear configuración simple
RUN echo 'server {' > /etc/nginx/conf.d/default.conf && \
    echo '    listen 80;' >> /etc/nginx/conf.d/default.conf && \
    echo '    root /usr/share/nginx/html;' >> /etc/nginx/conf.d/default.conf && \
    echo '    index index.html;' >> /etc/nginx/conf.d/default.conf && \
    echo '    location / {' >> /etc/nginx/conf.d/default.conf && \
    echo '        try_files $uri $uri/ /index.html;' >> /etc/nginx/conf.d/default.conf && \
    echo '    }' >> /etc/nginx/conf.d/default.conf && \
    echo '}' >> /etc/nginx/conf.d/default.conf

# Verificar archivos copiados
RUN echo "=== ARCHIVOS EN NGINX ===" && \
    ls -la /usr/share/nginx/html/ && \
    find /usr/share/nginx/html -name "*.html" -type f

# Verificar configuración
RUN nginx -t

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]