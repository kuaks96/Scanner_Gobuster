#!/bin/bash
#Author almy
# Función para solicitar entrada del usuario
function solicitar_entrada {
    read -p "$1" valor
    while [[ -z $valor ]]; do
        echo "El valor no puede estar vacío. Intenta nuevamente."
        read -p "$1" valor
    done
    echo "$valor"
}

# Función para ejecutar gobuster con los parámetros proporcionados
function ejecutar_gobuster {
    local comando=$1
    local url=$2
    local wordlist=$3
    local output_dir=$4

    mkdir -p "$output_dir"
    $comando -u "$url" -w "$wordlist" -o "$output_dir/gobuster_results.txt"
}

# Verificar si gobuster está instalado
if ! command -v gobuster &> /dev/null; then
    echo "La herramienta 'gobuster' no está instalada. Instalando..."
    sudo apt update
    sudo apt install gobuster -y
    if [ $? -ne 0 ]; then
        echo "Error al instalar gobuster. Asegúrate de tener los permisos adecuados o instálalo manualmente."
        exit 1
    fi
fi

# Pide al usuario que elija el tipo de escaneo
echo "Elige el tipo de escaneo:"
echo "1. Escaneo de directorios (gobuster dir)"
echo "2. Escaneo de parámetros en URL (gobuster fuzz)"
echo "3. Escaneo de subdominios (gobuster dns)"
read -p "Ingresa el número correspondiente: " opcion

case $opcion in
    1)
        # Escaneo de directorios
        url=$(solicitar_entrada "Ingresa la URL del sitio web: ")
        wordlist=$(solicitar_entrada "Ingresa la ruta de la wordlist: ")
        output_dir=$(solicitar_entrada "Ingresa el directorio de salida para los resultados: ")
        ejecutar_gobuster "gobuster dir -c 200" "$url" "$wordlist" "$output_dir"
        ;;
    2)
        # Escaneo de parámetros en URL
        url=$(solicitar_entrada "Ingresa la URL con FUZZ: ")
        wordlist=$(solicitar_entrada "Ingresa la ruta de la wordlist de parámetros: ")
        output_dir=$(solicitar_entrada "Ingresa el directorio de salida para los resultados: ")
        ejecutar_gobuster "gobuster fuzz" "$url" "$wordlist" "$output_dir"
        ;;
    3)
        # Escaneo de subdominios
        domain=$(solicitar_entrada "Ingresa el dominio para el escaneo de subdominios: ")
        wordlist=$(solicitar_entrada "Ingresa la ruta de la wordlist de subdominios: ")
        output_dir=$(solicitar_entrada "Ingresa el directorio de salida para los resultados: ")
        ejecutar_gobuster "gobuster dns -d" "$domain" "$wordlist" "$output_dir"
        ;;
    *)
        echo "Opción no válida. Saliendo."
        exit 1
        ;;
esac
