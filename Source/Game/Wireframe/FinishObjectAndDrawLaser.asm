                module Wireframe
                module FinishObjectAndDrawLaser
; -----------------------------------------
; завершение вывода объекта и условный вывод его лазерного луча
; исходный диапазон #A8DE..#A8EB
; In:
;   IX, объект
;   IY, модель объекта
; Out:
;   графический буфер и расширенные метаданные обновлены
; Corrupt:
;   HL, DE, BC, AF
; Note:
; F945 и F92D обслуживают расширенные данные вывода.
; BIT 3,(IX+20) задаёт условие луча, F92D сохраняет флаги.
; При наличии луча общий хвост #A884 берёт лазерную вершину модели и рисует линию.
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #A8DE
                ; обновление расширенных параметров вывода и проверка лазерного флага
Entry:          CALL Game.Extensions.GetViewAdjustedProjectedPoint.Entry
                BIT OBJ_LASER_BIT, (IX + FSpaceObject.Flags)
                CALL Game.Extensions.StorePairedObjectDirections.Entry
                RET Z                                                           ; выход, если у объекта не установлен признак лазерного луча

                JP Game.Wireframe.DrawWireframeObject.DrawLaser
                ; проверка исходного конца фрагмента
                ASSERT $ == #A8EC
                endmodule
                endmodule
