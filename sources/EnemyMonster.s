; EnemyMonster.s : モンスター
;


; モジュール宣言
;
    .module Enemy

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include    "Stage.inc"
    .include    "Bomb.inc"
    .include    "Character.inc"
    .include    "Player.inc"
    .include	"Enemy.inc"

; 外部変数宣言
;

; マクロの定義
;
ENEMY_MONSTER_LIMIT_LEFT        =   0x20
ENEMY_MONSTER_LIMIT_RIGHT       =   0xe4
ENEMY_MONSTER_LIMIT_NEAR        =   0x30
ENEMY_MONSTER_LIFE_MAXIMUM      =   0x0100
ENEMY_MONSTER_LIFE_ATTACK       =   0x04


; CODE 領域
;
    .area   _CODE

; エネミーを登場させる
;
_EnemyMonsterSpawn::
    
    ; レジスタの保存

    ; ix < エネミー
    ; de < Y/X 位置
    
    ; エネミーの初期化
    push    bc
    push    de
    ld      hl, #enemyMonsterDefault
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    pop     de
    pop     bc

    ; 位置の設定
    ld      CHARACTER_POSITION_X_H(ix), e
    ld      CHARACTER_POSITION_Y_H(ix), d

    ; ENEMY_THINK_0 : 照準

    ; ENEMY_THINK_1 : 発射回数

    ; ENEMY_THINK_2 : 砲口

    ; ENEMY_THINK_6-7 : ライフ

    ; カウントの更新
    call    _EnemyIncCount

    ; パターンの作成
    ld      bc, #((0x10 << 8) | 0x40)
    call    _EnemyBuildPattern8x8

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーが歩く
;
EnemyMonsterWalk:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; ENEMY_THINK_6-7 : ライフ
    ld      a, CHARACTER_LIFE_L(ix)
    ld      ENEMY_THINK_6(ix), a
    ld      a, CHARACTER_LIFE_H(ix)
    ld      ENEMY_THINK_7(ix), a

    ; アニメーションの開始
    ld      hl, #enemyMonsterAnimationStandBy
    call    _CharacterStartAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

;   ; プレイの監視
;   call    _GameIsPlay
;   jr      nc, 190$

    ; アニメーションの監視
    call    _CharacterIsDoneAnimation
    jr      nc, 190$

    ; ライフの確認
    ld      l, ENEMY_THINK_6(ix)
    ld      h, ENEMY_THINK_7(ix)
    ld      e, CHARACTER_LIFE_L(ix)
    ld      d, CHARACTER_LIFE_H(ix)
    or      a
    sbc     hl, de
    ld      de, #ENEMY_MONSTER_LIFE_ATTACK
    or      a
    sbc     hl, de
    jr      nc, 180$

    ; 位置の確認
    call    _PlayerGetPosition
    ld      a, CHARACTER_POSITION_X_H(ix)
    cp      #ENEMY_MONSTER_LIMIT_RIGHT
    jr      nc, 170$
    cp      #(ENEMY_MONSTER_LIMIT_LEFT + 0x01)
    jr      c, 171$
    sub     e
    jr      c, 171$
    bit     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    jr      z, 170$
    cp      #ENEMY_MONSTER_LIMIT_NEAR
    jr      c, 171$
;   jr      170$

    ; 移動
170$:
    res     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    ld      hl, #enemyMonsterAnimationWalkLeft
    call    _CharacterStartAnimation
    jr      190$
171$:
    set     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    ld      hl, #enemyMonsterAnimationWalkRight
    call    _CharacterStartAnimation
    jr      190$

    ; 攻撃
180$:
    ld      hl, #EnemyMonsterFire
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
;   jr      190$

    ; 歩くの完了
190$:

    ; アニメーションの更新
    call    _CharacterUpdateAnimation

    ; 位置の調整
    ld      a, CHARACTER_POSITION_X_H(ix)
    cp      #ENEMY_MONSTER_LIMIT_LEFT
    jr      nc, 80$
    ld      CHARACTER_POSITION_X_H(ix), #ENEMY_MONSTER_LIMIT_LEFT
    ld      CHARACTER_POSITION_X_L(ix), #0x00
    jr      89$
80$:
    cp      #ENEMY_MONSTER_LIMIT_RIGHT
    jr      c, 89$
    ld      CHARACTER_POSITION_X_H(ix), #ENEMY_MONSTER_LIMIT_RIGHT
    ld      CHARACTER_POSITION_X_L(ix), #0x00
;   jr      89$
89$:

    ; 終了
    ret

; エネミーが発射する
;
EnemyMonsterFire:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; ENEMY_THINK_0 : 照準
    ; ENEMY_THINK_1 : 発射回数
    call    _SystemGetRandom
    and     #0x10
    jr      nz, 01$
    ld      ENEMY_THINK_0(ix), #ENEMY_AIM_0900
    call    _SystemGetRandom
    and     #0x03
    jr      nz, 00$
    inc     a
00$:
    add     a, #(0x02 + 0x01)
    ld      ENEMY_THINK_1(ix), a
    jr      02$
01$:
    ld      ENEMY_THINK_0(ix), #ENEMY_AIM_1030
    ld      ENEMY_THINK_1(ix), #(0x07 + 0x01)
02$:

    ; ENEMY_THINK_2 : 砲口
    ld      ENEMY_THINK_2(ix), #0x00

    ; アニメーションの開始
    ld      hl, #enemyMonsterAnimationAim
    call    _CharacterStartAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; アニメーションの監視
    call    _CharacterIsDoneAnimation
    jr      nc, 190$

    ; 発射回数の更新
    ld      a, ENEMY_THINK_1(ix)
    or      a
    jr      z, 180$
    dec     ENEMY_THINK_1(ix)
    jr      z, 170$

    ; ミサイルの発射
    ld      a, ENEMY_THINK_0(ix)
    cp      #ENEMY_AIM_0900
    jr      nz, 111$

    ; 水平に発射
110$:
    ld      a, ENEMY_THINK_2(ix)
    and     #0x01
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyMonsterMuzzle_0900
    add     hl, de
    ld      a, #ENEMY_AIM_0900
    call    _EnemyFireHorizontal
    ld      hl, #enemyMonsterAnimationFire_0900
    jr      119$

    ; 斜めに発射
111$:
    ld      a, ENEMY_THINK_2(ix)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #(enemyMonsterMuzzle_1030 - ENEMY_AIM_1030 * 0x0002)
    add     hl, de
    ld      a, #ENEMY_AIM_1030
    call    _EnemyFireHoming
    ld      hl, #enemyMonsterAnimationFire_1030
;   jr      119$

    ; アニメーションの開始
119$:
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ex      de, hl
    call    _CharacterStartAnimation
    inc     ENEMY_THINK_2(ix)
    jr      190$

    ; 構えを直す
170$:
    ld      hl, #enemyMonsterAnimationFix
    call    _CharacterStartAnimation
    jr      190$

    ; 処理の更新
180$:
    ld      hl, #EnemyMonsterWalk
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
;   jr      190$

    ; 発射の完了
190$:

    ; アニメーションの更新
    call    _CharacterUpdateAnimation
    
    ; 終了
    ret

; エネミーが死亡する
;
EnemyMonsterDead:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; 点滅の設定
    ld      CHARACTER_BLINK(ix), #0x60

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; 点滅の監視
    ld      a, CHARACTER_BLINK(ix)
    sub     #(CHARACTER_BLINK_INTERVAL - 0x01)
    jr      nz, 19$

    ; 処理の更新
;   xor     a
    ld      CHARACTER_PROC_L(ix), a
    ld      CHARACTER_PROC_H(ix), a
    ld      CHARACTER_STATE(ix), a

    ; カウントの更新
    call    _EnemyDecCount
;   jr      19$

    ; 死亡の完了
19$:

    ; 爆発
    ld      a, CHARACTER_BLINK(ix)
    and     #0x03
    jr      nz, 29$
    call    _SystemGetRandom
    and     #0x3f
    sub     #0x20
    jr      nc, 20$
    neg
    ld      e, a
    ld      a, CHARACTER_POSITION_X_H(ix)
    sub     e
    jr      c, 29$
    jr      21$
20$:
    add     a, CHARACTER_POSITION_X_H(ix)
    jr      c, 29$
21$:
    ld      e, a
    call    _SystemGetRandom
    and     #0x3f
    sub     CHARACTER_POSITION_Y_H(ix)
    neg
    ld      d, a
    call    _BombEntry
29$:

    ; 終了
    ret

; 定数の定義
;

; エネミーの初期値
;
enemyMonsterDefault:

    .dw     EnemyMonsterWalk
    .db     CHARACTER_STATE_NULL
    .db     ENEMY_FLAG_COUNT ; CHARACTER_FLAG_NULL
    .dw     CHARACTER_POSITION_NULL
    .dw     CHARACTER_POSITION_NULL
    .dw     CHARACTER_SPEED_NULL
    .dw     CHARACTER_SPEED_NULL
    .db     0x40 ; CHARACTER_RECT_NULL
    .db     0x38 ; CHARACTER_RECT_NULL
    .db     CHARACTER_RECT_NULL
    .db     CHARACTER_RECT_NULL
    .db     CHARACTER_RECT_NULL
    .db     CHARACTER_RECT_NULL
    .db     CHARACTER_RECT_NULL
    .db     CHARACTER_RECT_NULL
    .dw     CHARACTER_ANIMATION_NULL
    .db     0x00 ; CHARACTER_ANIMATION_NULL
    .db     CHARACTER_ANIMATION_NULL
    .db     CHARACTER_BLINK_NULL
    .db     CHARACTER_HIT_NULL
    .db     CHARACTER_HIT_NULL
    .db     CHARACTER_HIT_NULL
    .db     CHARACTER_HIT_NULL
    .dw     ENEMY_MONSTER_LIFE_MAXIMUM ; CHARACTER_LIFE_NULL
    .dw     EnemyMonsterDead ; ENEMY_DEAD_NULL
    .dw     _EnemyPrintPattern8x8 ; ENEMY_PRINT_NULL
    .dw     _EnemyErasePattern8x8 ; ENEMY_ERASE_NULL
    .dw     ENEMY_STAGE_NULL
    .db     ENEMY_THINK_NULL
    .db     ENEMY_THINK_NULL
    .db     ENEMY_THINK_NULL
    .db     ENEMY_THINK_NULL
    .db     ENEMY_THINK_NULL
    .db     ENEMY_THINK_NULL
    .db     ENEMY_THINK_NULL
    .db     ENEMY_THINK_NULL

; 砲口
;
enemyMonsterMuzzle_0900:

    .db     -0x18, -0x16
    .db     -0x10, -0x0e

enemyMonsterMuzzle_1030:

    .db      0x0c, -0x37
    .db      0x08, -0x33
    .db      0x04, -0x2f
    .db      0x08, -0x33
    .db      0x0c, -0x37
    .db      0x08, -0x33
    .db      0x04, -0x2f

; アニメーション
;
enemyMonsterAnimationIdle:

    .db     0xff,  0x00, -0x3f - 0x00, -0x20, 0x00, SOUND_SE_NULL

enemyMonsterAnimationStandBy:

    .db     0x18,  0x00, -0x3f - 0x00, -0x20, 0x00, SOUND_SE_NULL
    .db     0x00

enemyMonsterAnimationWalkLeft:

    .db     0x18, -0x04, -0x3f - 0x00, -0x20, 0x01, SOUND_SE_NULL
    .db     0x18, -0x04, -0x3f - 0x00, -0x20, 0x02, SOUND_SE_NULL
    .db     0x18, -0x04, -0x3f - 0x00, -0x20, 0x03, SOUND_SE_NULL
    .db     0x18, -0x04, -0x3f - 0x00, -0x20, 0x00, SOUND_SE_NULL
    .db     0x00

enemyMonsterAnimationWalkRight:

    .db     0x18,  0x04, -0x3f - 0x00, -0x20, 0x03, SOUND_SE_NULL
    .db     0x18,  0x04, -0x3f - 0x00, -0x20, 0x02, SOUND_SE_NULL
    .db     0x18,  0x04, -0x3f - 0x00, -0x20, 0x01, SOUND_SE_NULL
    .db     0x18,  0x04, -0x3f - 0x00, -0x20, 0x00, SOUND_SE_NULL
    .db     0x00

enemyMonsterAnimationAim:

    .db     0x18,  0x00, -0x3f - 0x00, -0x20, 0x08, SOUND_SE_NULL
    .db     0x00

enemyMonsterAnimationFire_0900:

    .dw     enemyMonsterAnimationFire_0900_0
    .dw     enemyMonsterAnimationFire_0900_1

enemyMonsterAnimationFire_0900_0:

    .db     0x04,  0x00, -0x3f - 0x00, -0x20, 0x09, SOUND_SE_NULL
    .db     0x0c,  0x00, -0x3f - 0x00, -0x20, 0x08, SOUND_SE_NULL
    .db     0x00

enemyMonsterAnimationFire_0900_1:

    .db     0x04,  0x00, -0x3f - 0x00, -0x20, 0x0a, SOUND_SE_NULL
    .db     0x0c,  0x00, -0x3f - 0x00, -0x20, 0x08, SOUND_SE_NULL
    .db     0x00

enemyMonsterAnimationFire_1030:

    .dw     enemyMonsterAnimationFire_1030_0
    .dw     enemyMonsterAnimationFire_1030_1
    .dw     enemyMonsterAnimationFire_1030_2
    .dw     enemyMonsterAnimationFire_1030_1
    .dw     enemyMonsterAnimationFire_1030_0
    .dw     enemyMonsterAnimationFire_1030_1
    .dw     enemyMonsterAnimationFire_1030_2

enemyMonsterAnimationFire_1030_0:

    .db     0x04,  0x00, -0x3f - 0x00, -0x20, 0x0b, SOUND_SE_NULL
    .db     0x0c,  0x00, -0x3f - 0x00, -0x20, 0x08, SOUND_SE_NULL
    .db     0x00

enemyMonsterAnimationFire_1030_1:

    .db     0x04,  0x00, -0x3f - 0x00, -0x20, 0x0c, SOUND_SE_NULL
    .db     0x0c,  0x00, -0x3f - 0x00, -0x20, 0x08, SOUND_SE_NULL
    .db     0x00

enemyMonsterAnimationFire_1030_2:

    .db     0x04,  0x00, -0x3f - 0x00, -0x20, 0x0d, SOUND_SE_NULL
    .db     0x0c,  0x00, -0x3f - 0x00, -0x20, 0x08, SOUND_SE_NULL
    .db     0x00

enemyMonsterAnimationFix:

    .db     0x18,  0x00, -0x3f - 0x00, -0x20, 0x08, SOUND_SE_NULL
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

