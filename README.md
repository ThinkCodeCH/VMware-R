Este script configura e instala los módulos necesarios para VMware Workstation en Linux, asegurando su compatibilidad con cualquier versión de kernel y simplificando la configuración de la primera instalación. Además, firma los módulos del kernel para evitar problemas de compatibilidad en sistemas con políticas de seguridad activas (Secure Boot).

Características
Configuración de módulos de VMware para cualquier versión de kernel.
Generación y firma de claves RSA para los módulos vmmon y vmnet.
Verificación de firma para asegurar que los módulos estén correctamente firmados.
Importación de claves en MOK para que el sistema confíe en los módulos firmados.
Detección automática de dependencias con instalación opcional.
Interfaz de menú interactivo para una experiencia más amigable.
Registro de operaciones en un archivo log (vmware_setup.log) para revisar el progreso y detectar posibles errores.
Requisitos
Permisos de root: Este script debe ejecutarse con permisos de root para aplicar cambios en el sistema.
Dependencias:
vmware-modconfig
openssl
mokutil
El script comprobará si estas dependencias están instaladas y, en caso contrario, ofrecerá la opción de instalarlas automáticamente.
Instalación y Uso
Descargar el Script:

Descarga el script y asegúrate de darle permisos de ejecución:
bash
Copiar código
chmod +x script.sh
Ejecutar el Script:

Inicia el script como root:
bash
Copiar código
sudo ./script.sh
Navegar el Menú:

Al ejecutar el script, verás un menú con las siguientes opciones:
1) Instalar dependencias y configurar módulos: Instala las dependencias necesarias y configura VMware Workstation.
2) Generar y firmar claves RSA para módulos VMware: Genera claves y firma los módulos vmmon y vmnet.
3) Verificar firma de los módulos: Verifica que las firmas se hayan aplicado correctamente.
4) Importar clave generada en MOK: Importa la clave generada para que el sistema confíe en los módulos firmados.
5) Salir: Salir del script.
Reinicio y Finalización:

Una vez que todos los pasos estén completados, se requiere un reinicio del sistema.
Al reiniciar, verás una pantalla azul de Secure Boot. Sigue estos pasos:
Selecciona Enroll MOK
Luego Continuar
Elige Sí
Ingresa la contraseña que configuraste en el script
Selecciona OK o Reboot
Notas
Archivos Generados:

VMWARE1X.priv y VMWARE1X.der son las claves RSA generadas para firmar los módulos de VMware.
vmware_setup.log contiene un registro detallado de las operaciones realizadas por el script.
Compatibilidad: Este script está diseñado para sistemas Linux con VMware Workstation y Secure Boot activado.

Ejemplo de Uso
bash
Copiar código
# Ejecutar el script como root
sudo ./script.sh

# Seleccionar las opciones en el menú interactivo
# Seguir las instrucciones de la pantalla azul de Secure Boot tras el reinicio
Autor
Script originalmente creado y mejorado por Dr. Zurich y colaboradores.

Contribuciones
Las contribuciones son bienvenidas. Si deseas mejorar el script, realiza un pull request o contacta al autor.

Licencia
Este proyecto está bajo la Licencia MIT.
