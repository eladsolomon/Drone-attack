
section .data
  temp: dd 0
  struc drone
    id: resd 1
    destroyed: resd 1
    kills: resd 1
    x: resd 1
    y: resd 1
    heading: resd 1
    speed: resd 1
    next: resd 1
  endstruc
  
section .text
  align 16
  global main
  global run_drone
  extern printf
  extern fprintf 
  extern fflush
  extern malloc 
  extern calloc 
  extern free 
  extern sscanf
  extern stderr
  extern get_random_number
  extern working_drone
  extern randint
  extern CO_target
  extern CO_scheduler
  extern mayDestroy
  extern resume




run_drone:
  push ebp            
  mov ebp, esp
  pushad

  mov edx, dword[working_drone]

  cmp dword[edx + destroyed], 1
  jz skip_destory

  ; move drone

  ; Calculate new x
  mov ecx, dword[edx + heading]
  mov [temp], ecx
  fld dword[temp]
  fsin
  mov ecx, dword[edx + speed]
  mov [temp], ecx
  fld dword[temp]
  fmul
  mov ecx, dword[edx + x]
  mov [temp], ecx
  fld dword[temp]
  fadd
  mov dword[randint], 0
  fild dword[randint]
  fcomip
  ja negativex
  mov dword[randint], 100
  fild dword[randint]
  fcomip
  jb positivex
  jmp xReady

 negativex: ;TODO CHECK
    mov dword[randint], 100 ;add to heading
    fild dword[randint]
    fadd
    jmp xReady

  positivex:;TODO CHECK
    mov dword[randint], 100 ;max heading
    fild dword[randint]
    fsub
      
  xReady:
  fstp dword[edx + x]

  ; Calculate new y
  mov ecx, dword[edx + heading]
  mov [temp], ecx
  fld dword[temp]
  fsin
  mov ecx, dword[edx + speed]
  mov [temp], ecx
  fld dword[temp]
  fmul
  mov ecx, dword[edx + y]
  mov [temp], ecx
  fld dword[temp]
  fadd
  mov dword[randint], 0
  fild dword[randint]
  fcomip
  ja negativeY
  mov dword[randint], 100
  fild dword[randint]
  fcomip
  jb positiveY
  jmp yReady

 negativeY: ;TODO CHECK
    mov dword[randint], 100 ;add to heading
    fild dword[randint]
    fadd
    jmp yReady

  positiveY:;TODO CHECK
    mov dword[randint], 100 ;max heading
    fild dword[randint]
    fsub
      
  yReady:
  fstp dword[edx + y]




  ; Change drone heading
  push 120
  call get_random_number
  
  ;mov ebx, dword[randint] ; random heading [-60,60]
    fld dword[randint]
    mov dword[randint], 60
    fild dword[randint]
    fsub
    mov ecx, dword[edx + heading]
    
    mov [temp], ecx
    fld dword[temp]
    fadd
    mov dword[randint], 0 ;min heading
    fld dword[randint]
    fcomip
    ja negativeHedaing
    mov dword[randint], 360 ;add to heading
    fild dword[randint]
    fcomip
    
    jb positiveHeading
    jmp headingReady

  negativeHedaing: ;TODO CHECK
    mov dword[randint], 360 ;add to heading
    fild dword[randint]
    fadd
    jmp headingReady

  positiveHeading:;TODO CHECK
    mov dword[randint], 360 ;max heading
    fild dword[randint]
    fsub
  headingReady:
  fstp dword[edx + heading]
  fstp dword[randint]

  ; Change drone speed
  push 20
  call get_random_number ;random speed change [-10,10]
  fld dword[randint]
  mov dword[randint], 10
  fild dword[randint]
  fsub
  mov dword[randint], 0
  fild dword[randint]
  fcomip
  jb positiveSpeed
      ; Negetive speed
      mov ecx, dword[edx + speed]
      mov [temp], ecx
      fld dword[temp]
      fadd
      mov dword[randint], 0 ;min speed
      fld dword[randint]
      fcomip
      jb speedReady
      mov dword[randint], 0 ;min speed
      fild dword[randint]
      jmp speedReady

  positiveSpeed:
      mov ecx, dword[edx + speed]
      mov [temp], ecx
      fld dword[temp]
      fadd
      mov dword[randint], 100 ;max speed
      fild dword[randint]
      fcomip
      ja speedReady ;need to ne ja
      mov dword[randint], 100 ;max speed
      fild dword[randint]
  
  speedReady:
    fstp dword[edx + speed]

    call mayDestroy
    cmp eax, 0
    jz skip_destory

    inc dword[edx + kills]

	  popad
    mov esp, ebp
    pop ebp
	  mov dword ebx, CO_target
	  call resume
	  jmp run_drone


  skip_destory:
    popad
    mov esp, ebp
    pop ebp
    mov dword ebx, CO_scheduler
    call resume
    jmp run_drone

  
 

