                ifndef _LOADER_BASIC_
                define _LOADER_BASIC_
; -----------------------------------------
; исходная токенизированная строка BASIC 10, запускающая машинный загрузчик
; PAPER NOT PI, INK VAL "7", BORDER NOT PI, CLS
; RANDOMIZE USR (PEEK VAL "23635" + VAL "256" * PEEK VAL "23636" + VAL "5")
; после возврата выводится сообщение об отсутствии ELITE3.C
; Note:
;   строка REM 0 намеренно не завершается байтом #0D
;   её граница задаётся длиной #011A в заголовке, байты оригинала сохранены
;   #AF внутри сообщения также сохранён как исходный байт
; -----------------------------------------
BasicLine:      DB #00, #0A                                                     ; номер строки BASIC 10
                DW #005F                                                        ; длина тела строки вместе с #0D
                DB #DA, #C3, #A7, #3A                                           ; PAPER NOT PI
                DB #D9, #B0, #22, "7", #22, #3A                                 ; INK VAL "7"
                DB #E7, #C3, #A7, #3A                                           ; BORDER NOT PI
                DB #FB, #3A                                                     ; CLS
                DB #F9, #C0, #28, #BE, #B0, #22, "23635", #22, #2B              ; RANDOMIZE USR (PEEK VAL "23635" +
                DB #B0, #22, "256", #22, #2A, #BE, #B0, #22, "23636", #22, #2B  ; VAL "256" * PEEK VAL "23636" +
                DB #B0, #22, "5", #22, #29, #3A                                 ; VAL "5")
                DB #FB, #3A                                                     ; CLS
                DB #F5, #AC, #B0, #22, "11", #22, #2C                           ; PRINT AT VAL "11",
                DB #B0, #22, "1", #22, #3B                                      ; VAL "1" и разделитель вывода
                DB #22, "File ''ELITE3''", #AF, "not found", #22
                DB #0D                                                          ; конец строки BASIC

                endif                                                           ; ~_LOADER_BASIC_
