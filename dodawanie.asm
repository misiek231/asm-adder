         [bits 32]

;        esp -> [ret]  ; ret - adres powrotu do asmloader

         call getaddrinp
formatinp:
         db "a = ", 0
getaddrinp:

;        esp -> [format][ret]

         call [ebx+3*4]  ; printf("a = ");

;        esp -> [a][ret] ; zmienna a, adres format nie jest juz potrzebny

         push esp        ; esp -> stack

;        esp -> [addr_a][a][ret]

         call getaddrinp2
formatinp2:
         db "%d", 0
getaddrinp2:

;        esp -> [format2][addr_a][a][ret]

         call [ebx+4*4]  ; scanf("%d", &a);
         add esp, 2*4    ; esp = esp + 8

;        esp -> [a][ret]


         call getaddrinpb
formatinpb:
         db "b = ", 0
getaddrinpb:

;        esp -> [format][a][ret]

         call [ebx+3*4]  ; printf("b = ");

;        esp -> [b][a][ret] ; zmienna b, adres format nie jest juz potrzebny

         push esp        ; esp -> stack

;        esp -> [addr_b][b][a][ret]

         call getaddrinpb2
formatinpb2:
         db "%d", 0
getaddrinpb2:

;        esp -> [format2][addr_b][b][a][ret]

         call [ebx+4*4]  ; scanf("%d", &b);
         add esp, 2*4    ; esp = esp + 8

;        esp -> [b][a][ret]


         mov ecx, [esp]  ; ecx = *(int*)esp
         mov eax, [esp+4]  ; eax = *(int*)esp

         cmp ecx, eax
         cmovl eax, ecx  ; if ecx < eax then eax = ecx

         mov edi, eax  ; edi = eax

;        esp -> [b][a][ret]

         pop ecx  ; ecx <- stack
         pop eax  ; eax <- stack

;        esp -> [ret]

         cmp eax, ecx
         cmovl eax, ecx  ; if eax < ecx then eax = ecx

         push edi
         push eax

;        esp -> [max_a_b][min_a_b][ret]

         push 1

;        esp -> [1][max_a_b][min_a_b][ret]

         cmp eax, 1

         jle skip_log  ; pomijamy logarytm jeœli max_a_b = 1 lub max_a_b = 0

;        esp -> [ ][max_a_b][min_a_b][ret]  ; jeœli liczymy logarytm 1 traktujemy jako wolne miejsce na wynik

         call log10             
         
;        esp -> [width_max_a_b][max_a_b][min_a_b][ret]

skip_log:

         mov ecx, [esp]  ; ecx = *(int*)esp = width_max_a_b

         mov edi, 10  ; edi = 10
         
         push 2  ; liczba pomocnicza do wyjscia z pêtli

;                  +4             +8       +12
;        esp -> [2][width_max_a_b][max_a_b][min_a_b][ret]

         push dword [esp+8]

;                        +4 +8             +12       +16
;        esp -> [max_a_b][2][width_max_a_b][max_a_b][min_a_b][ret]

         push dword [esp+16]

;        esp -> [max_a_b][min_a_b][2][width_max_a_b][max_a_b][min_a_b][ret]

loop1:

         pop eax  ; eax = max_a_b

;        esp -> [min_a_b][2][width_max_a_b][max_a_b][min_a_b][ret]

         pop edx  ; edx = min_a_b

;        esp -> [2][width_max_a_b][max_a_b][min_a_b][ret]

         push 0

;        esp -> [0][2][width_max_a_b][max_a_b][min_a_b][ret]

         push edx
         
;        esp -> [min_a_b][0][2][width_max_a_b][max_a_b][min_a_b][ret]

         push eax

;        esp -> [max_a_b][min_a_b][0][2][width_max_a_b][max_a_b][min_a_b][ret]

         mov eax, [esp] ; eax = max_a_b
         mov edx, 0     ; edx = 0

         div edi  ; edx = eax % edi = digits_a

         mov esi, edx  ; esi = edx

         mov eax, [esp+4] ; eax = min_a_b
         mov edx, 0       ; edx = 0

         div edi  ; edx = eax % edi = digits_b

         add esi, edx  ; esi = esi + edx = digits_a + digits_b

         cmp edi, esi
         jg done  ; jeœli edi <= esi 0 zastêpujemy 1

         mov dword [esp+8], 1

;        esp -> [max_a_b][min_a_b][1][2][width_max_a_b][max_a_b][min_a_b][ret]

done     mov esi, 10   ; esi = 10
         mov eax, edi  ; eax = edi
         mul esi       ; eax = eax * esi = eax * 10
         mov edi, eax  ; edi = eax = edi * 10

         loop loop1  ; ecx = ecx - 1  ; jmp loop1

;        esp -> [max_a_b][min_a_b][0 or 1]...[2][width_max_a_b][max_a_b][min_a_b][ret]

         add esp, 2*4

;        esp -> [0 or 1]...[2][width_max_a_b][max_a_b][min_a_b][ret]

         call getaddrnl
formatnl:
         db 0xA, " ", 0
getaddrnl:

;        esp -> [format][0 or 1]...[2][width_max_a_b][max_a_b][min_a_b][ret]

         call [ebx+3*4]  ; printf(format);
         add esp, 4    ; esp = esp + 4

;        esp -> [0 or 1]...[2][width_max_a_b][max_a_b][min_a_b][ret]

loop2    pop eax  ; eax <- stack

;        esp -> [0 or 1]...[2][width_max_a_b][max_a_b][min_a_b][ret]

         cmp eax, 0
         je print_space  ; jeœli eax = 0 wypisujemy spacjê

         cmp eax, 1
         je print_1  ; jeœli eax = 1 wypisujemy 1

;        esp -> [width_max_a_b][max_a_b][min_a_b][ret]

         jmp done2  ; w pozosta³ych przypadkach wychodzimy z pêtli

print_space:

        call getspace
space    db " ", 0
getspace:

;        esp -> [f_space][0 or 1]...[2][width_max_a_b][max_a_b][min_a_b][ret]

         call [ebx+3*4]  ; printf(" ");
         add esp, 4  ; esp = esp + 4
         
;        esp -> [0 or 1]...[2][width_max_a_b][max_a_b][min_a_b][ret]

         jmp loop2

print_1:

        call getone
one    db "1", 0
getone:

;        esp -> [f_one][0 or 1]...[2][width_max_a_b][max_a_b][min_a_b][ret]

         call [ebx+3*4]  ; printf("1");
         add esp, 4
         
;        esp -> [0 or 1]...[2][width_max_a_b][max_a_b][min_a_b][ret]

         jmp loop2

done2:

;        esp -> [width_max_a_b][max_a_b][min_a_b][ret]

         pop edi  ; edi <- stack = width_max_a_b

;        esp -> [max_a_b][min_a_b][ret]
         
         call getaddrmaxab
formatmaxab:
         db 0xA, "  %d", 0xA, 0
getaddrmaxab:

;        esp -> [format][max_a_b][min_a_b][ret]

         call [ebx+3*4]  ; printf(format, max_a_b);
         add esp, 4      ; esp = esp + 4

;        esp -> [max_a_b][min_a_b][ret]

         pop eax  ; eax = max_a_b

;        esp -> [min_a_b][ret]

         pop ecx  ; ecx = min_a_b

;        esp -> [ret]

         push eax

;        esp -> [max_a_b][ret]

         push ecx

;        esp -> [min_a_b][max_a_b][ret]

         push edi
         
;        esp -> [width_max_a_b][min_a_b][max_a_b][ret]

         call getaddrminab
formatminab:
         db "+ %*d", 0xA, 0
getaddrminab:

;        esp -> [format][width_max_a_b][min_a_b][max_a_b][ret]

         call [ebx+3*4]  ; printf(format, width_max_a_b, min_a_b);
         add esp, 4    ; esp = esp + 4

;        esp -> [width_max_a_b][min_a_b][max_a_b][ret]

         mov ecx, [esp]  ; ecx = *(int*)esp = width_max_a_b

         add ecx, 2  ; ecx = ecx + 2

         call getaddrdash

formatdash:
         db "-", 0
getaddrdash:

;        esp -> [format][width_max_a_b][min_a_b][max_a_b][ret]

loop3    mov edi, ecx  ; edi = ecx  ; store counter

         call [ebx+3*4]  ; printf(format);
         
         mov ecx, edi   ; restore counter

         loop loop3  ; ecx = ecx - 1  ; jmp loop3

         add esp, 4  ; esp = esp + 4

;        esp -> [width_max_a_b][min_a_b][max_a_b][ret]

         mov eax, [esp+4]  ; eax = *(int*)(esp+4)
         mov edx, [esp+8]  ; edx = *(int*)(esp+8)

         add eax, edx  ; eax = eax + edx

         pop edx  ; edx <- stack = width_max_a_b

;        esp -> [min_a_b][max_a_b][ret]

         add edx, 1  ; edx = edx + 1

         push eax

;        esp -> [a+b][min_a_b][max_a_b][ret]

         push edx

;        esp -> [width_max_a_b][a+b][min_a_b][max_a_b][ret]

         call getaddrresult

formatresult:
         db 0xA, " %*d", 0xA, 0
getaddrresult:

;        esp -> [format][width_max_a_b][a+b][min_a_b][max_a_b][ret]

         call [ebx+3*4]  ; printf(format, width_max_a_b, a+b);
         add esp, 5*4    ; esp = esp + 20

;        esp -> [ret]

         push 0           ; esp -> [0][ret]
         call [ebx+0*4]   ; exit(0);
         


         
log10:

;        esp -> [ret][ ][max_a_b][min_a_b][ret]

;        setup fpu rounding mode to up

         call getup
up     dw 0x0800
getup:

;        esp -> [addr_up][ret][ ][max_a_b][min_a_b][ret]

         call getold
old      dw 0
getold:

;        esp -> [addr_old][addr_up][ret][ ][max_a_b][min_a_b][ret]

         mov eax, [esp]  ; eax = *(int*)esp

         fstcw [eax]  ; *(int*)eax = fpu_control_word

         mov edx, [eax]  ; edx = *(int*)eax

         mov ecx, [esp+4]  ; ecx = *(int*)(esp + 4) = addr_up

         mov ecx, [ecx]  ; ecx = *(int*)eax = up

         or edx, ecx  ; eax = eax | ecx

         mov [eax], edx  ; *(int*)eax = edx

         fldcw [eax]  ; load fpu control word

         add esp, 8  ; esp = esp + 8

;        esp -> [ret][ ][max_a_b][min_a_b][ret]
         
;        helper for input

         call getaddr2
input    dd 0
getaddr2:

;                           +4   +8 +12
;        esp -> [addr_input][ret][ ][max_a_b][min_a_b][ret]

         mov eax, [esp+12]  ; eax = *(int*)(esp + 12) = max_a_b

         mov ecx, [esp]  ; ecx = *(int*)esp = addr_input

         mov [ecx], eax  ; *(int*)ecx = eax  ; *input = max_a_b

         mov eax, [esp]  ; eax = *(int*)esp = addr_input

         fld1  ; 1 -> st ; fpu load floating-point: 1

;        st = [st0] = [1]

         fild dword [eax]  ; *(int*)(eax) = *(int*) addr_input = input -> st ; fpu load floating-point

;        st = [st0, st1] = [max_a_b, 1] ; fpu stack

         fyl2x  ; [st0, st1] => [st0, st1*log2(st0)] => [st1*log2(st0)]

;        st = [st1*(log2(st0)] = [1*log2(max_a_b)]

         fldlg2  ; log10(2) -> st  ; fpu load log10(2)

;        st = [st0, st1] = [log10(2), log2(max_a_b)]

         fmulp st1  ; [st0, st1] => [st0, st0*st1] => [st0*st1]

;        st = [st0] = [log10(2)*log2(max_a_b)]

         add esp, 4  ; esp = esp + 4

;        esp -> [ret][ ][max_a_b][min_a_b][ret]

         fistp dword [esp+4]  ; *(int*)(esp+4) <- st = [log10(2)*log2(max_a_b)]  ; fpu store top element and pop fpu stack

;        esp -> [ret][log10(max_a_b)][max_a_b][min_a_b][ret]

         ret

; asmloader API
;
; ESP wskazuje na prawidlowy stos
; argumenty funkcji wrzucamy na stos
; EBX zawiera pointer na tablice API
;
; call [ebx + NR_FUNKCJI*4] ; wywolanie funkcji API
;
; NR_FUNKCJI:
;
; 0 - exit
; 1 - putchar
; 2 - getchar
; 3 - printf
; 4 - scanf
;
; To co funkcja zwróci jest w EAX.
; Po wywolaniu funkcji sciagamy argumenty ze stosu.
;
; https://gynvael.coldwind.pl/?id=387

%ifdef COMMENT

ebx    -> [ ][ ][ ][ ] -> exit
ebx+4  -> [ ][ ][ ][ ] -> putchar
ebx+8  -> [ ][ ][ ][ ] -> getchar
ebx+12 -> [ ][ ][ ][ ] -> printf
ebx+16 -> [ ][ ][ ][ ] -> scanf

%endif
