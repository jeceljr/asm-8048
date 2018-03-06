        clr a    ;  vetor de power-up
        jmp inicio

        db   0,0,0,0  ;  vetor de interrupcao

        sel rb1  ;  vetor de interrupcao
        mov r2,a
        mov a,#0A0h
        mov t,a
        mov a,r4
        xrl a,#55h
        jnz nreset ; em reset manda AA
        mov r4,#0AAh
        clr a
L1a:    jnt1 L0a   ; recebeu reset ?
        dec a
        jnz L1a
        stop tcnt
L10a:   jt1 L10a   ; espera passar o reset
        mov a,#0AAh ; manda AA
        call send
        strt t
        sel rb0
        mov a,r5   ;  reinicializa ...
        anl a,#0E7h ;         ... o status
        orl a,#01h
        jmp L11a
L100:   mov a,r2
        retr
L0a:    sel rb0
        mov a,r5
        anl a, #0FEh
L11a:   mov r5,a
        sel rb1
        jmp L100

nreset: dis tcnti   ;  desliga saidas
        dis i
        orl p1,#0FFh
        orl p2,#0FFh
        movx a,@r0
        clr a
        mov psw,a   ;  inicializa jogo
        clr f1
        jtf L1b
L1b:    call L0b
        jmp inicio
L0b:    retr

inicio: mov r0,#3Fh  ;  limpa mapa do ...
L0c:    mov @r0,a    ;          ... teclado
        djnz r0,L0c
        mov r1,#10h  ;  inicializa apontadores
        mov r0,#1Fh  ;
        mov a,#0A0h  ;  inicializa Timer
        mov t,a
        strt t
        en tcnti
        sel rb1      ;  inicializa pilha de ...
        mov r5,#0F0h ;       ... teclas
        mov r6,#3Fh
        mov r7,#3Fh
        sel rb0
next:    inc r0       ;  proxima coluna
coluns: en tcnti
        sel rb1
        mov r4,#55h
        sel rb0
        mov a,#0D5h   ;  ultima coluna ?
        add a,r0
        jc last
        call read    ;  le coluna
        jz next
        mov r3,a     ;  debounce
        mov r2,#28h
L0d:    djnz r2,L0d
        movd p4,a
        call read
        anl p1,#0FEh
        movd p4,a
        anl a,r3
        jz next
        mov r3,a     ; acha tecla apertada 
        mov r2,#01
        mov a,r0
        swap a       ;  monta apontador p/ ...  
        rr a         ;     ... tecla testada
        anl a,#78h
        mov r7,a
        mov a,r2
outra:  anl a,r3
        jnz tecla    ;  tecla apertada ?
outras: sel rb0
        mov a,r3     ;  ha outra ?
        jz next
        mov a,r2     ;  proxima ?
        rl a
        mov r2,a
        inc r7
        jmp outra
tecla:  sel rb1      ;  buffer full ?
        mov a,r6
        sel rb0
        jz last
        mov a,r2     ;  apaga bit ...
        cpl a        ;  ... correspondente a ...
        anl a,r3     ;  ... tecla
        mov r3,a         
        mov a,r2     ;  ja' executou antes ?
        anl a,@r0
        jnz again
        mov a,r2     ;  marca a primeira execucao
        xrl a,@r0
        mov @r0,a
        mov a,r7     ;  coloca tecla calculada ...
        mov @r1,a    ;  ... no buffer de teclas
        mov a,r1     ;  incrementa apontador ...
        inc a        ;  ... do buffer ...
        anl a,#17h   ;  ... de teclas
        mov r1,a
        mov a,r7     ;  num lock ?
        xrl a,#04h
        jnz L4
        mov a,r5     ;  altera LED de ...
        xrl a,#10h   ;  ... num lock
        mov r5,a
L4:        mov a,r7     ;  caps lock ?
        xrl a,#00h
        jnz L5
        mov a,r5     ;  altera LED de ...
        xrl a,#08h   ;  ... caps lock
        mov r5,a
L5:        mov a,r7
        mov r4,a
        jf1 L1f      ;  pega codigo da tecla ...
        movp3 a,@a   ;  ... na tabela
L0f:    call send    ;  poe codigo no buffer
        sel rb1
        mov a,r5
        jb1 L11f     ;  ja' repeticao ?
        jmp outras
L11f:    mov r3,#32h
        jmp outras
L1f:    outl p1,a    ;  se tabela externa ...
        anl p2,#0FEh  ;  ... pega codigo nesta ...
        movx a,@r0   ;  ... rotina
        jmp L0f
again:    mov a,r1     ;  ja' foi mandado ...
        mov r6,a     ;  ... para o buffer ?
L0g:    mov a,r7
        xrl a,@r1
        jnz L1g
        mov a,r6     ;  ja' no buffer
        mov r1,a
        jmp outras
L1g:    mov a,r1     ;  fim de buffer ?
        inc a
        anl a,#17h
        mov r1,a
        xrl a,r6
        jnz L0g
        mov a,r2     ;  apaga da tabela ...
        xrl a,@r0    ;  ... de teclas
        mov @r0,a
        mov a,r7     ;  ultima tecla ?
        xrl a,r4
        jnz L7h
        sel rb1      ;  executa imediatamente
        mov r3,a
        sel rb0
        cpl a
        mov r4,a
L7h:    mov a,r7     ;  envia codigo de ...
        jf1 L80      ;  ... final de tecla
        movp3 a,@a
        orl a,#80h
L2:        call send
        jmp outras
L80:    outl p1,a
        orl p2,#01h
        movx a,@r0
        jmp L2
        nop
        nop
last:    jmp L1h      ;  conexao p/ outra ...
L1h:    jtf shift    ;  ... pagina de memoria
        nop
        nop
nada:    sel rb1      ;  sai ...
        mov a,r5     ;  ... start bit
        orl a,#0Fh
        outl p2,a
        in a,p2      ;  le status
        orl a,#0C0h
        mov r5,a
        sel rb0
        clr c
        mov a,r5
        jb3 L3
        orl p2,#40h  ;  LED aceso ...
        jmp L30      ;  ... de caps lock
L3:        anl p2,#0BFh ;  LED apagado ...
        sel rb1      ;  ... de caps lock
        mov a,r5
        anl a,#0BFh
        mov r5,a
        sel rb0
L30:    mov a,r5
        jb4 L4a
        orl p2,#80h  ;  LED aceso ...
        jmp L40      ;  ... num lock
L4a:    anl p2,#7Fh  ;  LED apagado ...
        sel rb1      ;  ... num lock
        mov a,r5
        anl a,#7Fh
        mov r5,a
L40:    sel rb1
        mov a,r5
        outl p2,a
        clr f1
        sel rb0
        mov r0,#20h
        jb2 L2a
        jmp coluns
L2a:    cpl f1
        jmp coluns
shift:    sel rb1      ;  tempo de espera ja' ...
        mov a,r3     ;  ... acabou ?
        jz L0i
        djnz r3,L0i
        mov r3,#08h  ;  seta novo tempo ...
        sel rb0      ;  ... da espera
        mov a,r4
        sel rb1
        jf1 L1i      ;  se auto repeat pega ...
        movp3 a,@a   ;  ... valor a repetir
L8:        call send
        jmp L0i
L1i:    outl p1,a
        anl p2,#0FEh
        movx a,@r0
        jmp L8
L0i:    sel rb0      ;  apaga ponta do buffer
        mov @r1,#0FFh
        mov a,r1     ;  incrementa apontador ...
        inc a        ;  ... de buffer
        anl a,#17h
        mov r1,a
        sel rb1      ;  buffer empty ?
        mov a,r7
        xrl a,r6
        jz nada
        mov a,r6
        jnz L6       ;  apaga buffer full
        mov a,r7
        mov r6,a
L6:        mov a,r7     ;  move topo de buffer
        mov r1,a
        dec a
        orl a,#30h
        mov r7,a
        stop tcnt
        anl p2,#0DFh ;  desliga clock de ...
        mov a,r5     ;  ... start bit
        anl a,#0EFh
        mov r5,a
        mov a,@r1    ;  prepara o primeiro nibble
        swap a
        mov @r1,a
        anl a,#10h   ;  manda o primeiro bit
        orl a,r5
        outl p2,a
        mov a,@r1
        anl p2,#0DFh
        rr a         ;  manda o segundo bit
        mov @r1,a
        anl a,#10h
        orl a,r5
        outl p2,a
        mov a,@r1    ;  manda o terceiro bit
        anl p2,#0DFh
        rr a
        mov @r1,a
        anl a,#10h
        orl a,r5
        outl p2,a
        mov a,@r1    ;  manda o quarto bit
        anl p2,#0DFh
        rr a
        mov @r1,a
        anl a,#10h
        orl a,r5
        outl p2,a
        mov a,@r1    ;  manda o quinto bit
        anl p2,#0DFh
        rr a
        mov @r1,a
        anl a,#10h
        orl a,r5
        outl p2,a
        mov a,@r1    ;  manda o sexto bit
        anl p2,#0DFh
        rr a
        mov @r1,a
        anl a,#10h
        orl a,r5
        outl p2,a
        mov a,@r1    ;  manda o setimo bit
        anl p2,#0DFh
        rr a
        mov @r1,a
        anl a,#10h
        orl a,r5
        outl p2,a
        mov a,@r1    ;  manda o oitavo bit
        anl p2,#0DFh
        rr a
        mov @r1,a
        anl a,#10h
        orl a,r5
        outl p2,a
        mov a,@r1
        anl p2,#0DFh
        rr a         ;  retorna valor a ...
        swap a       ;  ... mandar p/o buffer
        mov @r1,a
        mov a,#30h   ;  volta as linhas a +5V
        orl p2,#30h
        orl a,r5
        mov r5,a
        sel rb0
        mov a,r5
        jb0 L10j
L7:        strt t
        jmp nada
L10j:    nop          ;  atualiza status
        jni L12
        jb1 L4j
        orl a,#02h
        mov r5,a
        jmp L7
L4j:    sel rb1
        mov r0,#04h
L40j:    djnz r0,L40j
        anl p2,#0DFh
        sel rb0
L12:    anl a,#0FDh
        orl p2,#20h
        mov r5,a
        jmp L7
read:    mov a,r0     ;  liga coluna
        outl p1,a
        movd p4,a
        orl p1,#0FFh ;  le linhas
        in a,p1
        cpl a        ;  compara c/ buffer
        xrl a,@r0
        retr
send:    sel rb1      ;  buffer full ?
        xch a,r6
        jz L0k
        mov r1,a     ;  move apontador ...
        dec a        ;  ... de buffer
        orl a,#30h
        xch a,r6     ;  poe no buffer
        mov @r1,a
        mov a,r6     ;  buffer full ?
        xrl a,r7
        jnz L1k
L0k:    mov r6,a     ;  marca buffer full *
L1k:    retr

        org 01feh
        jmp nreset

        org 0284h
        jmp nreset
        jmp nreset

        org 02fch
        jmp nreset
        jmp nreset

        org 0300h
        db 045h, 036h, 038h, 01dh, 03ah, 054h, 02ah, 058h   ; tabela de teclas
        db 046h, 049h, 055h, 04dh, 04eh, 053h, 051h, 04ah
        db 00eh, 047h, 04ch, 04bh, 050h, 052h, 04fh, 048h
        db 00dh, 01bh, 01ch, 029h, 037h, 056h, 044h, 057h
        db 00bh, 019h, 028h, 027h, 039h, 00ch, 034h, 01ah
        db 009h, 017h, 026h, 025h, 033h, 00ah, 032h, 018h
        db 007h, 015h, 024h, 023h, 031h, 008h, 043h, 016h
        db 005h, 013h, 022h, 021h, 02fh, 004h, 02eh, 014h
        db 003h, 011h, 020h, 01fh, 02dh, 002h, 02ch, 010h
        db 001h, 00fh, 01eh, 042h, 02bh, 03ch, 041h, 03eh
        db 03bh, 03dh, 040h, 03fh, 035h, 006h, 030h, 012h
        db 004h, 033h, 000h, 000h

        org 0386h
        jmp nreset

        org 03feh
        jmp nreset

        end
