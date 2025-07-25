# Despliegue de Angular 16 en Google Cloud VPS con Docker y GitHub Actions

Esta guía te ayudará a configurar un pipeline de CI/CD completo para desplegar tu aplicación Angular 16 en un VPS de Google Cloud usando Docker y GitHub Actions.

## 🏗️ Arquitectura

- **Aplicación**: Angular 16
- **Contenedor**: Docker con Ubuntu 22.04
- **Servidor web**: Nginx
- **CI/CD**: GitHub Actions
- **Infraestructura**: Google Cloud VPS
- **Registry**: Docker Hub

## 📋 Prerrequisitos

### En tu máquina local:
- Node.js 16+ 
- Docker
- Git

### En Google Cloud:
- VPS con Ubuntu 22.04
- Docker instalado en el VPS
- Acceso SSH configurado

### Cuentas necesarias:
- Cuenta de Docker Hub
- Repositorio en GitHub
- Acceso a Google Cloud Platform

## 🚀 Configuración paso a paso

### 1. Preparar el proyecto

1. Clona este repositorio o copia los archivos a tu proyecto Angular existente
2. Ejecuta el script de configuración:
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

### 2. Configurar Docker Hub

1. Crea una cuenta en [Docker Hub](https://hub.docker.com/)
2. Crea un repositorio público o privado para tu aplicación
3. Anota tu username y password

### 3. Configurar Google Cloud VPS

#### Crear el VPS:
```bash
# Crear una instancia de VM
gcloud compute instances create angular-app-vm \
    --zone=us-central1-a \
    --machine-type=e2-medium \
    --image-family=ubuntu-2204-lts \
    --image-project=ubuntu-os-cloud \
    --boot-disk-size=20GB \
    --tags=http-server,https-server
```

#### Configurar firewall:
```bash
# Permitir tráfico HTTP
gcloud compute firewall-rules create allow-http \
    --allow tcp:80 \
    --source-ranges 0.0.0.0/0 \
    --tags http-server

# Permitir tráfico HTTPS (opcional)
gcloud compute firewall-rules create allow-https \
    --allow tcp:443 \
    --source-ranges 0.0.0.0/0 \
    --tags https-server
```

#### Instalar Docker en el VPS:
```bash
# Conectar al VPS
gcloud compute ssh angular-app-vm --zone=us-central1-a

# Instalar Docker
sudo apt update
sudo apt install -y docker.io
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

# Verificar instalación
docker --version
```

### 4. Configurar SSH

#### Generar clave SSH (si no tienes una):
```bash
ssh-keygen -t rsa -b 4096 -C "tu-email@ejemplo.com"
```

#### Agregar clave pública al VPS:
```bash
# En tu máquina local
cat ~/.ssh/id_rsa.pub

# En el VPS, agregar la clave a authorized_keys
echo "tu-clave-publica-aqui" >> ~/.ssh/authorized_keys
```

### 5. Configurar GitHub Secrets

Ve a tu repositorio en GitHub → Settings → Secrets and variables → Actions

Agrega los siguientes secrets:

| Secret | Descripción | Ejemplo |
|--------|-------------|---------|
| `DOCKER_USERNAME` | Tu usuario de Docker Hub | `miusuario` |
| `DOCKER_PASSWORD` | Tu contraseña de Docker Hub | `mipassword` |
| `GCP_VPS_HOST` | IP pública de tu VPS | `34.123.45.67` |
| `GCP_VPS_USERNAME` | Usuario SSH del VPS | `ubuntu` |
| `GCP_VPS_SSH_KEY` | Clave privada SSH completa | Contenido de `~/.ssh/id_rsa` |
| `GCP_VPS_PORT` | Puerto SSH (opcional) | `22` |

### 6. Configurar tu aplicación Angular

Asegúrate de que tu `package.json` tenga estos scripts:
```json
{
  "scripts": {
    "build": "ng build",
    "test": "ng test",
    "lint": "ng lint"
  }
}
```

### 7. Desplegar

1. Haz commit de todos los archivos:
   ```bash
   git add .
   git commit -m "Add Docker and GitHub Actions configuration"
   git push origin main
   ```

2. El pipeline se ejecutará automáticamente y:
   - Ejecutará las pruebas
   - Construirá la imagen Docker
   - La subirá a Docker Hub
   - La desplegará en tu VPS

## 📁 Estructura de archivos

```
tu-proyecto/
├── .github/
│   └── workflows/
│       └── deploy.yml          # Pipeline de GitHub Actions
├── Dockerfile                  # Configuración de Docker
├── nginx.conf                  # Configuración de Nginx
├── docker-compose.yml          # Para desarrollo local
├── .dockerignore              # Archivos a ignorar en Docker
├── setup.sh                   # Script de configuración
└── README-Deployment.md       # Esta documentación
```

## 🔧 Comandos útiles

### Desarrollo local con Docker:
```bash
# Construir imagen
docker build -t angular-app .

# Ejecutar contenedor
docker run -d --name angular-app -p 8080:80 angular-app

# Ver logs
docker logs angular-app

# Detener contenedor
docker stop angular-app && docker rm angular-app
```

### Desarrollo local con Docker Compose:
```bash
# Iniciar
docker-compose up -d

# Ver logs
docker-compose logs -f

# Detener
docker-compose down
```

### Verificar despliegue en VPS:
```bash
# Conectar al VPS
gcloud compute ssh angular-app-vm --zone=us-central1-a

# Ver contenedores ejecutándose
docker ps

# Ver logs del contenedor
docker logs angular-container

# Verificar que la app responda
curl http://localhost
```

## 🔒 Consideraciones de seguridad

1. **SSL/TLS**: Considera usar Let's Encrypt para HTTPS
2. **Firewall**: Configura reglas específicas para tu aplicación
3. **SSH**: Usa claves SSH en lugar de contraseñas
4. **Docker**: Mantén las imágenes actualizadas
5. **Secrets**: Nunca hardcodees credenciales en el código

## 🐛 Troubleshooting

### Error en la construcción de Docker:
- Verifica que todos los archivos estén en el repositorio
- Revisa el `.dockerignore` 
- Asegúrate de que `npm run build` funcione localmente

### Error en el despliegue SSH:
- Verifica que la clave SSH sea correcta
- Comprueba que el usuario tenga permisos de Docker
- Verifica la IP y puerto del VPS

### Error en la aplicación:
- Revisa los logs: `docker logs angular-container`
- Verifica que nginx esté configurado correctamente
- Comprueba que los archivos estén en `/var/www/html`

## 📈 Mejoras futuras

- Configurar HTTPS con Let's Encrypt
- Implementar health checks
- Agregar monitoreo y alertas
- Configurar backup automático
- Implementar rollback automático
- Usar Google Container Registry en lugar de Docker Hub

## 🤝 Contribución

Si encuentras algún problema o tienes sugerencias de mejora, por favor crea un issue o pull request.

## 📄 Licencia

Este proyecto está bajo la licencia MIT.