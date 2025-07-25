#!/bin/bash

# Script de configuración para el despliegue de Angular en Google Cloud VPS
echo "🚀 Configurando el entorno para despliegue de Angular 16..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para imprimir mensajes
print_message() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verificar si Docker está instalado
if ! command -v docker &> /dev/null; then
    print_error "Docker no está instalado. Por favor, instálalo primero."
    exit 1
fi

# Verificar si Node.js está instalado
if ! command -v node &> /dev/null; then
    print_error "Node.js no está instalado. Por favor, instálalo primero."
    exit 1
fi

# Verificar la versión de Node.js
NODE_VERSION=$(node --version | cut -d'v' -f2)
REQUIRED_VERSION="16.0.0"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$NODE_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    print_error "Se requiere Node.js versión $REQUIRED_VERSION o superior. Versión actual: $NODE_VERSION"
    exit 1
fi

print_message "Node.js versión $NODE_VERSION detectada"

# Crear estructura de directorios si no existe
mkdir -p .github/workflows

print_message "Estructura de directorios creada"

# Verificar archivos necesarios
files=("package.json" "angular.json")
for file in "${files[@]}"; do
    if [ ! -f "$file" ]; then
        print_error "Archivo $file no encontrado. Asegúrate de estar en el directorio raíz del proyecto Angular."
        exit 1
    fi
done

print_message "Archivos del proyecto Angular verificados"

# Instalar dependencias si no existen
if [ ! -d "node_modules" ]; then
    print_message "Instalando dependencias de npm..."
    npm install
fi

# Configurar scripts en package.json si no existen
print_message "Verificando scripts en package.json..."

# Test de construcción local
print_message "Probando construcción local..."
npm run build --prod

if [ $? -eq 0 ]; then
    print_message "Construcción local exitosa"
else
    print_error "Error en la construcción local. Revisa tu configuración de Angular."
    exit 1
fi

# Construir imagen Docker de prueba
print_message "Construyendo imagen Docker de prueba..."
docker build -t angular-app-test .

if [ $? -eq 0 ]; then
    print_message "Imagen Docker construida exitosamente"
else
    print_error "Error al construir la imagen Docker"
    exit 1
fi

# Probar contenedor localmente
print_message "Probando contenedor localmente..."
docker run -d --name angular-test -p 8080:80 angular-app-test

# Esperar a que el contenedor inicie
sleep 5

# Verificar que el contenedor esté ejecutándose
if docker ps | grep -q angular-test; then
    print_message "Contenedor ejecutándose correctamente en puerto 8080"
    echo "Puedes probarlo visitando: http://localhost:8080"
else
    print_error "El contenedor no se está ejecutando correctamente"
fi

# Limpiar contenedor de prueba
docker stop angular-test
docker rm angular-test
docker rmi angular-app-test

print_message "Limpieza completada"

echo ""
print_warning "Configuración de GitHub Secrets necesaria:"
echo "1. DOCKER_USERNAME - Tu usuario de Docker Hub"
echo "2. DOCKER_PASSWORD - Tu contraseña de Docker Hub"
echo "3. GCP_VPS_HOST - IP de tu VPS en Google Cloud"
echo "4. GCP_VPS_USERNAME - Usuario SSH del VPS"
echo "5. GCP_VPS_SSH_KEY - Clave privada SSH (completa)"
echo "6. GCP_VPS_PORT - Puerto SSH (opcional, por defecto 22)"

echo ""
print_warning "Configuración del VPS necesaria:"
echo "1. Instalar Docker en el VPS"
echo "2. Configurar acceso SSH con clave pública"
echo "3. Abrir puerto 80 en el firewall"

echo ""
print_message "🎉 Configuración inicial completada exitosamente!"
print_message "Ahora puedes hacer commit y push de estos archivos para activar el despliegue automático."