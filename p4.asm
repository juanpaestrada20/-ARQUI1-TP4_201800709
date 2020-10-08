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
	operandos       db 3000 dup ('$')
	operador        db 4 dup ('$')
	auxInt1         db 100 dup('$')
	auxInt2         db 100 dup('$')
	auxCadena       db 100 dup('$')                                                                                                                                                          	;
	auxGiro         db 4 dup('$')
	num1            db 100 dup('$')                                                                                                                                                          	;
	num2            db 100 dup('$')                                                                                                                                                          	;
	resultado       db 100 dup('$')                                                                                                                                                          	;
	resultadoAux    db 100 dup('$')
	idRes           db 100 dup('$')                                                                                                                                                          	;
	mediaVal        db 100 dup('$')                                                                                                                                                          	;
	modaVal         db 100 dup('$')                                                                                                                                                          	;
	noHay           db '"No hay"'                                                                                                                                                            	;
	medianaVal      db 100 dup('$')                                                                                                                                                          	;
	menorVal        db 100 dup('$')                                                                                                                                                          	;
	mayorVal        db 100 dup('$')                                                                                                                                                          	;
	aux             db 5 dup('$')                                                                                                                                                            	;
	d               db 2 dup('$')                                                                                                                                                            	;
	m               db 2 dup('$')                                                                                                                                                            	;
	a               db 4 dup('$')                                                                                                                                                            	;
	h               db 2 dup('$')                                                                                                                                                            	;
	min             db 2 dup('$')                                                                                                                                                            	;
	s               db 2 dup('$')                                                                                                                                                            	;
	
	div1            db 'div', '$'                                                                                                                                                            	; salto de linea
	div2            db '/', '$'                                                                                                                                                              	; salto de linea
	mul1            db 'mul', '$'                                                                                                                                                            	; salto de linea
	mul2            db '*', '$'                                                                                                                                                              	; salto de linea
	res1            db 'sub', '$'                                                                                                                                                            	; salto de linea
	res2            db '-', '$'                                                                                                                                                              	; salto de linea
	sum1            db 'add', '$'                                                                                                                                                            	; salto de linea
	sum2            db '+', '$'
	numero          db '#', '$'                                                                                                                                                              	; salto de linea
	id              db 'id', '$'
	; salto de linea
	console         db 0ah, 0dh, '============== CONSOLA ==============', 0ah, 0dh, '$'                                                                                                      	; salto de linea
	entrada         db '>> ', '$'                                                                                                                                                            	; salto de linea
	comando         db 100 dup('$')
	txtShow         db 'show', '$'
	txtMedia        db 'media', '$'
	txtMediana      db 'mediana', '$'
	txtModa         db 'moda', '$'
	txtMayor        db 'mayor', '$'
	txtMenor        db 'menor', '$'
	txtExit         db 'exit', '$'
	notYet          db 'Metodo no implementado', '$'


	date            db '00/00/0000'
	hour            db '00:00:00'

	msm1            db 0ah,0dh,'INGRESE RUTA: ',0ah,0dh,'$'
	msm2            db 0ah,0dh,'Archivo leido exitosamente!',0ah,0dh,'$'
	msm3            db 0ah,0dh,'Fin de analisis',0ah,0dh,'$'
	msm4            db 0ah,0dh,'Creando Reporte JSON',0ah,0dh,'$'
	msm5            db 0ah,0dh,'Reporte generado exitosamente!',0ah,0dh,'$'
	msm6            db 0ah,0dh,'Regresando al Menu','$'
	msmError1       db 0ah,0dh,'Error al abrir archivo','$'
	msmError2       db 0ah,0dh,'Error al leer archivo','$'
	msmError3       db 0ah,0dh,'Error al crear archivo','$'
	msmError4       db 0ah,0dh,'Error al escribir archivo','$'
	msmError5       db 0ah,0dh,'Comando no reconocido','$'
	rutaArchivo     db 100 dup('$')
	bufferLectura   db 3000 dup('$')
	bufferEscritura db 100 dup('$')
	handleFichero   dw ?

	; ============================ VARIABLES REPORTE ============================
	llaveAbre       db '{' , 0ah, 0dh
	llaveCierra     db '}' , 0ah, 0dh
	llaveCierraComa db '},' , 0ah, 0dh
	corcheteAbre    db '[' , 0ah, 0dh
	corcheteCierra  db ']' , 0ah, 0dh
	comilla         db '"'
	coma            db ','
	puntos          db ':'
	tabulacion1     db 09h
	tabulacion2     db 09h, 09h
	tabulacion3     db 09h, 09h, 09h
	tabulacion4     db 09h, 09h, 09h, 09h
	reporte         db '"Reporte": ', 0ah, 0dh
	alumno          db '"Alumno": ', 0ah, 0dh
	nombre          db '"Nombre": "Juan Pablo Estrada Aleman",', 0ah, 0dh
	carnet          db '"Carnet": "201800708",', 0ah, 0dh
	seccion         db '"Seccion": "A",', 0ah, 0dh
	curso           db '"Curso": "Arquitectura de Computadores y Ensambladores 1"', 0ah, 0dh
	fecha           db '"Fecha": ', 0ah, 0dh
	dia             db '"Dia": '
	mes             db '"Mes": '
	anio            db '"Año": '
	hora1           db '"Hora": ', 0ah, 0dh
	hora2           db '"Hora": '
	minutos         db '"Minutos": '
	segundos        db '"Segundos": '
	resultadosJson  db '"Resultados": ', 0ah, 0dh
	media           db '"Media": '
	mediana         db '"Mediana": '
	moda            db '"Moda": '
	menor           db '"Menor": '
	mayor           db '"Mayor": '
	saltoLinea      db 0ah, 0dh
	
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
			clean bufferLectura, SIZEOF bufferLectura
			clean rutaArchivo, SIZEOF rutaArchivo
			jmp Menu
		Consola:
			print console
			jmp Comandos
		Comandos:
			clean comando, SIZEOF comando
			print entrada
			getText comando
			compareComando comando
			jmp Comandos
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