; imprimir cadena;
; se recibe el texto que se imprimira
print macro cadena
	         LOCAL ETIQUETA
	ETIQUETA:
	         MOV   ah,09h    	; instruccion de impresion por la interrupcion 21h
	         MOV   dx,@data
	         MOV   ds,dx
	         lea   dx, cadena	; imprimimos la cadena
	         int   21h       	; fin de lal operacion
endm
 
; obtener char
; se utiliza para una pausa y que el usuario pueda leer el texto
getChar macro
	        mov ah,01h
	        int 21h
endm

; macro para obtener la ruta
getRuta macro buffer
	        LOCAL   INICIO,FIN
	        xor     si,si         	; limpiamos el registro si
	INICIO: 
	        getChar               	; obtenemos letra
	        cmp     al,0dh        	; si enter terminamos
	        je      FIN
	        mov     buffer[si],al 	; concatenamos letra ingresada
	        inc     si
	        jmp     INICIO
	FIN:    
	        mov     buffer[si],00h	; finalizamos de obtener la rua
endm

; Crea el archivo
; buffer es el nombre del archivo
; handle es el manejador del archivo
createFile macro buffer, handle
	           mov ah,3ch    	; genera el archivo
	           mov cx,00h    	; limpia cx
	           lea dx,buffer 	; le pone nombre al archivo creado
	           int 21h       	; Finaliza el proceso
	           mov handle,ax 	;
	           jc  ErrorCrear	; error por si no se crea el archivo
endm

; Escritura de archivos
; numbytes es el tamaño de la cadena que queremos escribir
; buffer es la cadena que queremos escribir
; handle es el manejador de archivos
writeFile macro numbytes, buffer, handle
	          mov ah, 40h      	; Opercion escritura de archivo
	          mov bx,handle    	; a bx le colocamos el manejador
	          mov cx, numbytes 	; colocamos de contador el tamaño de lo que se escribira
	          lea dx,buffer    	; lo guardamos en dx
	          int 21h          	; fin de opoeracion de escritura
	          jc  ErrorEscribir	; Error por si no se puede escribir en el archivo
endm

; Abre archivos
; ruta es la ruta del archivo que queramos abrir
; handle es para el manejador de archivos del programa
openFile macro ruta, handle
	         mov ah,3dh    	; operacion para abrir archivos
	         mov al,10b    	; operacion de escritura
	         lea dx,ruta   	; obtiene lo que tiene el archivo
	         int 21h       	; fin de operacion
	         mov handle,ax 	; limpia el handle
	         jc  ErrorAbrir	; error por si no puede abrir el archivo
endm

; Cerrar archivo
; handle es el manejador del archivo
closeFile macro handle
	          mov ah,3eh   	; Operacion de cierre de un archivo abierto
	          mov handle,bx	; limpiar el manejador
	          int 21h      	; Fin de operacion
endm

; Leer Archivo
; numbytes -> tamaño del archivo
; buffer -> donde se almacenara lo del archivo
; handle -> manejador de archivos
readFile macro numbytes,buffer,handle
	         mov ah,3fh     	; Lectura de archivo
	         mov bx,handle  	; utilizar manejador
	         mov cx,numbytes	; tamaño del archivo
	         lea dx,buffer  	; lo leido lo envia a dx
	         int 21h        	; fin de operacion
	         jc  ErrorLeer  	; mensaje de error
endm

; Limpiar variables
; value -> variable a limpiar
; numBytes -> tamaño variable 
clean macro value, numBytes
	           local       RepeatLoop
	           pushRecords
	           xor         si, si
	           xor         cx, cx
	           mov         cx, numBytes
	RepeatLoop:
	           mov         value[si], '$'
	           inc         si
	           Loop        RepeatLoop
	           popRecords
endm

; Analizador de archivo JSON
analyzeJson macro buffer, size
	            LOCAL       INICIO,RECORRIDO, ACTIVACION, CONTAR, DESCONTAR, CADENA , OPERACION, OPERADOR,INCREMENTAR, FIN
	; limpiamos nuestros arreglos
	            clean       resultados, SIZEOF resultados
	            clean       operadores, SIZEOF operadores
	            clean       operandos, SIZEOF operandos
	            clean       auxInt, SIZEOF auxInt
	            clean       auxCadena, SIZEOF auxCadena
	            clean       padre, SIZEOF padre

	INICIO:     
	            xor         si, si
	            xor         ax, ax
	            xor         cx, cx
	            xor         bx, bx
	            xor         di, di
	RECORRIDO:  
	            cmp         si, size                                                                                      	; si llegamos al tamaño del archivo finalizamos
	            je          FIN
	            mov         bl, buffer[si]                                                                                	; caracter al registro bl
	            cmp         bl, '$'                                                                                       	; fin de cadena
	            je          FIN
	            cmp         bl, '"'
	            je          CADENA
	            cmp         bl, '['
	            je          ACTIVACION
	            cmp         bl, '{'
	            je          CONTAR
	            cmp         bl, '}'
	            je          OPERAR

	            jmp         INCREMENTAR

	ACTIVACION: 
	            push        si
	            saveOnArray operandos, padre
	            clean       operandos, SIZEOF operandos
	            pop         si
	            jmp         INCREMENTAR

	CONTAR:     
	
	            inc         cx
	            jmp         INCREMENTAR

	DESCONTAR:  
	            dec         cx
	            jmp         OPERAR

	CADENA:     
	            inc         si
	            dec         cx
	            mov         bl, buffer[si]
	            cmp         bl, '"'
	            je          OPERACION
	            mov         auxCadena[di], bl
	            inc         di
	            jmp         CADENA

	OPERACION:  
	            push        si
	            push        ax

	            changeWord  auxCadena

	            mov         auxCadena[di], '%'
	            xor         di, di

				
	            saveOnArray auxCadena, operandos
	            xor         di, di

	            pop         ax
	            pop         si

	            getNumber   auxCadena, buffer, operandos
	            xor         di, di

	            clean       auxCadena, SIZEOF auxCadena
	            jmp         INCREMENTAR

	OPERAR:     
	            xor         cx, cx
	            mov         cx, 0
	            print       operandos
	            getChar

	INCREMENTAR:
	            inc         si
	            jmp         RECORRIDO
	
	FIN:        
	            print       msm3

endm

;gaurdar en un arreglo
saveOnArray macro auxCadena, array
	            LOCAL ASIGNACION, FIN, POSICION
	            xor   si, si
	            xor   di, di
				
	POSICION:   
	            mov   bl, array[di]            	; caracter al registro bl
	            cmp   bl, '$'                  	; fin de cadena
	            je    ASIGNACION
	            inc   di
	            jmp   POSICION

	ASIGNACION: 
	            mov   bl, auxCadena[si]        	; caracter al registro bl
	            cmp   bl, '$'                  	; fin de cadena
	            je    FIN
	            mov   array[di], bl
	            inc   di
	            inc   si
	            jmp   ASIGNACION

	FIN:        
endm


getNumber macro auxCadena, buffer, array
	              LOCAL COMPARACION, FIN, DOSPUNTOS, BUSCAR, POSICION, COMPARACION2, NUMERO, IDENTIFICADOR, AUXILIAR, AUXILIAR2
	              xor   di, di
	COMPARACION:  
	              cmp   auxCadena, '#'
	              je    DOSPUNTOS
	;cmp     auxCadena, 'id'
	;je      DOSPUNTOS
	              jne   FIN
	DOSPUNTOS:    
	              mov   bl, buffer[si]                                                                                         	; caracter al registro bl
	              cmp   bl, ':'                                                                                                	; fin de cadena
	              je    BUSCAR
	              inc   si
	              jmp   DOSPUNTOS

	BUSCAR:       
	              inc   si
	              mov   bl, buffer[si]                                                                                         	; caracter al registro bl
	              cmp   bl, 09h                                                                                                	; fin de cadena
	              je    BUSCAR
	              mov   bl, buffer[si]                                                                                         	; caracter al registro bl
	              cmp   bl, 20h                                                                                                	; fin de cadena
	              je    BUSCAR
	              jmp   POSICION

	POSICION:     
	              mov   bl, array[di]                                                                                          	; caracter al registro bl
	              cmp   bl, '$'                                                                                                	; fin de cadena
	              je    COMPARACION2
	              inc   di
	              jmp   POSICION

	COMPARACION2: 
	              cmp   auxCadena, '#'
	              je    AUXILIAR
	;jne   IDENTIFICADOR

	AUXILIAR:     
	              dec   di
	              dec   di
	              jmp   NUMERO


	NUMERO:       
	              mov   bl, buffer[si]                                                                                         	; caracter al registro bl
	              cmp   bl, 09h                                                                                                	; fin de cadena
	              je    AUXILIAR2
	              cmp   bl, 20h                                                                                                	; fin de cadena
	              je    AUXILIAR2
	              cmp   bl, 0ah                                                                                                	; fin de cadena
	              je    AUXILIAR2
	              cmp   bl, ','                                                                                                	; fin de cadena
	              je    AUXILIAR2
	              mov   array[di], bl
	              inc   di
	              inc   si
	              jmp   NUMERO

	AUXILIAR2:    
	              mov   array[di], '%'
	              JMP   FIN

	IDENTIFICADOR:
	FIN:          
endm

changeWord macro cadena
	               LOCAL VERIFICACION, MULITPLICACION, FIN, FIN2
	               push  di
	               xor   si, si
	               xor   di, di
	VERIFICACION:  
	               mov   cx, 4                                  	; contador de los datos a comparar
	               lea   si, mul1
	               lea   di, cadena
	               repe  cmpsb
	               je    MULTIPLICACION
	               jmp   FIN

	MULTIPLICACION:
	               clean cadena, SIZEOF cadena
	               xor   di, di
	               mov   bl, '*'
	               mov   cadena[di], bl
	               inc   di
	               jmp   FIN2


	FIN:           
	               pop   di
	               jmp   FIN2

	FIN2:          

endm








; guardar los registros que tenemos
; este macro se utilizara al momento de hacer 
; algun analisis y no perdamos los datos ya 
; almacenados
pushRecords macro
	            push ax
	            push bx
	            push cx
	            push dx
	            push si
	            push di
endm

; sacar los registros que habiamos guarado
popRecords macro
	           pop di
	           pop si
	           pop dx
	           pop cx
	           pop bx
	           pop ax
endm

; Obtener fecha
; buffer es donde se almacenara 
getFecha macro buffer
	         xor ax, ax         	; limpiar el registro ax
	         xor bx, bx         	; limpiar el registro bx
	         mov ah, 2ah        	; operacion para obtener fecha
	         int 21h            	; fin de operacion

	         mov di,0           	; limpiar el registro di
	         mov al,dl          	; trnas
	         bcd buffer

	         inc di
	         mov al, dh
	         bcd buffer

	         inc di
	         mov buffer[di], 32h
	         inc di
	         mov buffer[di], 30h
	         inc di
	         mov buffer[di], 32h
	         inc di
	         mov buffer[di], 30h

endm

getHora macro buffer
	        xor ax, ax
	        xor bx, bx
	        mov ah, 2ch
	        int 21h

	        mov di,0
	        mov al, ch
	        bcd buffer

	        inc di
	        mov al, cl
	        bcd buffer

	        inc di
	        mov al, dh
	        bcd buffer
	
endm

bcd macro entrada
	    push dx
	    xor  dx,dx
	    mov  dl,al
	    xor  ax,ax
	    mov  bl,0ah
	    mov  al,dl
	    div  bl
	    push ax
	    add  al,30h
	    mov  entrada[di], al
	    inc  di

	    pop  ax
	    add  ah,30h
	    mov  entrada[di], ah
	    inc  di
	    pop  dx

endm