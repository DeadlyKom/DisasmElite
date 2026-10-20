"""Проверенные замены битов ввода, очереди сообщений и звука, без сборки."""
from pathlib import Path
import json

ROOT = Path(__file__).resolve().parents[3]
plans = []


def replace(file, mapping):
    path = ROOT / 'Source/Game' / (file + '.asm')
    found = dict.fromkeys(mapping, 0)
    for n, line in enumerate(path.read_text(encoding='utf-8-sig').splitlines(), 1):
        code, sep, comment = line.partition(';')
        new = code
        for old, value in mapping.items():
            if old in new:
                found[old] += new.count(old)
                new = new.replace(old, value)
        if new != code:
            if sep:
                new = new.rstrip().ljust(80) + ';' + comment
            plans.append(dict(file=path.relative_to(ROOT).as_posix(), line=n, old=line, new=new.rstrip()))
    assert all(found.values()), (file, found)


replace('Input/IntegrateFlightControls', {'BIT 0,B':'BIT FLY_ROLL_N_BIT,B', 'BIT 1,B':'BIT FLY_ROLL_P_BIT,B', 'BIT 2,B':'BIT FLY_PITCH_N_BIT,B', 'BIT 3,B':'BIT FLY_PITCH_P_BIT,B', 'BIT 4,B':'BIT FLY_SPEED_BIT,B', 'BIT 5,B':'BIT FLY_BRAKE_BIT,B', 'BIT 3,C':'BIT INPUT_BRAKE_BIT,C', 'BIT 2,C':'BIT INPUT_STOP_BIT,C'})
replace('Input/InterruptGateAndAcceleration', {'BIT 5,B':'BIT FLY_BRAKE_BIT,B'})
replace('Input/ResetDemoAndNormalizeControls', {'BIT 6,(HL)':'BIT SYS_0_BIT,(HL)', 'RES 6,(HL)':'RES SYS_0_BIT,(HL)', 'SET 0,(HL)':'SET DEV_FIRE_BIT,(HL)', 'BIT 4,E':'BIT INPUT_INV_BIT,E', 'BIT 5,E':'BIT INPUT_INVY_BIT,E', 'AND #05':'AND FLY_NEG_MASK', 'AND #0A':'AND FLY_POS_MASK', 'AND #0C':'AND FLY_PITCH_MASK', 'AND #F0':'AND FLY_AUX_MASK', 'AND #80':'AND 1 << VIEW_PAUSE_BIT', 'LD A,#FE':'LD A,INPUT_ZERO_KEY'})
path = ROOT / 'Source/Game/Input/ResetDemoAndNormalizeControls.asm'
lines = path.read_text(encoding='utf-8-sig').splitlines()
for n, old, new in [(94,'AND #03','AND FLY_ROLL_MASK'), (108,'AND #03','AND INPUT_MODE_MASK'), (117,'RES 7,(HL)','RES VIEW_PAUSE_BIT,(HL)'), (119,'RES 2,(HL)','RES DEV_LAUNCH_BIT,(HL)'), (120,'RES 7,(HL)','RES DEV_DOCK_BIT,(HL)')]:
    assert old in lines[n-1], (n, lines[n-1])
    plans.append(dict(file=path.relative_to(ROOT).as_posix(), line=n, old=lines[n-1], new=lines[n-1].replace(old,new)))
replace('Flight/ShowTitleAndSelectControls', {'BIT 1,(HL)':'BIT NUM_5_BIT,(HL)', 'BIT 3,(HL)':'BIT NUM_6_BIT,(HL)', 'AND #03':'AND INPUT_MODE_MASK'})
replace('Flight/MainGameLoop', {'BIT 5,A':'BIT FLY_BRAKE_BIT,A'})
replace('Flight/ToggleCloakingDevice', {'RES 7,(HL)':'RES SYS_Y_BIT,(HL)', 'BIT 7,(HL)':'BIT SYS_Y_BIT,(HL)'})
replace('Flight/HandleMapCursorKeys', {'AND #0F':'AND FLY_DIR_MASK', 'AND #70':'AND CHART_KEY_MASK'})
replace('Flight/HandlePauseMenu', {'AND #80':'AND 1 << VIEW_PAUSE_BIT'})
replace('Flight/TryAutomaticDocking', {'AND #80':'AND 1 << DEV_DOCK_BIT', 'RES 7,B':'RES DEV_DOCK_BIT,B'})
replace('Input/FinishKeyboardRowAndSelectJoystick', {'AND #03':'AND INPUT_MODE_MASK'})
replace('Universe/HandleFastTravelStep', {'BIT 6,A':'BIT VIEW_FAST_BIT,A', 'AND #BF':'AND VIEW_FAST_KEEP'})
replace('Travel/CommitJumpFuelAndMishap', {'BIT 6,A':'BIT INPUT_MJ_BIT,A'})
replace('Travel/ClearFlightEventsAndHandleJump', {'RES 7,(HL)':'RES EVENT_WAIT_BIT,(HL)', 'AND #30':'AND VIEW_JUMP_MASK', 'AND #CF':'AND #FF - VIEW_JUMP_MASK', 'BIT 5,B':'BIT VIEW_GALAX_BIT,B', 'BIT 4,B':'BIT VIEW_HYPER_BIT,B'})
replace('Travel/EmptyFuelWithWarning', {'SET 7,(HL)':'SET EVENT_WAIT_BIT,(HL)'})
replace('Travel/SelectQueuedFlightMessage', {'BIT 7,(HL)':'BIT EVENT_WAIT_BIT,(HL)', 'RES 7,(HL)':'RES EVENT_WAIT_BIT,(HL)'})
replace('Combat/FirePlayerLaser', {'BIT 0,(HL)':'BIT DEV_FIRE_BIT,(HL)', 'RES 0,(HL)':'RES DEV_FIRE_BIT,(HL)', 'SET 6,(HL)':'SET SND_HIT_BIT,(HL)', 'SET 3,(HL)':'SET SND_LASER_BIT,(HL)'})
replace('Combat/HandleEscapeCapsule', {'BIT 6,A':'BIT DEV_ESCAPE_BIT,A'})
replace('Combat/ProcessLaserAndEcm', {'RES 4,(HL)':'RES DEV_ECM_BIT,(HL)', 'SET 5,(HL)':'SET SND_ECM_BIT,(HL)'})
replace('Combat/ProcessCombatControls', {'AND #91':'AND DEV_KEEP_MASK'})
replace('Combat/HandleMissileControls', {'SET 7,(HL)':'SET EVENT_WAIT_BIT,(HL)', 'SET 1,(HL)':'SET SND_MISSILE_BIT,(HL)'})
replace('Combat/CreatePlayerWreckScene', {'SET 2,(HL)':'SET SND_BLAST_BIT,(HL)'})
replace('Combat/HandleObjectCollision', {'SET 6,(HL)':'SET SND_HIT_BIT,(HL)', 'SET 2,(HL)':'SET SND_BLAST_BIT,(HL)'})
replace('Sound/StepNoise', {'BIT 7,A':'BIT SND_REPEAT_BIT,A'})
replace('Objects/ActivateEnemyECM', {'BIT 4,B':'BIT DEV_ECM_BIT,B'})
replace('Extensions/AttributeVectorAndEnergyBomb', {'BIT 5,A':'BIT DEV_BOMB_BIT,A', 'SET 0,(HL)':'SET SND_BOMB_BIT,(HL)'})


def replace_line(file, n, old, new):
    path = ROOT / 'Source/Game' / (file + '.asm')
    text = path.read_text(encoding='utf-8-sig').splitlines()[n-1]
    assert old in text, (file, n, text)
    code, sep, comment = text.partition(';')
    code = code.replace(old, new)
    if sep:
        code = code.rstrip().ljust(80) + ';' + comment
    plans.append(dict(file=path.relative_to(ROOT).as_posix(), line=n, old=text, new=code.rstrip()))


replace_line('Missions/RatingBountyDamageAndNewCommander',59,'SET 7,(HL)','SET EVENT_WAIT_BIT,(HL)')
replace_line('Missions/RatingBountyDamageAndNewCommander',110,'SET 7,(HL)','SET DEVICE_SIGN_BIT,(HL)')
replace_line('Missions/RatingBountyDamageAndNewCommander',116,'SET 7,(HL)','SET EVENT_WAIT_BIT,(HL)')
replace_line('Combat/ReleaseMissileTargets',52,'SET 7,(HL)','SET EVENT_WAIT_BIT,(HL)')
replace_line('Motion/ProcessObjectEnergyAndTactics',119,'SET 7,(HL)','SET EVENT_WAIT_BIT,(HL)')
replace_line('Combat/UpdateAllSpaceObjects',167,'SET 2,(HL)','SET SND_BLAST_BIT,(HL)')
replace_line('Motion/SteerObjectAndTryLaser',172,'SET 6,(HL)','SET SND_HIT_BIT,(HL)')
replace_line('Trade/OptionalBeep',19,'BIT 7,A','BIT INPUT_SND_BIT,A')
replace_line('Galaxy/GenerateSystemName',29,'AND #40','AND 1 << SEED_LONG_BIT')
replace_line('Galaxy/DeriveSystemProperties',23,'AND #07','AND SEED_ECON_MASK')
replace_line('Galaxy/DeriveSystemProperties',33,'AND #07','AND SEED_GOV_MASK')
replace_line('Galaxy/DeriveSystemProperties',47,'AND #03','AND SEED_TECH_MASK')
replace_line('Galaxy/AppendSystemNameSyllable',21,'AND #1F','AND SEED_SYLL_MASK')

if __name__ == '__main__':
    target = ROOT / 'Tools/Disasm/Research/RuntimeFlagEdits.json'
    target.write_text(json.dumps(plans, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
    print(len(plans), 'замен в', len({p['file'] for p in plans}), 'файлах')
