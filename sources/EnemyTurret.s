; EnemyTurret.s : 砲塔
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
    .include    "Character.inc"
    .include    "Player.inc"
    .include	"Enemy.inc"

; 外部変数宣言
;

; マクロの定義
;
ENEMY_TURRET_LIFE_MAXIMUM       =   0x0018


; CODE 領域
;
    .area   _CODE

; エネミーを登場させる
;
_EnemyTurretSpawn::
    
    ; レジスタの保存

    ; ix < エネミー
    ; de < Y/X 位置
    ; c  < 照準
    ; b  < ディレイ
    
    ; エネミーの初期化
    push    bc
    push    de
    ld      hl, #enemyTurretDefault
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    pop     de
    pop     bc

    ; 位置の設定
    ld      CHARACTER_POSITION_X_H(ix), e
    ld      CHARACTER_POSITION_Y_H(ix), d

    ; ENEMY_THINK_0 : ディレイ
    ld      ENEMY_THINK_0(ix), b

    ; ENEMY_THINK_1 : 待機時間

    ; ENEMY_THINK_2 : 照準
    ld      ENEMY_THINK_2(ix), c

    ; カウントの更新
    call    _EnemyIncCount

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーが待機する
;
EnemyTurretIdle:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; 照準の変更
    ld      a, ENEMY_THINK_0(ix)
    or      a
    jr      nz, 00$
    call    _SystemGetRandom
    ld      a, #0x01
    ld      e, a
    add     a, a
    add     a, a
    add     a, a
    add     a, e
    add     a, ENEMY_THINK_2(ix)
    ld      e, a
    ld      d, #0x00
    ld      hl, #enemyTurretRotate
    add     hl, de
    ld      a, (hl)
    ld      ENEMY_THINK_2(ix), a
00$:

    ; ENEMY_THINK_1 : 待機時間
    ld      a, ENEMY_THINK_0(ix)
    add     a, #0x30
    ld      ENEMY_THINK_1(ix), a
    ld      ENEMY_THINK_0(ix), #0x00

    ; アニメーションの開始
    ld      hl, #enemyTurretAnimationIdle
    ld      a, ENEMY_THINK_2(ix)
    call    _CharacterStartIndexAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; プレイの監視
    call    _GameIsPlay
    jr      nc, 190$

    ; プレイヤの存在
    call    _PlayerIsLive
    jr      nc, 190$

    ; 待機時間の更新
    dec     ENEMY_THINK_1(ix)
    jr      nz, 190$

    ; プレイヤの向きの取得
    call    _EnemyGetPlayerAim
    ld      e, a
    cp      ENEMY_THINK_2(ix)
    jr      z, 180$
    ld      d, #0x00
    ld      hl, #enemyTurretReverse
    add     hl, de
    ld      a, (hl)
    cp      ENEMY_THINK_2(ix)
    jr      z, 180$

    ; 状態の更新
    ld      CHARACTER_STATE(ix), #0x00
    jr      190$
    
    ; 発射の開始
180$:
    ld      ENEMY_THINK_2(ix), e

    ; 処理の更新
    ld      hl, #EnemyTurretFire
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
;   jr      190$

    ; 待機の完了
190$:

    ; アニメーションの更新
    call    _CharacterUpdateAnimation
    
    ; 終了
    ret

; エネミーが発射する
;
EnemyTurretFire:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; ミサイルの発射
    ld      hl, #enemyTurretMuzzle
    ld      a, ENEMY_THINK_2(ix)
    call    _EnemyFireStraight

    ; アニメーションの開始
    ld      hl, #enemyTurretAnimationFire
    ld      a, ENEMY_THINK_2(ix)
    call    _CharacterStartIndexAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; アニメーションの監視
    call    _CharacterIsDoneAnimation
    jr      nc, 190$

    ; 処理の更新
    ld      hl, #EnemyTurretIdle
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
;   jr      190$

    ; 待機の完了
190$:

    ; アニメーションの更新
    call    _CharacterUpdateAnimation
    
    ; 終了
    ret

; 定数の定義
;

; エネミーの初期値
;
enemyTurretDefault:

    .dw     EnemyTurretIdle
    .db     CHARACTER_STATE_NULL
    .db     ENEMY_FLAG_COUNT ; CHARACTER_FLAG_NULL
    .dw     CHARACTER_POSITION_NULL
    .dw     CHARACTER_POSITION_NULL
    .dw     CHARACTER_SPEED_NULL
    .dw     CHARACTER_SPEED_NULL
    .db     0x0f ; CHARACTER_RECT_NULL
    .db     0x0f ; CHARACTER_RECT_NULL
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
    .dw     ENEMY_TURRET_LIFE_MAXIMUM ; CHARACTER_LIFE_NULL
    .dw     _EnemyDead1x1 ; ENEMY_DEAD_NULL
    .dw     _CharacterPrintPattern2x2 ; ENEMY_PRINT_NULL
    .dw     _CharacterErasePattern2x2 ; ENEMY_ERASE_NULL
    .dw     ENEMY_STAGE_NULL
    .db     ENEMY_THINK_NULL
    .db     ENEMY_THINK_NULL
    .db     ENEMY_THINK_NULL
    .db     ENEMY_THINK_NULL
    .db     ENEMY_THINK_NULL
    .db     ENEMY_THINK_NULL
    .db     ENEMY_THINK_NULL
    .db     ENEMY_THINK_NULL

; 回転
;
enemyTurretRotate:

    .db     ENEMY_AIM_0730, ENEMY_AIM_0900, ENEMY_AIM_1030, ENEMY_AIM_1030, ENEMY_AIM_1200, ENEMY_AIM_0130, ENEMY_AIM_0300, ENEMY_AIM_0430, ENEMY_AIM_0600
    .db     ENEMY_AIM_1030, ENEMY_AIM_1200, ENEMY_AIM_0130, ENEMY_AIM_0130, ENEMY_AIM_0300, ENEMY_AIM_0430, ENEMY_AIM_0600, ENEMY_AIM_0730, ENEMY_AIM_0900

; 反転
;
enemyTurretReverse:

    .db     ENEMY_AIM_0300, ENEMY_AIM_0430, ENEMY_AIM_0600, ENEMY_AIM_0600, ENEMY_AIM_0730, ENEMY_AIM_0900, ENEMY_AIM_1030, ENEMY_AIM_1200, ENEMY_AIM_0130

; 砲口
;
enemyTurretMuzzle:

    .db     -0x08, -0x08
    .db     -0x07, -0x0e
    .db     -0x01, -0x0f
    .db     -0x01, -0x0f
    .db      0x07, -0x0e
    .db      0x07, -0x08
    .db      0x06, -0x01
    .db     -0x01, -0x00
    .db     -0x06, -0x01

; アニメーション
;
enemyTurretAnimationIdle:

    .dw     enemyTurretAnimationIdle_0300_0900
    .dw     enemyTurretAnimationIdle_0430_1030
    .dw     enemyTurretAnimationIdle_1200_0600
    .dw     enemyTurretAnimationIdle_1200_0600
    .dw     enemyTurretAnimationIdle_0130_0730
    .dw     enemyTurretAnimationIdle_0300_0900
    .dw     enemyTurretAnimationIdle_0430_1030
    .dw     enemyTurretAnimationIdle_1200_0600
    .dw     enemyTurretAnimationIdle_0130_0730

enemyTurretAnimationIdle_1200_0600:

    .db     0xff,  0x00, -0x0f, -0x08, 0xb0, SOUND_SE_NULL

enemyTurretAnimationIdle_0130_0730:

    .db     0xff,  0x00, -0x0f, -0x08, 0xc0, SOUND_SE_NULL

enemyTurretAnimationIdle_0300_0900:

    .db     0xff,  0x00, -0x0f, -0x08, 0xd0, SOUND_SE_NULL

enemyTurretAnimationIdle_0430_1030:

    .db     0xff,  0x00, -0x0f, -0x08, 0xe0, SOUND_SE_NULL

enemyTurretAnimationFire:

    .dw     enemyTurretAnimationFire_0300_0900
    .dw     enemyTurretAnimationFire_0430_1030
    .dw     enemyTurretAnimationFire_1200_0600
    .dw     enemyTurretAnimationFire_1200_0600
    .dw     enemyTurretAnimationFire_0130_0730
    .dw     enemyTurretAnimationFire_0300_0900
    .dw     enemyTurretAnimationFire_0430_1030
    .dw     enemyTurretAnimationFire_1200_0600
    .dw     enemyTurretAnimationFire_0130_0730


enemyTurretAnimationFire_1200_0600:

    .db     0x04,  0x00, -0x0f, -0x08, 0xb4, SOUND_SE_NULL
    .db     0x1c,  0x00, -0x0f, -0x08, 0xb0, SOUND_SE_NULL
    .db     0x00

enemyTurretAnimationFire_0130_0730:

    .db     0x04,  0x00, -0x0f, -0x08, 0xc4, SOUND_SE_NULL
    .db     0x1c,  0x00, -0x0f, -0x08, 0xc0, SOUND_SE_NULL
    .db     0x00

enemyTurretAnimationFire_0300_0900:

    .db     0x04,  0x00, -0x0f, -0x08, 0xd4, SOUND_SE_NULL
    .db     0x1c,  0x00, -0x0f, -0x08, 0xd0, SOUND_SE_NULL
    .db     0x00

enemyTurretAnimationFire_0430_1030:

    .db     0x04,  0x00, -0x0f, -0x08, 0xe4, SOUND_SE_NULL
    .db     0x1c,  0x00, -0x0f, -0x08, 0xe0, SOUND_SE_NULL
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

