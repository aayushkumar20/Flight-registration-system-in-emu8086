data segment
    ;strings
    newlineString db 0ah,0dh,' $'  
    welcomeString db 0ah,0dh,'Welcome to Air India Ticket Reservation System','$' 
    thankYouString db 0ah,0dh,'Thank you for using our system $'  

    ;flight choosing menu
    flightMenuString db 0ah,0dh,'Please Select type of flight to Book Tickets: $' 
    flightSelection db 0ah,0dh,'Enter Flight Type number: $'                     
    flightAName db 0ah,0dh,'1: Airbus $'
    flightBName db 0ah,0dh,'2: Boeing $'
    flightCName db 0ah,0dh,'3: Chartered $' 

    ;class menu         
    classMenuString db 0ah,0dh,'Please select class  $'     
    classSelection db 0ah,0dh,'Select a class (enter number): $'
    classAName db 0ah,0dh,'1: Economy $' 
    classBName db 0ah,0dh,'2: First $'
    classCName db 0ah,0dh,'3: Business $'
    
    ;error message
    errorString db 0ah,0dh,'INVALID OPTION.PLEASE TRY AGAIN!!!$'

    ;status messages
    currentStatus db 0ah,0dh,'Current Status (processing) : $'  
    noMoreAvailable db 0ah,0dh,'Sorry!! No more seats are available $'
    returnClassMenu db 0ah,0dh,'1: Return to class selection $'
    returnMainMenu db 0ah,0dh,'2: Return to main menu $'
    exitProg db 0ah,0dh,'3: Exit $'
    choiceRead db 0ah,0dh,'Enter choice: $'
    availableSeats db 0ah,0dh,'No. of seats available: $'
    numOfSeatsToBeBooked db 0ah,0dh,'Enter no .of seats to be booked,[max 5]: $'    
    limitOver db 0ah,0dh,'Maximum limit exceeded,give less than 5: $'
    success db 0ah,0dh,'Booking successful! $'
    bookedSeats db 0ah,0dh,'Your seats are: $'
    anotherTicket db 0ah,0dh,'1: Book another ticket $'
    exitProgram db 0ah,0dh,'2: Exit $' 
   
    ;variables to store available seating information
    flightASeatsNumber db 3 dup(20)
    flightBSeatsNumber db 3 dup(20)   
    flightCSeatsNumber db 3 dup(20) 

    ;variables to display booked/unbooked seats
    flightASeats db 60 dup(0)  
    flightBSeats db 60 dup(0)
    flightCSeats db 60 dup(0)

    ;currently chosen items
    currentlyChosenFlight db ?
    currentlyChosenClass db ? 
    
    choiceCompartment dw ?     
    choiceAvailableSeats dw ?
    chosenFlightID db ?
    chosenClassID db ?  
    printVal db ?      

data ends
    
;macro to print strings    
printString macro arg
    lea dx,arg
    mov ah,09h
    int 21h
endm  

;macro to print char
printChar macro arg
    mov dl,arg
    mov ah,02h
    int 21h
endm

;code segment
code segment
assume cs:code,ds:data
      
start:          mov ax,data
                mov ds,ax
;print menu
menu:           mov ah,00h
                mov al,02h
                int 10h
                ;clear screen
                printString welcomeString  
                printString newlineString

;flight menu
                printString flightMenuString  
                printString newlineString  
                printString flightAName
                printString newlineString
                printString flightBName
                printString newlineString 
                printString flightCName  
chooseFlight:   printString newlineString 
                printString flightSelection             

                call readInt                
;check for errors
                cmp al,04h
                jc noErrorFlight
                printString newlineString
                printString errorString
                jmp chooseFlight

;choose class
noErrorFlight:   mov currentlyChosenFlight,al
                
                printString newlineString
classMenu:      printString classMenuString  
                printString newlineString  
                printString classAName
                printString newlineString
                printString classBName
                printString newlineString 
                printString classCName  
chooseClass:    printString newlineString 
                printString classSelection 
           
                call readInt
;check for errors 
                cmp al,04h
                jc noErrorClass
                printString newlineString
                printString errorString
                jmp chooseClass
             
noErrorClass:   mov currentlyChosenClass,al
                printString newlineString
                printString currentStatus
                printString newlineString
                printString newlineString
                call displaySeats 
                mov si,choiceCompartment
                mov di,choiceAvailableSeats
                mov bh,[di]
                mov ah,14h
                sub ah,bh
addLoop:        cmp ah,00h
                jz h
                inc si
                dec ah
                jmp addLoop

;check for seats  
h:              cmp bh,00h
                jnz seatAvailable
                printString noMoreAvailable
                printString newlineString
                printString returnClassMenu
                printString returnMainMenu
                printString exitProg
redoChoice:     printString newlineString
                printString choiceRead
                
                call readInt
                cmp al,04h
                jc process
                printString errorString
                jmp redoChoice
process:        cmp al,01h
                jz classMenu
                cmp al,02h
                jz menu
                jmp exit

seatAvailable:  printString availableSeats
                mov printVal,bh
                call printInt

repeatBook:     printString newlineString 
                printString numOfSeatsToBeBooked 
                
                call readInt  
                cmp al,06h
                jc proceedBooking
                printString limitOver
                jmp repeatBook

proceedBooking: mov bl,al
                mov bh,14h
                mov ah,[di]
                sub bh,ah
                inc bh
                printString newlineString
                printString success
                printString bookedSeats

printSeats:     printChar chosenFlightID
                printChar chosenClassID
                mov printVal,bh
                call printInt
                inc bh
                printChar ' '
                mov [si],01h
                inc si
                dec [di]
                dec bl
                jnz printSeats
whatNext:       printString newlineString
                printString anotherTicket
                printString exitProgram
                printString newlineString
                printString choiceRead
                call readInt
;check for errors 
                cmp al,04h
                jc noProbs
                printString newlineString
                printString errorString
                jmp whatNext

noProbs:        cmp al,01h
                jz menu 

exit:           printString newlineString
                printString thankYouString
                mov ah,4ch
                int 21h 
;end of main program               

;procedure to read integer
readInt proc   
    mov ah,01h
    int 21h
    sub al,30h
    cmp al,09h
    jc rn
    jz rn
    sub al,07h
 rn:ret
endp         

;procedure to print integer
printInt proc  
        mov dl,printVal
        and dl,0F0h
        mov cl,04h
        shr dl,cl
        add dl,30h
        cmp dl,39h
        jc rnu
        jz rnu  
        add dl,07h
 rnu:   mov ah,02h
        int 21h
        mov dl,printVal
        and dl,0Fh
        add dl,30h
        cmp dl,39h
        jc rnp
        jz rnp  
        add dl,07h
 rnp:   mov ah,02h
        int 21h
 ret
endp   
    
    
;procedure to display seating
displaySeats proc
flightAChosen:   cmp currentlyChosenFlight,01h
                jnz flightBChosen
                lea si,flightASeats   
                lea di,flightASeatsNumber
                mov chosenFlightID,'A'
                jmp classAChosen

flightBChosen:   cmp currentlyChosenFlight,02h
                jnz flightCChosen
                lea si,flightBSeats
                lea di,flightBSeatsNumber
                mov chosenFlightID,'B'
                jmp classAChosen

flightCChosen:   lea si,flightCSeats
                lea di,flightCSeatsNumber
                mov chosenFlightID,'C'
                
classAChosen:   cmp currentlyChosenClass,01h
                jnz classBChosen
                mov chosenClassID,'A'
                jmp chooseOver

classBChosen:   cmp currentlyChosenClass,02h
                jnz classCChosen
                add si,14h
                add di,01h
                mov chosenClassID,'B'
                jmp chooseOver

classCChosen:   add si,28h  
                add di,02h
                mov chosenClassID,'C'

chooseOver:     mov choiceAvailableSeats,di
                mov di,si 
                mov choiceCompartment,si
                inc di
                mov ch,02h

nextrow:        mov cl,0ah

;display the seats
disploop1:      cmp [si],00h
                jnz booked
                mov dl,'-'
                jmp show

booked:         mov dl,'X'

;show '-' if not booked and 'X' if booked
show:           mov ah,02h
                int 21h

                mov dl,' '
                mov ah,02h
                int 21h

                add si,02h
                dec cl
                jnz disploop1

                printString newlineString

                mov si,di
                dec ch
                jnz nextrow
ret
endp

code ends
end start