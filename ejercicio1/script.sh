#!/bin/bash

# Autores del código:
# Melissa Danten - 326461
# Paulina Vazquez - 325917
# Francisco Zadikian - 303142

# definir colores según códigos de escape ANSI (https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux)
# se tiene que usar "-e" para que funcionen los colores con echo (activar backlash escapes)
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[1;35m'
NC='\033[0m' # sin color 'no colour'

# definir separador
SEP="${BLUE}------------------${NC}"

# declaramos variable afuera porque precisamos usar la variable en más de una función
usuario=""

tipos=("BASE" "LAYER" "SHADE" "DRY" "CONTRAST" "TECHNICAL" "TEXTURE" "MEDIUMS")

# se muestra el menu si el usuario inicio sesion correctamente
menu(){
	echo -e "${PURPLE}Menu Principal:${NC}"
	echo -e $SEP
	echo "1) Lista de usuarios registrados"
	echo "2) Dar de alta un usuario"
	echo "3) Cambiar contraseña"
	echo "4) Ingresar Producto"
	echo "5) Vender producto"
	echo "6) Filtro de productos"
	echo "7) Crear reporte de Pinturas"
	echo "8) Cerrar sesión"
	echo "9) Salir"
	echo -e $SEP
	echo -ne "${PURPLE}> ${NC}"
	read menuvalor
	if [ -z $menuvalor ]; then
		menu
	elif [ $menuvalor = 1 ]; then
		listaUsuarios
	elif [ $menuvalor = 2 ]; then
		altaUsuario
	elif [ $menuvalor = 3 ]; then
		cambiarContrasena
	elif [ $menuvalor = 4 ]; then
		ingresarProducto
	elif [ $menuvalor = 5 ]; then
		venderProducto
	elif [ $menuvalor = 6 ]; then
		filtrarProductos
	elif [ $menuvalor = 7 ]; then
		crearReportePinturas
	elif [ $menuvalor = 8 ]; then
		cerrarSesion
	elif [ $menuvalor = 9 ]; then
		exit		
	else
		echo -e "${RED}Opción inválida, intente nuevamente${NC}"
		menu
	fi
}

listaUsuarios() {
	echo -e $SEP
	echo -e "${PURPLE}Lista de usuarios:${NC}"
	archivo="./credenciales.txt"
	while IFS= read -r usua && IFS= read -r contra && IFS= read -r separador; do
                echo $usua
    done < "$archivo"
	echo -e $SEP
	menu
}

altaUsuario(){
	echo -e $SEP
	echo -n "Ingrese usuario (en caso de dejar en vacío, se vuelve al menu): "
	read user
	if [ -z $user ]; then
		echo -e $SEP
		menu
	fi
	archivo="./credenciales.txt"
	esta=0
	while IFS= read -r usua && IFS= read -r contra && IFS= read -r separador; do
		if [ $usua = $user ]; then
			esta=1
		fi
	done < "$archivo"
	if [ $esta = 1 ]; then
		echo -e "${RED}El usuario ya existe${NC}"
		altaUsuario
	else
		echo -n "Ingrese contraseña: "
		# "-s" esconde el input, echo porque salto de línea no sucede con "read -s"
		read -s pass
		echo -ne "\n"
		# si la contraseña está vacía, reintentar
		while [ -z $pass ]; do
			echo -e "${RED}La contraseña no debe estar vacía${NC}"
            echo -n "Ingrese contraseña: "
		    read -s pass
		    echo -ne "\n"
		done
		# encriptar contraseña usando el algoritmo SHA-512
		# "-n" omite la nueva línea después del echo
		# "sha512sum" encripta el string
		# awk '{print $1}' se queda con la primer parte del output (sha512sum devuelve la pass+" -")
		pass=$(echo -n "$pass" | sha512sum | awk '{print $1}')
		echo $user >> $archivo
		echo $pass >> $archivo
		echo "####" >> $archivo
		echo -e "${GREEN}Usuario registrado${NC}"
		echo -e $SEP
		menu
	fi
}

cambiarContrasena(){
    echo -e $SEP
	echo -n "Ingrese su contraseña actual (en caso de dejar en vacío, se vuelve al menu): "
	# "-s" esconde el input, echo porque salto de línea no sucede con "read -s"
	read -s passActual
	echo -ne "\n"

	if [ -z $passActual ]; then
		echo -e $SEP
		menu
	fi

    passActual=$(echo -n "$passActual" | sha512sum | awk '{print $1}')
    archivo="./credenciales.txt"
  	# verificar si la contraseña ingresada es igual a la contraseña dentro del txt que corresponde al usuario logeado.
	esta=0
	while IFS= read -r usua && IFS= read -r contra && IFS= read -r separador; do
		if [ $usuario = $usua ] && [ $passActual = $contra ]; then
			esta=1
		fi
	done < "$archivo"

    if [ $esta = 1 ]; then
		echo -n "Ingrese su nueva contraseña: "
        read -s passNueva
        echo -ne "\n"

        passNueva=$(echo -n "$passNueva" | sha512sum | awk '{print $1}')
        
		sed -i "/$usuario/{n;s/.*/$passNueva/}" "$archivo"
		echo -e "${GREEN}Contraseña cambiada exitosamente${NC}"
        echo -e $SEP
        menu
	else
		echo -e "${RED}Contraseña incorrecta${NC}"
		echo -n "¿Desea reintentar el cambio de contraseña? (S/N): "
		read reintentar
		# si el input del usuario en minúsculas es "s"
		if [ "${reintentar,,}" = "s" ]; then
			cambiarContrasena
		else
            echo -e $SEP
            menu
		fi
    fi
}

cerrarSesion(){
	usuario=""
	echo -e "${GREEN}Sesión cerrada correctamente${NC}"
	iniciarSesion
}

iniciarSesion(){
	echo -n "Ingrese el usuario: "
	read usuario

	while [[ -z $usuario ]] ; do
		echo -e "${RED}El usuario no puede estar vacío${NC}"
		echo -n "Ingrese el usuario: "
		read usuario
	done

	echo -n "Ingrese la contraseña: "
	# "-s" esconde el input, echo porque salto de línea no sucede con "read -s"
	read -s pass
	echo -ne "\n"

	while [[ -z $pass ]] ; do
		echo -e "${RED}La contraseña no puede estar vacía${NC}"
        echo -n "Ingrese la contraseña: "
        read -s pass
        echo -ne "\n"
	done

	# encriptar contraseña usando el algoritmo SHA-512
	# "-n" omite la nueva línea después del echo
	# "sha512sum" encripta el string
	# awk '{print $1}' se queda con la primer parte del output (sha512sum devuelve la pass+" -")
	pass=$(echo -n "$pass" | sha512sum | awk '{print $1}')
	archivo="./credenciales.txt"
	# si coincide que el usuario ingresado es igual a un usuario dentro del txt, y la contraseña ingresada es igual a la contraseña dentro del txt que corresponde al mismo usuario.
	esta=0
	while IFS= read -r usua && IFS= read -r contra && IFS= read -r separador; do
		if [ $usuario = $usua ] && [ $pass = $contra ]; then
			esta=1
		fi
	done < "$archivo"
	if [ $esta = 1 ]; then
		echo -e $SEP
		menu
	else
		echo -e "${RED}Usuario y/o contraseña incorrectos${NC}"
		echo -n "¿Desea reintentar el inicio de sesión? (S/N):"
		read reintentar
		# si el input del usuario en minúsculas es "s"
		if [ "${reintentar,,}" = "s" ]; then
			iniciarSesion
		else exit
		fi
	fi
}

es_entero() {
    [[ "$1" =~ ^-?[0-9]+$ ]]
}

ingresarProducto(){
	echo -e $SEP

	echo -e "Ingrese el código del producto (en caso de dejar en vacío, se vuelve al menu)"
	read cod

	if [[ -z $cod ]]; then
		echo -e $SEP
		menu
	fi

	echo -e "Ingrese el tipo del producto (en caso de dejar en vacío, se vuelve al menu)"
	read tipo

	if [[ -z $tipo ]]; then
		echo -e $SEP
		menu
	fi

	esta=0
	for i in "${tipos[@]}"; do
		if [ "${i,,}" = "${tipo,,}" ]; then
			esta=1
		fi
	done

    tipoSubstr="${tipo:0:3}"
	while [[ "${tipoSubstr,,}" != "${cod,,}" || $esta -eq 0 ]]; do
		echo -e "${RED}El tipo o código no es válido, intente nuevamente${NC}"
        ingresarProducto
	done

	echo -e "Ingrese el modelo del producto"
	read mod
	while [[ -z "$mod" ]]; do
		echo -e "${RED}El modelo no puede estar vacío, intente nuevamente${NC}"
		read mod
	done

	echo -e "Ingrese la descripción del producto"
	read desc
	while [[ -z "$desc" ]]; do
		echo -e "${RED}La descripción no puede estar vacía, intente nuevamente${NC}"
		read desc
	done

	echo -e "Ingrese la cantidad del producto"
	read cant
	while [ -z "$cant" ] || ! es_entero "$cant" || [ "$cant" -le 0 ]; do
		echo -e "${RED}La cantidad debe ser un entero mayor a 0, intente nuevamente${NC}"
		read cant
	done

	echo -e "Ingrese el precio del producto"
	read prec
	while [ -z "$prec" ] || ! es_entero "$prec" || [ "$prec" -le 0 ]; do
		echo -e "${RED}El precio debe ser un entero mayor a 0, intente nuevamente${NC}"
		read prec
	done	
	
	echo "${cod^^} - ${tipo,,} - $mod - $desc - $cant - \$$prec" >> ./lista_productos.txt

	echo -e "${GREEN}El producto fue ingresado correctamente${NC}"
	menu
}

venderProducto(){
	echo -e $SEP

    if [ -f "./venta_tmp.txt" ]; then
        rm "./venta_tmp.txt"
    fi

    resp="S"
	while [ "${resp,,}" = "s" ]; do
		echo "Pinturas disponibles para la venta:"
        echo -e $SEP
		echo -e "${PURPLE}Número - Tipo - Modelo - Precio${NC}"
		awk -F' - ' '{print NR" - "$2" - "$3" - "$6}' lista_productos.txt
        echo -e $SEP

		echo "Ingrese el número del producto que desea comprar:"
		read num
		while [ -z "$num" ] || ! es_entero "$num" || [ "$num" -le 0 ] || [ "$num" -gt "$(wc -l < ./lista_productos.txt)" ]; do
			echo -e "${RED}El número de producto debe ser un entero  [1, cantProductos], intente nuevamente${NC}"
			read num
		done

		echo "Ingrese cantidad"
		read cant

		cantidad=$(awk -F' - ' "NR==$num {print \$5}" lista_productos.txt)

		while [ -z "$cant" ] || ! es_entero "$cant" || [ "$cant" -le 0 ] || [ "$cant" -gt "$cantidad" ]; do
			echo -e "${RED}La cantidad de producto debe ser un entero [1, stock], intente nuevamente${NC}"
			read cant
		done

        # Ingresar compra al archivo temporal
		awk -F' - ' -v num="$num" -v cant="$cant" '
			NR == num {
				precio = substr($6, 2)
				total = cant * precio
				print $2 " - " $3 " - " cant " - $" total
			}
		' ./lista_productos.txt >> ./venta_tmp.txt
		

		# Restar cantidad del stock en la lista de productos
		cantidad_actual=$(sed -n "${num}s/.* - \([0-9]\+\) - \$[0-9]\+/\1/p" lista_productos.txt)

		nueva_cant=$((cantidad_actual - cant))

		sed -i "${num}s/\(.* - \)[0-9]\+\( - \$[0-9]\+\)/\1${nueva_cant}\2/" lista_productos.txt

        echo -e $SEP
		echo -e "${PURPLE}Resumen de su compra actual:${NC}"
		cat ./venta_tmp.txt
        echo -e $SEP

		echo "¿Desea comprar mas productos? (S/N)"
		read resp
	done

	echo -e "${GREEN}¡Compra realizada exitosamente!${NC}"

    echo -e $SEP
	echo -e "${PURPLE}Resumen final de su compra:${NC}"
	cat ./venta_tmp.txt
	
	echo -e "${PURPLE}Precio total de su compra:${NC}"
	awk -F' - ' '{
		total_prod = substr($4, 2)
		suma += total_prod
	} END {
		print "$" suma
	}' ./venta_tmp.txt
    echo -e $SEP

	rm ./venta_tmp.txt
	menu
}

filtrarProductos(){
	echo -e $SEP
	echo -e "Ingrese el tipo a filtrar, vacío para todos"
	read tipo
	if [[ -z "$tipo" ]]; then
        echo -e $SEP
        echo -e "${PURPLE}Productos disponibles:${NC}"
    	cat ./lista_productos.txt
        echo -e $SEP
        menu
	fi

	esta=0
	while [[ "$esta" -eq 0 ]]; do
		for i in "${tipos[@]}"; do
			if [ "${i,,}" = "${tipo,,}" ]; then
				esta=1
			fi
		done

		if [[ "$esta" -eq 0 ]]; then
			echo -e "${RED}El tipo ingresado no es valido, intente nuevamente${NC}"
			read tipo
            if [[ -z "$tipo" ]]; then
                echo -e $SEP
                echo -e "${PURPLE}Productos disponibles:${NC}"
    	        cat ./lista_productos.txt
                echo -e $SEP
                menu
	        fi
		fi
	done
	cod="${tipo:0:3}"
    echo -e $SEP
    echo -e "${PURPLE}Productos de tipo ${tipo}:${NC}"
	grep "^${cod^^}" ./lista_productos.txt
    echo -e $SEP
	menu
}

crearReportePinturas(){
	echo -e $SEP

    mkdir -p "./Datos"
	touch ./Datos/datos.csv

	datosCSV="./Datos/datos.csv"

	echo "Codigo,Tipo,Modelo,Descripcion,Cantidad,Precio" > "$datosCSV"

	awk -F' - ' '{print $1","$2","$3","$4","$5","$6}' ./lista_productos.txt >> "$datosCSV"

	echo -e "${GREEN}Reporte generado correctamente en ${NC}$(realpath $datosCSV)${GREEN} :${NC}"
	
	echo -e $SEP
	menu
}

iniciarSesion
