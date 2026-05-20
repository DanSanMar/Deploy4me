#!/bin/bash

# ==============================================================================
# SCRIPT DE AUTO-DESPLIEGUE PARA LABORATORIOS CTF - Versión 1 ligth docker.io
# ==============================================================================
# para limpiar la salida:
stty -echoctl
# --- FUNCIONES DE CONTROL ---
# --- DEFINICIÓN DE COLORES ---
CRE='\033[31m'; CYE='\033[33m'; CGR='\033[32m'; CBL='\033[34m'
CBLE='\033[36m'; CBK='\033[37m'; CGY='\033[90m'; BLD='\033[1m'; CNC='\033[0m'

detener_y_eliminar_contenedor() {
    if [ -n "$CONTAINER_NAME" ]; then
        echo -e "\n\e[1;34m[*] Limpiando entorno del contenedor: $CONTAINER_NAME...\e[0m"
        docker rm -f "$CONTAINER_NAME" > /dev/null 2>&1 || true
        echo -e "\n\e[1;32m[+] Contenedor $CONTAINER_NAME eliminado con éxito.\e[0m"
        echo -e "\n\e[1;34m[!] Gracias por usar DOCKERLABS con deploy4me, bye bye!\e[0m"
    fi
}

trap ctrl_c INT

function ctrl_c() {
    echo -e "\n\e[1;33m[!] Señal de interrupción detectada. Eliminando este laboratorio...\e[0m" 
    detener_y_eliminar_contenedor
    exit 0
}

# --- VALIDACIONES INICIALES ---

if [ $# -ne 1 ]; then
    echo -e "\e[1;31m[!] Error: Debes proporcionar el archivo .tar\e[0m"
    echo "Uso: $0 <archivo_tar>"
    exit 1
fi

# --- COMPROBACIÓN E INSTALACIÓN DE DOCKER ---

check_docker_installed() {
    command -v docker &> /dev/null
}

if check_docker_installed; then
    echo -e "${CGR}[✓]${CNC} Docker ya está instalado."
else
    echo -e "${CYE}[!]${CNC} Docker no encontrado. Instale docker o comrpruebe que funciona a través del host principal"
    echo "........................."
    echo -e "${CYE}[!]${CNC} En WSL2, asegúrate de que Docker Desktop esté instalado y configurado para usar WSL2."
    read -p "Presiona Enter para continuar de todas formas o Ctrl+C para salir..."
fi


TAR_FILE="$1"

if [ ! -f "$TAR_FILE" ]; then
    echo -e "\e[1;31m[!] Error: El archivo '$TAR_FILE' no existe.\e[0m"
    exit 1
fi


# --- VARIABLES DINÁMICAS ---
# Si no se pasa nombre, usa el nombre del archivo sin extensión
SCRIPT_NAME=$(basename "$TAR_FILE" .tar)
VERSION="con deploy4me v5.0"

# --- FUNCIÓN DE IMPRESIÓN DEL LOGO ---
print_logo() {
    printf "\n"
    printf "\t                   ${CRE} ##       ${CBK} .         \n"
    printf "\t             ${CRE} ## ## ##      ${CBK} ==         \n"
    printf "\t           ${CRE}## ## ## ##      ${CBK}===         \n"
    printf "\t       ${CBLE}/\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\"\\\___/ ${CBL}===       \n"
    printf "\t  ${CBL}~~~ ${CBK}{${CBL}~~ ~~~~ ~~~ ~~~~ ~~ ~ ${CBK}/  ${CYE}- ${CBL}===- ${CBL}~~~${CBK}\n"
    printf "\t       \\______${CBK} o ${CBK}         __/           \n"
    printf "\t         \\    \\        __/            \n"
    printf "\t          \\____\\______/               \n"
    printf "\n"
    printf "${BLD}${CBLE}                                          \n"
    printf "  ___  ____ ____ _  _ ____ ____ _    ____ ___  ____ \n"
    printf "  |  \\ |  | |    |_/  |___ |__/ |    |__| |__] [__  \n"
    printf "  |__/ |__| |___ | \\_ |___ |  \\ |___ |  | |__] ___] \n"
    printf "${CNC}                                          \n"
    printf "\n"
    # Línea de estado y nombre del script
    printf "${CGR}[✔]${CNC} Lanzando [${BLD}${CBLE}${SCRIPT_NAME}${CNC}${BLD}]${CNC} ${VERSION}${CNC} - Solo será un momento...\n"
    
    # Línea de información y ayuda
    printf "${CYE}[I]${BLD} Programa desarrollado para desplegar en WSL2 y Kali Linux\n"
    printf "${CBK}[!] Recuerda!! Puedes abrir tu navegador desde la terminal de WSL2 para ver el puerto 80 del contenedor${CNC}\n"
    
}

# Ejecutar logo
print_logo

# --- DESPLIEGUE ---

echo -e "\e[1;93m\n[*] Cargando imagen desde: $TAR_FILE\n\e[0m"

# 1. Cargar imagen (Tu lógica original)
if ! sudo docker load -i "$TAR_FILE"; then
    echo -e "\n\e[91m\n[X] Error fatal al cargar el .tar. Revisa el archivo.\e[0m"
    exit 1
fi

# 2. Definición de variables (Plan B directo como pediste)
IMAGE_REPO=$(basename "$TAR_FILE" .tar)
IMAGE_NAME="${IMAGE_REPO}:latest"

# Verificamos con sudo para que no diga que no existe por falta de permisos
if ! sudo docker image inspect "$IMAGE_NAME" > /dev/null 2>&1; then
    echo -e "\e[91m[X] La imagen $IMAGE_NAME no se encontró tras cargar.\e[0m"
    exit 1
fi

ID_UNICO=$(date +%s)
# Usamos el nombre del repo directamente para el contenedor, quitando caracteres que no sean letras o números
CONTAINER_NAME_BASE=$(echo "$IMAGE_REPO" | sed 's/[^a-zA-Z0-9]//g')
CONTAINER_NAME="${CONTAINER_NAME_BASE}_${ID_UNICO}" 

echo -e "\n\e[1;34m[*] Lanzando contenedor con el ID: $CONTAINER_NAME\n\e[0m"

# 3. Ejecutar contenedor (Tu bloque original de servicios)
sudo docker run -d -p 80 --name "$CONTAINER_NAME" "$IMAGE_NAME" \
    /bin/bash -c "
    service apache2 start 2>/dev/null || true;
    service nginx start 2>/dev/null || true;
    service mariadb start 2>/dev/null || true;
    service mysql start 2>/dev/null || true;
    while true; do sleep 60; done
    "

if [ $? -ne 0 ]; then
    echo -e "\e[91m\n[X] Error al iniciar el contenedor. Revisa los logs de Docker.\e[0m"
    detener_y_eliminar_contenedor
    exit 1
fi

# 4. Obtener IP
IP_DOCKER=$(sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$CONTAINER_NAME" 2>/dev/null)

echo -e "\n\e[1;92m[✔] ¡Máquina vulnerable lista!\n\e[0m"
echo -e "\e[1;97m--------------------------------------------------------------------------------\e[0m"
echo -e "\e[1;97m  Contenedor cargado: ------------------------------>\e[1;92m $CONTAINER_NAME\e[0m"
echo -e "\e[1;97m  IP del laboratorio: ------------------------------>\e[1;96m $IP_DOCKER\e[0m"
echo -e "\e[1;97m--------------------------------------------------------------------------------\e[0m"
echo -e "\n\e[1;5m[Exit] Pulsa Control C para detener el contenedor de ${SCRIPT_NAME} y salir del programa.\n\e[0m"

# Mantener el script vivo
while true; do sleep 1; done
