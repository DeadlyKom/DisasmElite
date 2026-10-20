                module Flight
                module PrintMessageAfterMetadataReset
; -----------------------------------------
; Печать токена после сброса объектных метаданных
; исходный диапазон #9381..#9388
; In:
;   AF, A токен второй таблицы
; Out:
;   F9AB сбрасывает метаданные, затем D039 печатает сохранённый токен
; Corrupt:
;   HL, DE, BC, AF
; Note:
;   PUSH/POP AF сохраняет номер сообщения вокруг F9AB, используется надписью гибели
; -----------------------------------------
                ASSERT $ == #9381
                ; сохранение токена вокруг сброса метаданных объектов
Entry:          PUSH AF
                CALL Game.Extensions.ResetObjectMetadata.Entry
                POP AF
                JP Game.Interface.DispatchDescriptionToken.Entry
                ASSERT $ == #9389
                endmodule
                endmodule
