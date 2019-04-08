#!/bin/bash



#Autor: Oscar Anadon O. - NIA: 760628

#CONOCER SI EL USUARIO ES PRIVILEGIADO
#envio la salida de estandar y de error
more /etc/shadow >/dev/null
if [ "$?" -eq "0" ]  ;then
	echo ok 1>/dev/null
else
	echo "Este script necesita privilegios de administracion"
	exit 1
fi

#NUMERO DE ARGUMENTOS
if [ "$#" != "2" ];then
	echo "Numero incorrecto de parametros"
	#exit 1
else
	fecha=$(date --date "+30 days" +%Y-%m-%d)
	#FALLO POR AQUI
	#OPCIONES SCRIPT
	if [ "$1" = "-a" ]; then
		
		while read line;do
		identificador=`echo $line|cut -d, -f1`
		pass=`echo $line|cut -d, -f2`
		nombre=`echo $line|cut -d, -f3`
		#compruebo que el usuario no existe
		#if [ -n "grep $identificador /etc/passwd" ];then
		#	echo el usuario $identificador ya existe
		#else	
			#FALLOFALLOFALLOFALLO
			#compruebo que los tres campos no son vacios
			if [ ! -z $identificador ] && [ ! -z $pass ] && [ ! -z $nombre ];then
				#creacion del usuario + constraseña
				groupadd $nombre 2>/dev/null
				#los ficheros de /etc/skel (skeleton) son copiados con la opcion -m
				useradd -c "$nombre" $identificador -g $nombre -m -u $((1815 + $((RANDOM)))) 2>/dev/null
				
				if [ $? -eq "0" ];then
					#permite acutalizar contraseñas de usuarios existentes
					echo "$identificador:$pass" | chpasswd
					
					#para cambiar la caducidad de la contraseña
					chage -M 30 $identificador
					#para darle sudo sin contraseña
					echo "$identificador ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
					usermod -G sudo $identificador
					echo "$nombre ha sido creado"
					#mkdir /var/mail/$identificador
				else 
					echo "El usuario $nombre ya existe"
				fi
			else
				echo "campo invalido";exit
			fi
		#fi
	done < $2
	elif [ "$1" = "-s" ];then
		#-p para crearlo de forma recursiva
		mkdir -p /extra/backup
		if [ $? -ne "0" ];then
			exit 1
		else
		while read line;do
		identificador=`echo $line|cut -d, -f1`
		pass=`echo $line|cut -d, -f2`
		nombre=`echo $line|cut -d, -f3`
			#compruebo que al menos existe un campo no vacio
			if [ -n $identificador ]; then
				#borro la carpeta home -Recursivamenteforzadamente OBSERVAR SIGNIFICADO PUNTO
				#no 
				tar -cf "/extra/backup/$identificador.tar" /home/$identificador 2> /dev/null
				#para comprobar que el backup se ha realizado correctamente
				if [ $? -eq 0 ];then
					#con -r eliminaria la carpeta mail y home, pero mail no existey salta error
					#para sacarlo de todos grupos pero que pasa con el creado
					#usermod -a $identificador
					#para que no me salte el aviso por el correo

					userdel $identificador -r 2>/dev/null #-r para borrar la carpeta home
					
					#para borrarlo del fichero sudoers
					sed -i /$identificador/d /etc/sudoers
				else
					echo -n
				fi
				
			else
				echo "por definir que pasa si al borrar no tiene ni un campo, no especifica"
			fi
		done < $2
		#echo borrado todo correctamente
		fi
		
	#no es ni -a ni -s
	else
		echo "Opcion invalida" 1>&2
	fi
	
fi









