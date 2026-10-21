                module Text
                module ApplyTextCase
; -----------------------------------------
; Выбор регистра букв перед рисованием символа
; исходный диапазон #D499..#D4E0
; In:
;   AF, A = символ, LetterCase, WordStart и CapitalNext = режимы регистра
; Out:
;   A преобразован и управление передано Game.Text.DrawCharacter8x8.Entry
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   Для A..Z режим LetterCase=1 сохраняет верхний регистр, CapitalNext однократно сохраняет заглавную и
;   сбрасывает себя, WordStart отмечает начало слова, иначе прибавляется 20, любой небуквенный символ
;   ставит WordStart=1, проверка TextMode после Game.Text.ApplyTextCase.EmitCharacter в этой версии нейтрализована NOP
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
                POP AF                                                          ; далее Game.Text.DrawCharacter8x8.Entry без команды перехода
                ; проверка исходного конца фрагмента
                ASSERT $ == #D4E1
                endmodule
                endmodule
