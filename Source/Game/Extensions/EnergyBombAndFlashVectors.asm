                module Extensions
                module EnergyBombAndFlashVectors
; -----------------------------------------
; векторы энергетической бомбы и вспышки атрибутов
; исходный диапазон #6FF2..#6FF7
; смысловое имя EnergyBombAndFlashVectors
; In: параметры соответствующих обработчиков Game.Extensions.AttributeVectorAndEnergyBomb.UseEnergyBomb и Game.Extensions.FlashViewAttributes.Entry
; Out: хвостовой переход без дополнительного адреса возврата
; Corrupt: по контрактам целевых обработчиков
; Game.Extensions.EnergyBombAndFlashVectors.Entry вызывается обработчиком оружия Game.Combat.ProcessCombatControls.Entry и ведёт к энергетической бомбе
; после первого JP сохранён отдельный переход в Game.Extensions.FlashViewAttributes.Entry, прямых входящих вызовов не найдено
; Отсутствие найденного вызова не меняет доказанной семантики трёх байтов вектора, целевой эффект вызывается также напрямую из Game.Extensions.AttributeVectorAndEnergyBomb.FlashAgain
; -----------------------------------------
                ; проверка исходного начала фрагмента
                ASSERT $ == #6FF2
                ; передача управления обработчику энергетической бомбы
Entry:          JP Game.Extensions.AttributeVectorAndEnergyBomb.UseEnergyBomb

                ; дополнительный вектор двухфазного мигания атрибутов
                JP Game.Extensions.FlashViewAttributes.Entry

                ; проверка исходного конца фрагмента
                ASSERT $ == #6FF8
                endmodule
                endmodule
