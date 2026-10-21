                ifndef _VARIABLES_SOUND_
                define _VARIABLES_SOUND_

SoundState      EQU Game.Flight.ClearNearbyShipSlots.SoundData                  ; адрес структуры FSoundState
.Mode           EQU SoundState + FSoundState.Mode                               ; 0 тишина, 1 скользящий тон, 2 тон из данных, остальные значения шум
.Duration       EQU SoundState + FSoundState.Duration                           ; сохранённые DE, назначение D/E зависит от звукового режима
.DataCursor     EQU SoundState + FSoundState.DataCursor                         ; сохранённый HL, адрес следующего отсчёта либо параметр тона
SoundRequest    EQU Game.Sound.StartHyperjumpNoise.RequestIndex                 ; номер выбранного звукового запроса, 0..7
NoiseSamples    EQU Game.Sound.StepNoise.PacketSize                             ; изменяемый операнд LD C, число отсчётов шумового пакета
NoiseStep       EQU Game.Sound.StepNoise.PeriodStep                             ; изменяемый операнд ADD A, шаг задержки шумового пакета
ToneShift       EQU Game.Sound.StepDataTone.SampleShift                         ; изменяемая двухбайтовая команда преобразования отсчёта тона
PitchStep       EQU Game.Sound.StepPitchSweep.PeriodStep                        ; изменяемый операнд ADD A, шаг периода скользящего тона

NoiseRomData    EQU #0127                                                       ; исходные байты ПЗУ BASIC, проигрыватель использует их как шумовые отсчёты

                endif                                                           ; ~_VARIABLES_SOUND_
