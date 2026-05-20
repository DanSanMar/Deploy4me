# minideploy4me 🐋

Versión reducida, ligera y optimizada del script original `deploy4me`. Diseñada especialmente para el despliegue rápido de laboratorios y máquinas vulnerables de **Dockerlabs** en entornos **WSL2 (Windows Subsystem for Linux)** o contenedores **Docker** donde el servicio corre directamente en el host principal.

Esta versión elimina comprobaciones innecesarias, instalaciones automáticas pesadas y arranques forzados del servicio Docker, confiando en la infraestructura ya existente del host.

---

## ✨ Características principales

* **Ultra ligero:** Eliminación de ruido, funciones redundantes y comprobaciones de servicios del sistema.
* **Optimizado para WSL2:** Diseñado para interactuar de forma nativa con Docker Desktop configurado en WSL2.
* **Ciclo de vida limpio:** Al presionar `Ctrl + C`, el script destruye automáticamente el contenedor para no dejar residuos en el sistema.
* **Inyección de servicios automatizada:** Arranca de forma transparente servicios web y de bases de datos (`Apache2`, `Nginx`, `MariaDB`, `MySQL`) dentro del contenedor.

---

## 🚀 Requisitos previos

1. **Docker instalado y corriendo:** En WSL2, asegúrate de tener Docker Desktop activo y con la integración de tu distribución Linux habilitada.
2. **Permisos de Sudo:** El script requiere ejecutar comandos de Docker con `sudo` para interactuar con el demonio del host.

---

## 🛠️ Modo de uso

Dale permisos de ejecución al script y lánzalo pasando como único argumento el archivo `.tar` de la máquina de Dockerlabs que desees desplegar.

```bash
# 1. Otorgar permisos de ejecución
chmod +x minideploy4me.sh

# 2. Desplegar la máquina vulnerable
./minideploy4me.sh nombre_de_la_maquina.tar
```

### 🏁 Finalización del laboratorio

Una vez que termines de auditar la máquina, simplemente regresa a la terminal donde ejecutas el script y presiona:

```text
Ctrl + C
```

El script capturará la señal, detendrá el contenedor y lo eliminará de forma segura.

---

## 📝 Flujo de ejecución del Script

1. **Validación:** Comprueba que se ha proporcionado un archivo `.tar` válido.
2. **Chequeo de Docker:** Advierte si no detecta Docker en el entorno pero permite continuar si se usa el host principal.
3. **Carga de Imagen:** Ejecuta un `docker load` del archivo comprimido.
4. **Despliegue Dinámico:** Genera un nombre de contenedor único basado en la marca de tiempo para evitar colisiones.
5. **Arranque de Servicios:** Inicia los servicios internos esenciales de la máquina CTF.
6. **Mapeo de Red:** Extrae y muestra en pantalla la IP asignada al laboratorio para comenzar el testeo de penetración.
