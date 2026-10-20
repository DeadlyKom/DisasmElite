                ifndef _CONST_CONTROL_
                define _CONST_CONTROL_

INPUT_SND_BIT   EQU 7                                                           ; флаг, разрешён звук
INPUT_MJ_BIT    EQU 6                                                           ; флаг, выход в межзвёздное пространство
INPUT_INVY_BIT  EQU 5                                                           ; флаг, перестановка направлений тангажа
INPUT_INV_BIT   EQU 4                                                           ; флаг, перестановка направлений обеих осей
INPUT_BRAKE_BIT EQU 3                                                           ; флаг, торможение отпущенной оси
INPUT_STOP_BIT  EQU 2                                                           ; флаг, остановка при противоположной команде
INPUT_MODE_MASK EQU #03                                                         ; двухбитовый номер источника направлений
INPUT_NO_KEY    EQU #FF                                                         ; нет нажатой клавиши
INPUT_ZERO_KEY  EQU #FE                                                         ; сочетание клавиши 0 и CAPS SHIFT

                endif                                                           ; ~_CONST_CONTROL_
