                module Text
                module ApplyTextCase
; -----------------------------------------
; Выбор регистра букв перед рисованием символа
; исходный диапазон #D499..#D4E0
; In:
;   AF, A = символ, D0D1..D0D3 = режимы регистра
; Out:
;   A преобразован и управление передано D4E1
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Для A..Z режим D0D1=1 сохраняет верхний регистр, D0D3 однократно сохраняет заглавную и
;   сбрасывает себя, D0D2 отмечает начало слова, иначе прибавляется 20, любой небуквенный символ
;   ставит D0D2=1, проверка D0D4 после D4D8 в этой версии нейтрализована NOP
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #D499
                ; регистр преобразуется только для ASCII A..Z, прочие символы не меняются
Entry:          CP #41
                JR C, MarkWordStart                                             ; переход, если код меньше A, преобразование регистра букв не применяется

                CP #5B
                JR NC, MarkWordStart                                            ; переход, если код не меньше [, преобразование регистра букв не применяется

                ; выбор регистра по постоянному режиму и одноразовому признаку заглавной буквы
                PUSH AF
                LD A, (LetterCase)
                CP #01
                JR Z, EmitCharacter                                             ; переход, если режим регистра равен 1, оставить заглавную букву

                LD A, (CapitalNext)
                AND A
                JR Z, CheckWordStart                                            ; переход, если одноразовый признак заглавной буквы отсутствует, проверить состояние слова

                XOR A
                LD (CapitalNext), A
                LD (WordStart), A
                JR EmitCharacter

CheckWordStart: LD A, (WordStart)
                CP #01
                JR NZ, Lowercase                                                ; переход, если состояние границы слова не равно 1, применить строчный регистр

                XOR A
                LD (WordStart), A
                LD A, (LetterCase)
                CP #02
                JR Z, Lowercase                                                 ; переход, если режим регистра равен 2, первую букву также сделать строчной

                JR EmitCharacter

Lowercase:      POP AF
                ADD A, #20
                PUSH AF
                JR EmitCharacter

MarkWordStart:  PUSH AF
                LD A, #01
                LD (WordStart), A
EmitCharacter:  LD A, (TextMode)
                CP #01
                NOP
                NOP
                NOP
                POP AF
                ; проверка исходного конца фрагмента
                ASSERT $ == #D4E1
                endmodule
                endmodule
