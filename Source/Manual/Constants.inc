; исходные адреса ROM, системных переменных и данных просмотрщика
ROM_CLS         EQU #0DAF
ROM_CHAN_OPEN   EQU #1601
TRDOS_COMMAND   EQU #3D03
KEY_RECORD      EQU #5C04
CHARS           EQU #5C36
CH_ADD          EQU #5C5D
DF_SZ           EQU #5C6B
IRQ_VECTOR      EQU #5CFF
TEXT_SENTINEL   EQU #9FFE
TEXT_BEGIN      EQU #A000
CODE_BASE       EQU #9648
CODE_SIZE       EQU #0512
PACK_BASE       EQU #C9BC
PACK_SIZE       EQU #3644
FONT_SIZE       EQU #0300
FILE_SIZE       EQU #4172

TEXT_DICTIONARY EQU #FF80                                                       ; 64 пары символов в конце упакованного файла

; исходные указатели, размещение памяти не изменяется
BOOT_STACK      EQU Memory.Attributes + #0400                                   ; временный стек переноса, верхняя граница исходной области #5B00..#5BFF
STACK_TOP       EQU #0000                                                       ; верх памяти с 16-битным оборотом, первый PUSH записывает #FFFE/#FFFF
ROM_FONT        EQU #3C00                                                       ; исходная база CHARS стандартного шрифта ПЗУ
VIEW_TOP        EQU Memory.Screen + #0040                                       ; левая граница растровой строки 16, верх окна
VIEW_NEXT       EQU VIEW_TOP + #0100                                            ; растровая строка 17, источник сдвига вверх на один пиксель
VIEW_BOTTOM     EQU Memory.Screen + #1780                                       ; левая граница растровой строки 167, низ окна
VIEW_PREV       EQU VIEW_BOTTOM - #0100                                         ; растровая строка 166, источник сдвига вниз на один пиксель
EDGE_BOTTOM     EQU Memory.Screen + #10A0                                       ; растровая строка 168, новый нижний край перед сдвигом вверх
EDGE_NEXT       EQU EDGE_BOTTOM + #0100                                         ; растровая строка 169, второй нижний срез при двойном шаге
EDGE_TOP        EQU Memory.Screen + #0720                                       ; растровая строка 15, новый верхний край перед сдвигом вниз
EDGE_PREV       EQU EDGE_TOP - #0100                                            ; растровая строка 14, второй верхний срез при двойном шаге
SPEED_ATTR      EQU Memory.Attributes + 23 * 32                                 ; атрибутная строка 23, индикатор скорости прокрутки
PACK_LAST       EQU PACK_BASE + PACK_SIZE - 1                                   ; последний байт назначения LDDR, конец упакованного текста и словаря
