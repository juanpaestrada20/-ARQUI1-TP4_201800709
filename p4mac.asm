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
	            LOCAL                   INICIO,RECORRIDO, ACTIVACION, CONTAR, DESCONTAR, CADENA , OPERACION, OPERADOR,INCREMENTAR, FIN
	; limpiamos nuestros arreglos
	            clean                   resultados, SIZEOF resultados
	            clean                   padre, SIZEOF padre
	            clean                   operandos, SIZEOF operandos
	;clean       operador, SIZEOF operador
	            clean                   auxInt1, SIZEOF auxInt1
	            clean                   auxInt2, SIZEOF auxInt2
	            clean                   auxCadena, SIZEOF auxCadena
	            clean                   auxGiro, SIZEOF auxGiro

	INICIO:     
	            xor                     si, si
	            xor                     ax, ax
	            xor                     cx, cx
	            xor                     bx, bx
	            xor                     di, di
	            jmp                     RECORRIDO

	RECORRIDO:  
	            cmp                     si, size                                                                                      	; si llegamos al tamaño del archivo finalizamos
	            je                      FIN
	            mov                     bl, buffer[si]                                                                                	; caracter al registro bl
	            cmp                     bl, '$'                                                                                       	; fin de cadena
	            je                      FIN
	            cmp                     bl, '"'
	            je                      CADENA
	            cmp                     bl, '['
	            je                      ACTIVACION
	            cmp                     bl, '{'
	            je                      CONTAR
	            cmp                     bl, '}'
	            je                      OPERAR
	            cmp                     bl, ']'
	            je                      FIN

	            jmp                     INCREMENTAR

	ACTIVACION: 
	            push                    si
	            saveOnArray             operandos, padre
	            clean                   operandos, SIZEOF operandos
	            xor                     di, di
	            pop                     si
	            jmp                     INCREMENTAR

	CONTAR:     
	
	            inc                     cx
	            jmp                     INCREMENTAR

	DESCONTAR:  
	            dec                     cx
	            jmp                     OPERAR

	CADENA:     
	            inc                     si
	            mov                     bl, buffer[si]
	            cmp                     bl, '"'
	            je                      OPERACION
	            mov                     auxCadena[di], bl
	            inc                     di
	            jmp                     CADENA

	OPERACION:  
	            push                    si
	            push                    ax
	            mov                     auxCadena[di], '%'
	            xor                     di, di

	            saveOnArray             auxCadena, operandos
	            xor                     di, di
	            pop                     ax
	            pop                     si

	            getNumber               auxCadena, buffer, operandos
	            xor                     di, di

	            clean                   auxCadena, SIZEOF auxCadena
	            jmp                     INCREMENTAR

	OPERAR:     
	            xor                     cx, cx
	            mov                     cx, 0
	            getValues
	            pushRecords
	            realizarOperacion
	            saveOnArray             resultado, operandos
	            popRecords
	            verificarFinalOperacion buffer, resultado
	            jmp                     INCREMENTAR

	INCREMENTAR:
	            inc                     si
	            jmp                     RECORRIDO
	
	FIN:        
	            print                   msm3
	            print                   salto
	            print                   padre
	            print                   salto
	            print                   resultados
	           

endm

;guardar en un arreglo
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
	              LOCAL       COMPARACION, COMPARACION3, FIN, DOSPUNTOS, BUSCAR, POSICION, COMPARACION2, NUMERO, COMILLAS, IDENTIFICADOR, AUXILIAR, AUXILIAR2, AUXILIAR3
	              xor         di, di
	COMPARACION:  
	              cmp         auxCadena, '#'
	              je          DOSPUNTOS
	              jne         COMPARACION3

	COMPARACION3: 
	              mov         bl, auxCadena[0]
	              cmp         bl, 'i'
	              jne         FIN
	              mov         bl, auxCadena[1]
	              cmp         bl, 'd'
	              je          DOSPUNTOS
	              jne         FIN

	DOSPUNTOS:    
	              mov         bl, buffer[si]                                                                                                                            	; caracter al registro bl
	              cmp         bl, ':'                                                                                                                                   	; fin de cadena
	              je          BUSCAR
	              inc         si
	              jmp         DOSPUNTOS

	BUSCAR:       
	              inc         si
	              mov         bl, buffer[si]                                                                                                                            	; caracter al registro bl
	              cmp         bl, 09h                                                                                                                                   	; fin de cadena
	              je          BUSCAR
	              mov         bl, buffer[si]                                                                                                                            	; caracter al registro bl
	              cmp         bl, 20h                                                                                                                                   	; fin de cadena
	              je          BUSCAR
	              jmp         POSICION

	POSICION:     
	              mov         bl, array[di]                                                                                                                             	; caracter al registro bl
	              cmp         bl, '$'                                                                                                                                   	; fin de cadena
	              je          COMPARACION2
	              inc         di
	              jmp         POSICION

	COMPARACION2: 
	              cmp         auxCadena, '#'
	              je          AUXILIAR
	              jne         AUXILIAR3

	AUXILIAR:     
	              dec         di
	              dec         di
	              jmp         NUMERO


	NUMERO:       
	              mov         bl, buffer[si]                                                                                                                            	; caracter al registro bl
	              cmp         bl, 09h                                                                                                                                   	; fin de cadena
	              je          AUXILIAR2
	              cmp         bl, 20h                                                                                                                                   	; fin de cadena
	              je          AUXILIAR2
	              cmp         bl, 0ah                                                                                                                                   	; fin de cadena
	              je          AUXILIAR2
	              cmp         bl, ','                                                                                                                                   	; fin de cadena
	              je          AUXILIAR2
	              mov         array[di], bl
	              inc         di
	              inc         si
	              jmp         NUMERO

	AUXILIAR2:    
	              mov         array[di], '%'
	              JMP         FIN

	AUXILIAR3:    
	              xor         di, di
	              clean       idRes, SIZEOF idRes
	              jmp         COMILLAS

	COMILLAS:     
	              inc         si
	              mov         bl, buffer[si]
	              cmp         bl, '"'
	              je          IDENTIFICADOR
	              mov         idRes[di], bl
	              inc         di
	              jmp         COMILLAS


	IDENTIFICADOR:
	              pushRecords
	              getValueId  idRes
	              popRecords

	FIN:          
endm

getValueId macro valor
	               LOCAL       IDENTIFICADOR, COMPARACION, OBTNERVALOR, SIGUIENTE, SIGUIENTE2, FIN, SINVALOR, OBTENER, ASIGNACION, POSICION,CAMBIO, SALIR, IDENTIFICADOR2
	               clean       auxCadena, SIZEOF auxCadena
	               xor         si, si
	               xor         di, di
	IDENTIFICADOR: 
	               mov         bl, resultados[si]
	               cmp         bl, '%'
	               je          COMPARACION
	               cmp         bl, '$'
	               je          SINVALOR
	               mov         auxCadena[di], bl
	               inc         di
	               inc         si
	               jmp         IDENTIFICADOR
	
	COMPARACION:   
	               push        si
	               xor         cx, cx
	               xor         si, si
	               inc         di
	               mov         cx, di
	               xor         di, di
	               lea         si, auxCadena                                                                                                                             	; mover el dato al registro si
	               lea         di, valor                                                                                                                                 	; enviamos la cadena exit al registro di para poder operarlo con si
	               repe        cmpsb
	               je          OBTNERVALOR
	               jne         SIGUIENTE

	SIGUIENTE:     
	               clean       auxCadena, SIZEOF auxCadena
	               pop         si
	               inc         si
	               xor         di, di
	               xor         bx, bx
	               jmp         SIGUIENTE2

	SIGUIENTE2:    
	               mov         bl, resultados[si]
	               cmp         bl, '%'
	               je          IDENTIFICADOR2
	               cmp         bl, '$'
	               je          SINVALOR
	               inc         si
	               jmp         SIGUIENTE2

	IDENTIFICADOR2:
	               inc         si
	               jmp         IDENTIFICADOR

	OBTNERVALOR:   
	               getChar
	               clean       valor, SIZEOF valor
	               clean       auxCadena, SIZEOF auxCadena
	               pop         si
	               inc         si
	               xor         di, di
	               jmp         OBTENER
				  
	OBTENER:       
	               mov         bl, resultados[si]
	               cmp         bl, '%'
	               je          ASIGNACION
	               mov         valor[di], bl                                                                                                                             	; caracter al registro bl
	               inc         di
	               inc         si
	               jmp         OBTENER

	SINVALOR:      
	               clean       valor, SIZEOF valor
	               clean       auxCadena, SIZEOF auxCadena
	               xor         di, di
	               mov         bl, '0'
	               mov         valor[di], bl
	               inc         di
	               jmp         ASIGNACION
	ASIGNACION:    
	               mov         bl, '%'
	               mov         valor[di], bl
	               xor         si, si
	               xor         di, di
	               jmp         POSICION

	POSICION:      
	               mov         bl, operandos[di]                                                                                                                         	; caracter al registro bl
	               cmp         bl, '$'                                                                                                                                   	; fin de cadena
	               je          CAMBIO
	               inc         di
	               jmp         POSICION

	CAMBIO:        
	               dec         di
	               mov         operandos[di], '$'
	               dec         di
	               mov         operandos[di], '$'
	               dec         di
	               mov         operandos[di], '$'
	               saveOnArray valor, operandos
	               jmp         SALIR

	SALIR:         

endm

getValues macro
	            LOCAL         FIRSTVALUE, SECONDVALUE, FIN, POSITION, REMOVE, REMOVE2, REMOVE3, OPERACION, GIRAR
	            pushRecords
	            xor           si, si
	            xor           di, di
	            clean         auxGiro, SIZEOF auxGiro

	POSITION:   
	
	            mov           bl, operandos[di]
	            cmp           bl, '$'
	            je            REMOVE
	            inc           di
	            jmp           POSITION

	REMOVE:     
	            dec           di
	            mov           operandos[di], '$'
	            jmp           FIRSTVALUE

	FIRSTVALUE: 
	            dec           di
	            mov           bl, operandos[di]
	            cmp           bl, '%'
	            je            REMOVE2
	            mov           auxInt1[si], bl
	            mov           operandos[di], '$'
	            inc           si
	            jmp           FIRSTVALUE

	REMOVE2:    
	            mov           operandos[di], '$'
	            xor           si,si
	            jmp           SECONDVALUE

	SECONDVALUE:
	            dec           di
	            mov           bl, operandos[di]
	            cmp           bl, '%'
	            je            REMOVE3
	            mov           auxInt2[si], bl
	            mov           operandos[di], '$'
	            inc           si
	            jmp           SECONDVALUE

	REMOVE3:    
	            mov           operandos[di], '$'
	            xor           si,si
	            jmp           OPERACION

	OPERACION:  
	            dec           di
	            mov           bl, operandos[di]
	            cmp           bl, '%'
	            je            GIRO
	            mov           auxGiro[si], bl
	            mov           operandos[di], '$'
	            inc           si
	            jmp           OPERACION

	GIRO:       
	            push          di
	            rotateNumbers
	            rotateOperand
	            pop           di

	FIN:        
	            popRecords

endm

rotateNumbers macro
	              LOCAL RECORRIDO1, RECORRIDO2, INTERCAMBIO1, INTERCAMBIO2, SIGUIENTE, FIN
	              clean num1, SIZEOF num1
	              clean num2, SIZEOF num2
	              xor   si, si
	              xor   di,di
	              mov   si, SIZEOF auxInt1
				  
	RECORRIDO1:   
	              dec   si
	              mov   bl, auxInt1[si]
	              cmp   bl,	'$'
	              je    RECORRIDO1
	              jmp   INTERCAMBIO1
	INTERCAMBIO1: 
	              mov   bl, auxInt1[si]
	              cmp   di, SIZEOF num1
	              je    SIGUIENTE
	              mov   num1[di], bl
	              dec   si
	              inc   di
	              jmp   INTERCAMBIO1

	SIGUIENTE:    
	              xor   si, si
	              xor   di,di
	              mov   si, SIZEOF auxInt2

	RECORRIDO2:   
	              dec   si
	              mov   bl, auxInt2[si]
	              cmp   bl,	'$'
	              je    RECORRIDO2
	              jmp   INTERCAMBIO2
	INTERCAMBIO2: 
	              mov   bl, auxInt2[si]
	              cmp   di, SIZEOF num2
	              je    FIN
	              mov   num2[di], bl
	              dec   si
	              inc   di
	              jmp   INTERCAMBIO2

	FIN:          
	              clean auxInt1, SIZEOF auxInt1
	              clean auxInt2, SIZEOF auxInt2
endm

verificarFinalOperacion macro buffer, result
	                        LOCAL       INICIO, FIN, RESULTADO, AVANCE, COMPARACION, IGUALES, COMPARACION2, SALTEO, FIN2, SALTEO2, AVANCE2, PASADO
	                        pushRecords
	                        xor         si, si
	                        xor         di, di
	
	INICIO:                 
	                        mov         bl, operandos[si]
	                        cmp         bl, '%'
	                        je          AVANCE
	                        mov         auxCadena[si], bl
	                        inc         si
	                        jmp         INICIO

	AVANCE:                 
	                        mov         bl, '%'
	                        mov         auxCadena[si], bl
	                        inc         si
	                        clean       resultadoAux, SIZEOF resultadoAux
	                        jmp         RESULTADO
	
	RESULTADO:              
	                        mov         bl, operandos[si]
	                        cmp         bl, '%'
	                        je          COMPARACION
	                        mov         resultadoAux[di], bl
	                        inc         si
	                        inc         di
	                        jmp         RESULTADO

	COMPARACION:            
	                        xor         si, si                                                                                                    	; limpiamos el registro si para poder almacenaar la nueva comparacion
	                        xor         di, di
	                        jmp         COMPARACION2

	COMPARACION2:           
	                        mov         bl, result[si]
	                        mov         al, resultadoAux[si]
	                        cmp         al, bl
	                        jne         FIN
	                        cmp         al, '$'
	                        jmp         IGUALES
	                        inc         si
	                        jmp         COMPARACION2


	IGUALES:                
	                        saveOnArray auxCadena, resultados
	                        saveOnArray result, resultados
	                        clean       operandos, SIZEOF resultados
	                        popRecords
	                        inc         si
	                        jmp         SALTEO

	SALTEO:                 
	                        mov         bl, buffer[si]                                                                                            	; caracter al registro bl
	                        cmp         bl, '$'                                                                                                   	; fin de cadena
	                        je          FIN2
	                        cmp         bl, '"'
	                        je          PASADO
	                        cmp         bl, ']'
	                        je          PASADO
	                        cmp         bl, '{'
	                        je          FIN2
	                        cmp         bl, '}'
	                        je          AVANCE2
	                        inc         si
	                        jmp         SALTEO
	AVANCE2:                
	                        inc         si
	                        jmp         SALTEO2

	SALTEO2:                
	                        mov         bl, buffer[si]                                                                                            	; caracter al registro bl
	                        cmp         bl, '$'                                                                                                   	; fin de cadena
	                        je          FIN2
	                        cmp         bl, '"'
	                        je          PASADO
	                        cmp         bl, ']'
	                        je          PASADO
	                        cmp         bl, '{'
	                        je          FIN2
	                        cmp         bl, '}'
	                        je          FIN2
	                        inc         si
	                        jmp         SALTEO2

	PASADO:                 
	                        dec         si
	                        jmp         FIN2

	FIN2:                   
	                        pushRecords
	                        jmp         FIN

	FIN:                    
	                        clean       auxCadena, SIZEOF auxCadena
	                        popRecords


endm

rotateOperand macro
	              LOCAL RECORRIDO, FIN, INTERCAMBIO
	              clean operador, SIZEOF operador
	              xor   si, si
	              xor   di,di
	              mov   si, SIZEOF auxGiro
	RECORRIDO:    
	              dec   si
	              mov   bl, auxGiro[si]
	              cmp   bl,	'$'
	              je    RECORRIDO
	              jmp   INTERCAMBIO
	INTERCAMBIO:  
	              mov   bl, auxGiro[si]
	              cmp   di, SIZEOF operador
	              je    FIN
	              mov   operador[di], bl
	              dec   si
	              inc   di
	              jmp   INTERCAMBIO
	FIN:          
endm

realizarOperacion macro
	                  LOCAL           OPERACION, MULTIPLICACION, DIVISION, SUMA, RESTA, FIN, FIN2, FIN3
	                  clean           resultado, SIZEOF resultado
	                  xor             si, si
	                  xor             di, di

	OPERACION:        
	                  mov             cx, 4
	                  mov             ax, ds
	                  mov             es, ax
	                  lea             si, mul1
	                  lea             di, operador
	                  repe            cmpsb
	                  je              MULTIPLICACION

	                  xor             si, si
	                  xor             di, di
	                  lea             si, div1
	                  lea             di, operador
	                  repe            cmpsb
	                  je              DIVISION

	                  xor             si, si
	                  xor             di, di
	                  lea             si, res1
	                  lea             di, operador
	                  repe            cmpsb
	                  je              RESTA
					  
	                  xor             si, si
	                  xor             di, di
	                  lea             si, sum1
	                  lea             di, operador
	                  repe            cmpsb
	                  je              SUMA

	                  xor             si, si
	                  mov             bl, operador[si]
	                  cmp             bl, '*'
	                  je              MULTIPLICACION

	                  xor             si, si
	                  mov             bl, operador[si]
	                  cmp             bl, '/'
	                  je              DIVISION

	                  xor             si, si
	                  mov             bl, operador[si]
	                  cmp             bl, '-'
	                  je              RESTA

	                  xor             si, si
	                  mov             bl, operador[si]
	                  cmp             bl, '+'
	                  je              SUMA
			
	MULTIPLICACION:   
	                  ConvertirAscii  num1
	                  mov             bx,ax
	                  push            bx
	                  ConvertirAscii  num2
	                  pop             bx
	                  mul             bx
	                  ConvertirString resultado
	                  jmp             FIN
	DIVISION:         
	                  ConvertirAscii  num1
	                  mov             bx,ax
	                  push            bx
	                  ConvertirAscii  num2
	                  pop             bx
	                  div             bx
	                  ConvertirString resultado
	                  jmp             FIN
	SUMA:             
	                  ConvertirAscii  num1
	                  mov             bx,ax
	                  push            bx
	                  ConvertirAscii  num2
	                  pop             bx
	                  add             ax, bx
	                  ConvertirString resultado
	                  jmp             FIN
	RESTA:            
	                  ConvertirAscii  num1
	                  mov             bx,ax
	                  push            bx
	                  ConvertirAscii  num2
	                  pop             bx
	                  sub             ax, bx
	                  ConvertirString resultado
	                  jmp             FIN
					  
	FIN:              
	                  xor             si, si
	                  jmp             FIN2
			
	FIN2:             
	                  mov             bl, resultado[si]
	                  cmp             bl, '$'
	                  je              FIN3
	                  inc             si
	                  jmp             FIN2

	FIN3:             
	                  mov             resultado[si], '%'

					  
endm

ConvertirString macro buffer
	                LOCAL Dividir,Dividir2,FinCr3,NEGATIVO,FIN2,FIN
	                xor   si,si
	                xor   cx,cx
	                xor   bx,bx
	                xor   dx,dx
	                mov   dl,0ah
	                test  ax,1000000000000000
	                jnz   NEGATIVO
	                jmp   Dividir2

	NEGATIVO:       
	                neg   ax
	                mov   buffer[si],45
	                inc   si
	                jmp   Dividir2

	Dividir:        
	                xor   ah,ah
	Dividir2:       
	                div   dl
	                inc   cx
	                push  ax
	                cmp   al,00h
	                je    FinCr3
	                jmp   Dividir
	FinCr3:         
	                pop   ax
	                add   ah,30h
	                mov   buffer[si],ah
	                inc   si
	                loop  FinCr3
	                mov   ah,24h
	                mov   buffer[si],ah
	                inc   si
	FIN:            
endm

ConvertirAscii macro numero
	               LOCAL INICIO,FIN
	               xor   ax,ax
	               xor   bx,bx
	               xor   cx,cx
	               mov   bx,10        	;multiplicador 10
	               xor   si,si
	INICIO:        
	               mov   cl,numero[si]
	               cmp   cl,48
	               jl    FIN
	               cmp   cl,57
	               jg    FIN
	               inc   si
	               sub   cl,48        	;restar 48 para que me de el numero
	               mul   bx           	;multplicar ax por 10
	               add   ax,cx        	;sumar lo que tengo mas el siguiente
	               jmp   INICIO
	FIN:           
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

generateReport macro
	               xor          si, si
	               xor          di, di
	               print        msm4
	               generateJSON
	               print        msm5
endm

setFileName macro
	            LOCAL RECORRIDO, INTERCAMBIO
	            xor   si, si

	RECORRIDO:  
	            mov   bl, padre[si]
	            cmp   bl, '%'
	            je    INTERCAMBIO
	            mov   rutaArchivo[si], bl
	            inc   si
	            jmp   RECORRIDO
	
	INTERCAMBIO:
	            mov   rutaArchivo[si], '.'
	            inc   si
	            mov   rutaArchivo[si], 'j'
	            inc   si
	            mov   rutaArchivo[si], 's'
	            inc   si
	            mov   rutaArchivo[si], 'o'
	            inc   si
	            mov   rutaArchivo[si], 'n'
	            inc   si
	            mov   rutaArchivo[si], 00h

endm

generateJSON macro
	             getFecha      date
	             getHora       hour
	             splitFecha
	             splitHora
	             setFileName
	             createFile    rutaArchivo, handleFichero
	             openFile      rutaArchivo, handleFichero
	             structureJson
	             closeFile     handleFichero
endm

splitFecha macro
	           xor si, si
	           xor di, di
	;dia
	           mov bl, date[si]
	           mov d[di], bl

	           inc di
	           inc si

	           mov bl, date[si]
	           mov d[di], bl

	           inc si          	; /
	           inc si
	           xor di, di
	; mes
	           mov bl, date[si]
	           mov m[di], bl

	           inc di
	           inc si

	           mov bl, date[si]
	           mov m[di], bl

	           inc si          	; /
	           inc si
	           xor di, di
	; año
	           mov bl, date[si]
	           mov a[di], bl

	           inc di
	           inc si

	           mov bl, date[si]
	           mov a[di], bl

	           inc di
	           inc si

	           mov bl, date[si]
	           mov a[di], bl

	           inc di
	           inc si

	           mov bl, date[si]
	           mov a[di], bl
endm

splitHora macro
	          xor si, si
	          xor di, di
	; hora
	          mov bl, hour[si]
	          mov h[di], bl

	          inc di
	          inc si

	          mov bl, hour[si]
	          mov h[di], bl

	          inc si          	; :
	          inc si
	          xor di, di
	; minuto
	          mov bl, hour[si]
	          mov min[di], bl

	          inc di
	          inc si

	          mov bl, hour[si]
	          mov min[di], bl

	          inc si          	; :
	          inc si
	          xor di, di
	; segundos
	          mov bl, hour[si]
	          mov s[di], bl

	          inc di
	          inc si

	          mov bl, date[si]
	          mov s[di], bl
endm


structureJson macro
	              writeFile           SIZEOF llaveAbre, llaveAbre, handleFichero
	              writeFile           SIZEOF tabulacion1, tabulacion1, handleFichero
	              writeFile           SIZEOF reporte, reporte, handleFichero
	              writeFile           SIZEOF tabulacion1, tabulacion1, handleFichero
	              writeFile           SIZEOF llaveAbre, llaveAbre, handleFichero
	; datos alumno
	              writeFile           SIZEOF tabulacion2, tabulacion2, handleFichero
	              writeFile           SIZEOF alumno, alumno, handleFichero
	              writeFile           SIZEOF tabulacion2, tabulacion2, handleFichero
	              writeFile           SIZEOF llaveAbre, llaveAbre, handleFichero
	              writeFile           SIZEOF tabulacion3, tabulacion3, handleFichero
	              writeFile           SIZEOF nombre, nombre, handleFichero
	              writeFile           SIZEOF tabulacion3, tabulacion3, handleFichero
	              writeFile           SIZEOF carnet, carnet, handleFichero
	              writeFile           SIZEOF tabulacion3, tabulacion3, handleFichero
	              writeFile           SIZEOF seccion, seccion, handleFichero
	              writeFile           SIZEOF tabulacion3, tabulacion3, handleFichero
	              writeFile           SIZEOF curso, curso, handleFichero
	              writeFile           SIZEOF tabulacion2, tabulacion2, handleFichero
	              writeFile           SIZEOF llaveCierraComa, llaveCierraComa, handleFichero
	; fecha
	              writeFile           SIZEOF tabulacion2, tabulacion2, handleFichero
	              writeFile           SIZEOF fecha, fecha, handleFichero
	              writeFile           SIZEOF tabulacion2, tabulacion2, handleFichero
	              writeFile           SIZEOF llaveAbre, llaveAbre, handleFichero
	              writeFile           SIZEOF tabulacion3, tabulacion3, handleFichero
	              writeFile           SIZEOF dia, dia, handleFichero
	              writeFile           SIZEOF d, d, handleFichero
	              writeFile           SIZEOF coma, coma, handleFichero
	              writeFile           SIZEOF saltoLinea, saltoLinea, handleFichero
	              writeFile           SIZEOF tabulacion3, tabulacion3, handleFichero
	              writeFile           SIZEOF mes, mes, handleFichero
	              writeFile           SIZEOF m, m, handleFichero
	              writeFile           SIZEOF coma, coma, handleFichero
	              writeFile           SIZEOF saltoLinea, saltoLinea, handleFichero
	              writeFile           SIZEOF tabulacion3, tabulacion3, handleFichero
	              writeFile           SIZEOF anio, anio, handleFichero
	              writeFile           SIZEOF a, a, handleFichero
	              writeFile           SIZEOF saltoLinea, saltoLinea, handleFichero
	              writeFile           SIZEOF tabulacion2, tabulacion2, handleFichero
	              writeFile           SIZEOF llaveCierraComa, llaveCierraComa, handleFichero
	; hora
	              writeFile           SIZEOF tabulacion2, tabulacion2, handleFichero
	              writeFile           SIZEOF hora1, hora1, handleFichero
	              writeFile           SIZEOF tabulacion2, tabulacion2, handleFichero
	              writeFile           SIZEOF llaveAbre, llaveAbre, handleFichero
	              writeFile           SIZEOF tabulacion3, tabulacion3, handleFichero
	              writeFile           SIZEOF hora2, hora2, handleFichero
	              writeFile           SIZEOF h, h, handleFichero
	              writeFile           SIZEOF coma, coma, handleFichero
	              writeFile           SIZEOF saltoLinea, saltoLinea, handleFichero
	              writeFile           SIZEOF tabulacion3, tabulacion3, handleFichero
	              writeFile           SIZEOF minutos, minutos, handleFichero
	              writeFile           SIZEOF min, min, handleFichero
	              writeFile           SIZEOF coma, coma, handleFichero
	              writeFile           SIZEOF saltoLinea, saltoLinea, handleFichero
	              writeFile           SIZEOF tabulacion3, tabulacion3, handleFichero
	              writeFile           SIZEOF segundos, segundos, handleFichero
	              writeFile           SIZEOF s, s, handleFichero
	              writeFile           SIZEOF saltoLinea, saltoLinea, handleFichero
	              writeFile           SIZEOF tabulacion2, tabulacion2, handleFichero
	              writeFile           SIZEOF llaveCierraComa, llaveCierraComa, handleFichero
	; Estadisticas
	              writeFile           SIZEOF tabulacion2, tabulacion2, handleFichero
	              writeFile           SIZEOF resultadosJson, resultadosJson, handleFichero
	              writeFile           SIZEOF tabulacion2, tabulacion2, handleFichero
	              writeFile           SIZEOF llaveAbre, llaveAbre, handleFichero
	; macro para imprimir las estadisticas
	              writeFile           SIZEOF tabulacion2, tabulacion2, handleFichero
	              writeFile           SIZEOF llaveCierraComa, llaveCierraComa, handleFichero
	; Resultados
	              writeFile           SIZEOF tabulacion2, tabulacion2, handleFichero
	              imprimirPadre
	              writeFile           SIZEOF tabulacion2, tabulacion2, handleFichero
	              writeFile           SIZEOF corcheteAbre, corcheteAbre, handleFichero
	              imprimirOperaciones
	              writeFile           SIZEOF tabulacion2, tabulacion2, handleFichero
	              writeFile           SIZEOF corcheteCierra, corcheteCierra, handleFichero
	; Fin JSON
	              writeFile           SIZEOF tabulacion1, tabulacion1, handleFichero
	              writeFile           SIZEOF llaveCierra, llaveCierra, handleFichero
	              writeFile           SIZEOF llaveCierra, llaveCierra, handleFichero

endm

imprimirPadre macro
	              LOCAL     ESPACIO, FIN
	              xor       di, di

	ESPACIO:      
	              mov       bl, padre[di]
	              cmp       bl, '%'
	              je        FIN
	              inc       di
	              jmp       ESPACIO

	FIN:          
	              writeFile SIZEOF comilla, comilla, handleFichero
	              writeFile di, padre, handleFichero
	              writeFile SIZEOF comilla, comilla, handleFichero
	              writeFile SIZEOF puntos, puntos, handleFichero
	              writeFile SIZEOF saltoLinea, saltoLinea, handleFichero
endm

imprimirOperaciones macro
	                    LOCAL     INICIO, IDENTIFICADOR, SIGUIENTE, VALOROP, SIGUIENTE2, ULTIMO, OTROID
	                    xor       si, si
	INICIO:             
	                    clean     auxCadena, SIZEOF auxCadena
	                    xor       di, di
	                    writeFile SIZEOF tabulacion3, tabulacion3, handleFichero
	                    writeFile SIZEOF llaveAbre, llaveAbre, handleFichero
	                    writeFile SIZEOF tabulacion4, tabulacion4, handleFichero
	                    writeFile SIZEOF comilla, comilla, handleFichero
	                    jmp       IDENTIFICADOR

	IDENTIFICADOR:      
	                    mov       bl, resultados[si]
	                    cmp       bl, '%'
	                    je        SIGUIENTE
	                    mov       auxCadena[di], bl
	                    inc       di
	                    inc       si
	                    jmp       IDENTIFICADOR

	SIGUIENTE:          
	                    writeFile di, auxCadena, handleFichero
	                    writeFile SIZEOF comilla, comilla, handleFichero
	                    writeFile SIZEOF puntos, puntos, handleFichero
	                    clean     auxCadena, SIZEOF auxCadena
	                    xor       di, di
	                    inc       si
	                    jmp       VALOROP

	VALOROP:            
	                    mov       bl, resultados[si]
	                    cmp       bl, '%'
	                    je        SIGUIENTE2
	                    mov       auxCadena[di], bl
	                    inc       di
	                    inc       si
	                    jmp       VALOROP

	SIGUIENTE2:         
	                    writeFile di, auxCadena, handleFichero
	                    inc       si
	                    mov       bl, resultados[si]
	                    cmp       bl, '$'
	                    je        ULTIMO
	                    jmp       OTROID

	OTROID:             
	                    writeFile SIZEOF saltoLinea, saltoLinea, handleFichero
	                    writeFile SIZEOF tabulacion3, tabulacion3, handleFichero
	                    writeFile SIZEOF llaveCierraComa, llaveCierraComa, handleFichero
	                    jmp       INICIO

	ULTIMO:             
	                    writeFile SIZEOF saltoLinea, saltoLinea, handleFichero
	                    writeFile SIZEOF tabulacion3, tabulacion3, handleFichero
	                    writeFile SIZEOF llaveCierra, llaveCierra, handleFichero

endm



