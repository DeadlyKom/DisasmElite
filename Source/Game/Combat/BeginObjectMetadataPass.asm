                module Combat
                module BeginObjectMetadataPass
; -----------------------------------------
; сохранение числа кораблей и начало обхода метаданных
; исходный диапазон #B712..#B71B
; In:
;   AF, A содержит число управляемых обычных кораблей
; Out:
;   HL, первая запись ObjectEffects.Records
;   память ActiveShips/ObjectEffects.Current обновлена
; Corrupt:
;   нет дополнительных регистров
; Note:
; Восемь основных слотов обходятся параллельно десятибайтовым расширенным записям.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #B712
                ; сохранение числа кораблей и установка первой записи метаданных
Entry:          LD (ActiveShips), A
                LD HL, ObjectEffects.Records
                LD (ObjectEffects.Current), HL
                RET

                ; проверка исходного конца фрагмента
                ASSERT $ == #B71C
                endmodule
                endmodule
