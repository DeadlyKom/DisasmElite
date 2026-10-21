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
; Game.Extensions.GetViewAdjustedProjectedPoint.Entry и Game.Extensions.StorePairedObjectDirections.Entry обслуживают расширенные данные вывода.
; OBJ_LASER_BIT в FSpaceObject.Flags задаёт условие луча, Game.Extensions.StorePairedObjectDirections.Entry сохраняет флаги
; При наличии луча общий хвост Game.Wireframe.DrawWireframeObject.DrawLaser берёт лазерную вершину модели и рисует линию.
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
