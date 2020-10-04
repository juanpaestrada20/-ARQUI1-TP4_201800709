;===============SECCION DE MACROS ===========================
include p4mac.asm
;================= DECLARACION TIPO DE EJECUTABLE ============
.model small 
.stack 100h 
.data
	;================ SECCION DE DATOS ========================
	encab           db 0ah,0dh, 'UNIVERSIDAD DE SAN CARLOS DE GUATEMALA', 0ah,0dh,'FACULTAD DE INGENIERIA',0ah,0dh,'CIENCIAS Y SISTEMAS',0ah,0dh,'ARQUITECTURA DE COMPUTADORES 1',0ah,0dh,'$'
	datos           db 0ah,0dh, 'NOMBRE: JUAN PABLO ESTRADA ALEMAN', 0ah,0dh,'CARNET: 201800709',0ah,0dh,'SECCION: A',0ah,0dh,'$'
	men             db 0ah,0dh, '1) CARGAR', 0ah,0dh,'2) CONSOLA',0ah,0dh,'3) SALIR',0ah,0dh,'$'
	salto           db 0ah, 0dh , '$'
	
	resultados      db 1000 dup ('$')
	padre           db 1000 dup ('$')
	operadores      db 1000 dup ('$')
	operandos       db 3000 dup ('$')
	auxInt          db 50 dup('$')
	auxCadena       db 100 dup('$')                                                                                                                                                          	;
	
	div1            db 'div', '$'                                                                                                                                                            	; salto de linea
	div2            db '/', '$'                                                                                                                                                              	; salto de linea
	mul1            db 'mul', '$'                                                                                                                                                            	; salto de linea
	mul2            db '*', '$'                                                                                                                                                              	; salto de linea
	res1            db 'sub', '$'                                                                                                                                                            	; salto de linea
	res2            db '-', '$'                                                                                                                                                              	; salto de linea
	sum1            db 'sum', '$'                                                                                                                                                            	; salto de linea
	sum2            db '+', '$'
	numero          db '#',  '$'                                                                                                                                                             	; salto de linea
	id              db 'id',  '$'                                                                                                                                                            	; salto de linea

	fecha           db "00/00/0000",0dh, 0ah
	hora            db "00:00:00", 0dh, 0ah

	msm1            db 0ah,0dh,'INGRESE RUTA',0ah,0dh,'$'
	msm2            db 0ah,0dh,'Archivo leido exitosamente!',0ah,0dh,'$'
	msm3            db 0ah,0dh,'Fin de analisis',0ah,0dh,'$'
	msm4            db 0ah,0dh,'GUARDANDO ARCHIVO',0ah,0dh,'$'
	msmError1       db 0ah,0dh,'Error al abrir archivo','$'
	msmError2       db 0ah,0dh,'Error al leer archivo','$'
	msmError3       db 0ah,0dh,'Error al crear archivo','$'
	msmError4       db 0ah,0dh,'Error al Escribir archivo','$'
	msmError5       db 0ah,0dh,'Error al Formato de movimiento','$'
	msmRegreso      db 0ah,0dh,'Regresando al Menu','$'
	msmName         db 0ah,0dh,'Ingrese nombre para guardar:','$'
	rutaTab         db 100 dup('0')
	rutaArchivo     db 100 dup('$')
	bufferLectura   db 3000 dup('$')
	bufferEscritura db 100 dup('$')
	handleFichero   dw ?

	entra           db 0ah,0dh,'entra','$'
	num             db 0ah,0dh,'num','$'
	ide             db 0ah,0dh,'id','$'
.code ;segmento de código
;================== SECCION DE CODIGO ===========================
	main proc 
			MOV ax, @data ; obtenemos lo que esta en el segmento de data y lo movemos a ax
			MOV ds, ax  ; enviamos toda la data a ds y asi se puede acceder a las variables

		Menu:
			print encab
			print datos
			print men
			getChar
			cmp al,49
			je LeerJson
			cmp al,50
			je Consola
			cmp al,51
			je Salir
			jmp Menu
		LeerJson:
			print msm1
			getRuta rutaArchivo
			openFile rutaArchivo,handleFichero
			readFile SIZEOF bufferLectura,bufferLectura,handleFichero
			closeFile handleFichero
			print msm2
			analyzeJson bufferLectura, SIZEOF bufferLectura
			jmp Menu
		Consola:
		Salir: 
			MOV ah,4ch 
			int 21h
		ErrorCrear:
	    	print msmError3
	    	getChar
	    	jmp Menu
		ErrorEscribir:
	    	print msmError4
	    	getChar
	    	jmp Menu
		ErrorAbrir:
	    	print msmError1
	    	getChar
	    	jmp Menu
		ErrorLeer:
	    	print msmError2
	    	getChar
	    	jmp Menu
	main endp
;================ FIN DE SECCION DE CODIGO ========================
end