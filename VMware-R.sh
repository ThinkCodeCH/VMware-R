#!/bin/bash

# Autor: ThinkCode (Zurich)
# Descripción: Este script configura VMware Workstation para cualquier versión de kernel en Linux,
# facilitando la instalación inicial y asegurando la compatibilidad con módulos firmados.

# Variables
filename_key="vmware_key"
log_file="vmware_setup.log"
kernel_version=$(uname -r)

# Función para mostrar un título con bordes decorativos
function titulo() {
    echo -e "\n\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m"
    echo ""
    echo -e "       🌟 $1 🌟"
    echo ""    
    echo -e "\e[1;34m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\e[0m\n"
}

# Verificar si se ejecuta como root
if [[ $EUID -ne 0 ]]; then
   echo -e "\e[1;31mEste script debe ejecutarse como root. Por favor, utiliza sudo.\e[0m" 
   exit 1
fi

# Función para verificar dependencias
function verificar_dependencias() {
    dependencias=("vmware-modconfig" "openssl" "mokutil")
    for dep in "${dependencias[@]}"; do
        if ! command -v $dep &> /dev/null; then
            echo -e "\e[1;31mDependencia '$dep' no encontrada. ¿Deseas instalarla? (s/n): \e[0m"
            read -p "" resp
            if [[ "$resp" == "s" ]]; then
                sudo apt-get install -y $dep || { echo "Error al instalar $dep"; exit 1; }
            else
                echo -e "\e[1;31mEl script no puede continuar sin $dep. Saliendo...\e[0m"
                exit 1
            fi
        fi
    done
}

# Mostrar menú interactivo
function menu() {
    titulo "Bienvenido al instalador y configurador de módulos de VMware para Linux"
    echo -e "Seleccione una opción:\n"
    echo -e "1) Instalar dependencias y configurar módulos"
    echo -e "2) Generar y firmar claves RSA para módulos VMware"
    echo -e "3) Verificar firma de los módulos"
    echo -e "4) Importar clave generada en MOK"
    echo -e "5) Salir"
    read -p "Seleccione una opción (1-5): " opcion
}

# Función para instalar y configurar módulos
function instalar_configuracion() {
    titulo "Instalando dependencias y configuraciones necesarias"
    sudo vmware-modconfig --console --install-all | tee -a "$log_file"
    echo -e "\e[1;32mDependencias y configuración completadas.\e[0m"
}

# Función para generar claves RSA y firmar módulos
function generar_firmas() {
    titulo "Generando claves RSA de 2048 bits para firmar los módulos"
    openssl req -new -x509 -newkey rsa:2048 -keyout VMWARE1X.priv -outform DER -out VMWARE1X.der -nodes -days 36500 -subj "/CN=VMWARE/" | tee -a "$log_file"
    echo -e "\e[1;36m🔏 Firmando el módulo vmmon...\e[0m"
    sudo /usr/src/linux-headers-$kernel_version/scripts/sign-file sha256 ./VMWARE1X.priv ./VMWARE1X.der $(modinfo -n vmmon) | tee -a "$log_file"
    echo -e "\e[1;36m🔏 Firmando el módulo vmnet...\e[0m"
    sudo /usr/src/linux-headers-$kernel_version/scripts/sign-file sha256 ./VMWARE1X.priv ./VMWARE1X.der $(modinfo -n vmnet) | tee -a "$log_file"
}

# Función para verificar la firma de los módulos
function verificar_firma() {
    titulo "Verificando que las firmas se hayan aplicado correctamente"
    if tail $(modinfo -n vmmon) | grep -q "La firma ha sido añadida exitosamente"; then
        echo -e "\e[1;32m✅ Firma de vmmon aplicada exitosamente.\e[0m"
    else
        echo -e "\e[1;31m❌ La firma de vmmon no se aplicó correctamente.\e[0m"
    fi
    if tail $(modinfo -n vmnet) | grep -q "La firma ha sido añadida exitosamente"; then
        echo -e "\e[1;32m✅ Firma de vmnet aplicada exitosamente.\e[0m"
    else
        echo -e "\e[1;31m❌ La firma de vmnet no se aplicó correctamente.\e[0m"
    fi
}

# Función para importar clave en MOK
function importar_clave() {
    titulo "Importando la clave generada en MOK para que sea de confianza"
    sudo mokutil --import VMWARE1X.der | tee -a "$log_file"
    echo -e "\e[1;32m🔑 La clave se ha importado en MOK exitosamente. Recuerda reiniciar y seguir los pasos en pantalla.\e[0m"
}

# Bucle principal del menú
while true; do
    menu
    case $opcion in
        1) instalar_configuracion ;;
        2) generar_firmas ;;
        3) verificar_firma ;;
        4) importar_clave ;;
        5) echo -e "\e[1;32mSaliendo... ¡Gracias por usar el script!\e[0m"; break ;;
        *) echo -e "\e[1;31mOpción inválida. Por favor, seleccione entre 1 y 5.\e[0m" ;;
    esac
    echo -e "\n\e[1;34mPresiona Enter para regresar al menú principal...\e[0m"
    read -r
done
