; EnemyGunner.s : ガンナー
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
ENEMY_GUNNER_LIMIT_LEFT         =   0x07
ENEMY_GUNNER_LIMIT_RIGHT        =   0x06
ENEMY_GUNNER_LIMIT_UPPER        =   0x10
ENEMY_GUNNER_LIMIT_LOWER        =   0x08
ENEMY_GUNNER_LIFE_MAXIMUM       =   0x0018


; CODE 領域
;
    .area   _CODE

; エネミーを登場させる
;
_EnemyGunnerSpawn::
    
    ; レジスタの保存

    ; ix < エネミー
    ; de < Y/X 位置
    ; c  < 向き
    ; b  < ディレイ
    
    ; エネミーの初期化
    push    bc
    push    de
    ld      hl, #enemyGunnerDefault
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    pop     de
    pop     bc

    ; 位置の設定
    ld      CHARACTER_POSITION_X_H(ix), e
    ld      CHARACTER_POSITION_Y_H(ix), d

    ; 向きの設定
    ld      a, c
    or      a
    jr      z, 30$
    set     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
30$:

    ; ENEMY_THINK_0 : ディレイ
    ld      ENEMY_THINK_0(ix), b
    
    ; ENEMY_THINK_1 : 歩数
    
    ; ENEMY_THINK_2 : 照準

    ; ENEMY_THINK_3 : ヒット

    ; カウントの更新
    call    _EnemyIncCount

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーが準備する
;
EnemyGunnerStandBy:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; アニメーションの開始
    ld      hl, #enemyGunnerAnimationStandByLeft
    ld      de, #enemyGunnerAnimationStandByRight
    call    _CharacterStartDirectionAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; プレイの監視
    call    _GameIsPlay
    jr      nc, 190$

    ; 準備時間の更新
    ld      a, ENEMY_THINK_0(ix)
    or      a
    jr      z, 100$
    dec     ENEMY_THINK_0(ix)
    jr      nz, 190$

    ; アニメーションの開始
    ld      hl, #enemyGunnerAnimationStandUpLeft
    ld      de, #enemyGunnerAnimationStandUpRight
    call    _CharacterStartDirectionAnimation
    jr      190$

    ; アニメーションの監視
100$:
    call    _CharacterIsDoneAnimation
    jp      nc, 190$

    ; 処理の更新
    ld      hl, #EnemyGunnerWalk
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
;   jr      190$

    ; 準備の完了
190$:

    ; アニメーションの更新
    call    _CharacterUpdateAnimation

    ; 終了
    ret

; エネミーが歩く
;
EnemyGunnerWalk:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; ENEMY_THINK_1 : 歩数
    call    _SystemGetRandom
    and     #0x03
    add     a, #0x04
    ld      ENEMY_THINK_1(ix), a

    ; ENEMY_THINK_3 : ヒット
    ld      ENEMY_THINK_3(ix), #0x00

    ; アニメーションの開始
    ld      hl, #enemyGunnerAnimationIdleLeft
    ld      de, #enemyGunnerAnimationIdleRight
    call    _CharacterStartDirectionAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; プレイの監視
    call    _GameIsPlay
    jp      nc, 190$

    ; アニメーションの監視
    call    _CharacterIsDoneAnimation
    jp      nc, 190$

    ; 歩数の更新
    ld      a, ENEMY_THINK_1(ix)
    or      a
    jr      z, 100$
    dec     ENEMY_THINK_1(ix)
100$:

    ; ヒットの更新
    ld      a, CHARACTER_HIT_FRAME(ix)
    or      ENEMY_THINK_3(ix)
    ld      ENEMY_THINK_3(ix), a

    ; 向きの確認
    call    _PlayerGetPosition
    ld      c, e
    ld      b, d
    bit     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    jr      nz, 120$

    ; 左向き
110$:
    call    _PlayerIsLive
    jr      nc, 113$
    ld      a, CHARACTER_POSITION_X_H(ix)
    sub     c
    jr      c, 112$
    cp      #0x10
    jr      c, 113$
    ld      a, ENEMY_THINK_1(ix)
    or      a
    jr      nz, 113$
    ld      hl, #enemyGunnerMuzzle
    ld      a, #ENEMY_AIM_0900
    call    _EnemyRay
    jr      nc, 113$
    ld      a, c
    sub     e
    jr      c, 111$
    ld      a, b
    sub     CHARACTER_POSITION_Y_H(ix)
    add     a, #ENEMY_GUNNER_LIMIT_UPPER
    cp      #(ENEMY_GUNNER_LIMIT_UPPER + ENEMY_GUNNER_LIMIT_LOWER + 0x01)
    jr      nc, 111$
    ld      a, #ENEMY_AIM_0900
    jp      180$
111$:
    ld      a, #ENEMY_AIM_1030
    jp      180$
112$:
    ld      a, ENEMY_THINK_3(ix)
    or      a
    jr      z, 113$
    ld      a, CHARACTER_POSITION_Y_H(ix)
    cp      b
    jr      nc, 170$
113$:
    ld      a, CHARACTER_POSITION_X_H(ix)
    ld      d, CHARACTER_POSITION_Y_H(ix)
    sub     #ENEMY_GUNNER_LIMIT_LEFT
    jr      c, 170$
    ld      e, a
    call    _StageIsBlock
    jr      c, 170$
    inc     d
    call    _StageIsBlock
    jr      nc, 170$
    ld      hl, #enemyGunnerAnimationWalkLeft
    call    _CharacterStartAnimation
    jp      190$

    ; 右向き
120$:
    call    _PlayerIsLive
    jr      nc, 123$
    ld      a, c
    sub     CHARACTER_POSITION_X_H(ix)
    jr      c, 122$
    cp      #0x10
    jr      c, 123$
    ld      a, ENEMY_THINK_1(ix)
    or      a
    jr      nz, 123$
    ld      hl, #enemyGunnerMuzzle
    ld      a, #ENEMY_AIM_0300
    call    _EnemyRay
    jr      nc, 123$
    ld      a, e
    sub     c
    jr      c, 121$
    ld      a, b
    sub     CHARACTER_POSITION_Y_H(ix)
    add     a, #ENEMY_GUNNER_LIMIT_UPPER
    cp      #(ENEMY_GUNNER_LIMIT_UPPER + ENEMY_GUNNER_LIMIT_LOWER + 0x01)
    jr      nc, 121$
    ld      a, #ENEMY_AIM_0300
    jr      180$
121$:
    ld      a, #ENEMY_AIM_0130
    jr      180$
122$:
    ld      a, ENEMY_THINK_3(ix)
    or      a
    jr      z, 123$
    ld      a, CHARACTER_POSITION_Y_H(ix)
    cp      b
    jr      nc, 170$
123$:
    ld      a, CHARACTER_POSITION_X_H(ix)
    ld      d, CHARACTER_POSITION_Y_H(ix)
    add     a, #ENEMY_GUNNER_LIMIT_RIGHT
    jr      c, 170$
    ld      e, a
    call    _StageIsBlock
    jr      c, 170$
    inc     d
    call    _StageIsBlock
    jr      nc, 170$
    ld      hl, #enemyGunnerAnimationWalkRight
    call    _CharacterStartAnimation
    jr      190$

    ; 方向転換
170$:

    ; フラグの更新
    ld      a, CHARACTER_FLAG(ix)
    xor     #CHARACTER_FLAG_RIGHT
    ld      CHARACTER_FLAG(ix), a

    ; アニメーションの開始
    ld      hl, #enemyGunnerAnimationTurnLeft
    ld      de, #enemyGunnerAnimationTurnRight
    call    _CharacterStartDirectionAnimation
    jr      190$

    ; 発射
180$:

    ; ENEMY_THINK_2 : 照準
    ld      ENEMY_THINK_2(ix), a

    ; 処理の更新
    ld      hl, #EnemyGunnerFire
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
;   jr      190$

    ; 歩くの完了
190$:

    ; アニメーションの更新
    call    _CharacterUpdateAnimation

    ; 終了
    ret

; エネミーが発射する
;
EnemyGunnerFire:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; アニメーションの開始
    ld      hl, #enemyGunnerAnimationAim
    ld      a, ENEMY_THINK_2(ix)
    call    _CharacterStartIndexAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; アニメーションの監視
    call    _CharacterIsDoneAnimation
    jr      nc, 190$

    ; 状態の確認
    ld      a, CHARACTER_STATE(ix)
    cp      #0x01
    jr      nz, 180$

    ; ミサイルの発射
    ld      hl, #enemyGunnerMuzzle
    ld      a, ENEMY_THINK_2(ix)
    cp      #ENEMY_AIM_0900
    jr      z, 100$
    cp      #ENEMY_AIM_0300
    jr      z, 100$
    call    _EnemyFireParabola
    jr      109$
100$:
    call    _EnemyFireStraight
;   jr      109$
109$:

    ; アニメーションの開始
    ld      hl, #enemyGunnerAnimationFire
    ld      a, ENEMY_THINK_2(ix)
    call    _CharacterStartIndexAnimation

    ; 状態の更新
    inc     CHARACTER_STATE(ix)
    jr      190$

    ; 処理の更新
180$:
    ld      hl, #EnemyGunnerWalk
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
enemyGunnerDefault:

    .dw     EnemyGunnerStandBy
    .db     CHARACTER_STATE_NULL
    .db     ENEMY_FLAG_COUNT ; CHARACTER_FLAG_NULL
    .dw     CHARACTER_POSITION_NULL
    .dw     CHARACTER_POSITION_NULL
    .dw     CHARACTER_SPEED_NULL
    .dw     CHARACTER_SPEED_NULL
    .db     0x0c ; CHARACTER_RECT_NULL
    .db     0x0e ; CHARACTER_RECT_NULL
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
    .dw     ENEMY_GUNNER_LIFE_MAXIMUM ; CHARACTER_LIFE_NULL
    .dw     _EnemyDead1x1 ; ENEMY_DEAD_NULL
    .dw     _CharacterPrintSprite1x1 ; ENEMY_PRINT_NULL
    .dw     _CharacterEraseSprite ; ENEMY_ERASE_NULL
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
enemyGunnerMuzzle:

    .db     -0x04, -0x07
    .db      0x00, -0x0d
    .db      0x06, -0x0f
    .db     -0x08, -0x0f
    .db     -0x01, -0x0d
    .db      0x03, -0x07
    .db      0x00,  0x00
    .db      0x00,  0x00
    .db      0x00,  0x00

; アニメーション
;
enemyGunnerAnimationIdleLeft:

    .db     0xff,  0x00, -0x0f - 0x01, -0x08, 0x40, SOUND_SE_NULL

enemyGunnerAnimationIdleRight:

    .db     0xff,  0x00, -0x0f - 0x01, -0x08, 0x50, SOUND_SE_NULL

enemyGunnerAnimationStandByLeft:

    .db     0xff,  0x00, -0x0f - 0x01, -0x08, 0x47, SOUND_SE_NULL

enemyGunnerAnimationStandByRight:

    .db     0xff,  0x00, -0x0f - 0x01, -0x08, 0x57, SOUND_SE_NULL

enemyGunnerAnimationStandUpLeft:

    .db     0x18,  0x00, -0x0f - 0x01, -0x08, 0x40, SOUND_SE_NULL
    .db     0x00

enemyGunnerAnimationStandUpRight:

    .db     0x18,  0x00, -0x0f - 0x01, -0x08, 0x50, SOUND_SE_NULL
    .db     0x00

enemyGunnerAnimationTurnLeft:

    .db     0x0c,  0x00, -0x0f - 0x01, -0x08, 0x48, SOUND_SE_NULL
    .db     0x0c,  0x00, -0x0f - 0x01, -0x08, 0x40, SOUND_SE_NULL
    .db     0x00

enemyGunnerAnimationTurnRight:

    .db     0x0c,  0x00, -0x0f - 0x01, -0x08, 0x58, SOUND_SE_NULL
    .db     0x0c,  0x00, -0x0f - 0x01, -0x08, 0x50, SOUND_SE_NULL
    .db     0x00

enemyGunnerAnimationWalkLeft:

    .db     0x06, -0x02, -0x0f - 0x01, -0x08, 0x41, SOUND_SE_NULL
    .db     0x06,  0x00, -0x0f - 0x01, -0x08, 0x42, SOUND_SE_NULL
    .db     0x06, -0x02, -0x0f - 0x01, -0x08, 0x43, SOUND_SE_NULL
    .db     0x06,  0x00, -0x0f - 0x01, -0x08, 0x40, SOUND_SE_NULL
    .db     0x00

enemyGunnerAnimationWalkRight:

    .db     0x06,  0x02, -0x0f - 0x01, -0x08, 0x51, SOUND_SE_NULL
    .db     0x06,  0x00, -0x0f - 0x01, -0x08, 0x52, SOUND_SE_NULL
    .db     0x06,  0x02, -0x0f - 0x01, -0x08, 0x53, SOUND_SE_NULL
    .db     0x06,  0x00, -0x0f - 0x01, -0x08, 0x50, SOUND_SE_NULL
    .db     0x00

enemyGunnerAnimationAim:

    .dw     enemyGunnerAnimationAim_0900
    .dw     enemyGunnerAnimationAim_1030
    .dw     enemyGunnerAnimationAim_1200
    .dw     enemyGunnerAnimationAim_0000
    .dw     enemyGunnerAnimationAim_0130
    .dw     enemyGunnerAnimationAim_0300
    .dw     0x0000
    .dw     0x0000
    .dw     0x0000

enemyGunnerAnimationAim_0900:

    .db     0x10,  0x00, -0x0f - 0x01, -0x04, 0x4a, SOUND_SE_NULL
    .db     0x00

enemyGunnerAnimationAim_1030:

    .db     0x10,  0x00, -0x0f - 0x01, -0x04, 0x4c, SOUND_SE_NULL
    .db     0x00

enemyGunnerAnimationAim_1200:

    .db     0x10,  0x00, -0x0f - 0x01, -0x04, 0x4e, SOUND_SE_NULL
    .db     0x00

enemyGunnerAnimationAim_0000:

    .db     0x10,  0x00, -0x0f - 0x01, -0x0c, 0x5e, SOUND_SE_NULL
    .db     0x00

enemyGunnerAnimationAim_0130:

    .db     0x10,  0x00, -0x0f - 0x01, -0x0c, 0x5c, SOUND_SE_NULL
    .db     0x00

enemyGunnerAnimationAim_0300:

    .db     0x10,  0x00, -0x0f - 0x01, -0x0c, 0x5a, SOUND_SE_NULL
    .db     0x00

enemyGunnerAnimationFire:

    .dw     enemyGunnerAnimationFire_0900
    .dw     enemyGunnerAnimationFire_1030
    .dw     enemyGunnerAnimationFire_1200
    .dw     enemyGunnerAnimationFire_0000
    .dw     enemyGunnerAnimationFire_0130
    .dw     enemyGunnerAnimationFire_0300
    .dw     0x0000
    .dw     0x0000
    .dw     0x0000

enemyGunnerAnimationFire_0900:

    .db     0x04,  0x00, -0x0f - 0x01, -0x04, 0x4b, SOUND_SE_NULL
    .db     0x14,  0x00, -0x0f - 0x01, -0x04, 0x4a, SOUND_SE_NULL
    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x44, SOUND_SE_NULL
    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x40, SOUND_SE_NULL
    .db     0x00

enemyGunnerAnimationFire_1030:

    .db     0x04,  0x00, -0x0f - 0x01, -0x04, 0x4d, SOUND_SE_NULL
    .db     0x14,  0x00, -0x0f - 0x01, -0x04, 0x4c, SOUND_SE_NULL
    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x44, SOUND_SE_NULL
    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x40, SOUND_SE_NULL
    .db     0x00

enemyGunnerAnimationFire_1200:

    .db     0x04,  0x00, -0x0f - 0x01, -0x04, 0x4f, SOUND_SE_NULL
    .db     0x14,  0x00, -0x0f - 0x01, -0x04, 0x4e, SOUND_SE_NULL
    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x44, SOUND_SE_NULL
    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x40, SOUND_SE_NULL
    .db     0x00

enemyGunnerAnimationFire_0000:

    .db     0x04,  0x00, -0x0f - 0x01, -0x0c, 0x5f, SOUND_SE_NULL
    .db     0x14,  0x00, -0x0f - 0x01, -0x0c, 0x5e, SOUND_SE_NULL
    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x54, SOUND_SE_NULL
    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x50, SOUND_SE_NULL
    .db     0x00

enemyGunnerAnimationFire_0130:

    .db     0x04,  0x00, -0x0f - 0x01, -0x0c, 0x5d, SOUND_SE_NULL
    .db     0x14,  0x00, -0x0f - 0x01, -0x0c, 0x5c, SOUND_SE_NULL
    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x54, SOUND_SE_NULL
    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x50, SOUND_SE_NULL
    .db     0x00

enemyGunnerAnimationFire_0300:

    .db     0x04,  0x00, -0x0f - 0x01, -0x0c, 0x5b, SOUND_SE_NULL
    .db     0x14,  0x00, -0x0f - 0x01, -0x0c, 0x5a, SOUND_SE_NULL
    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x54, SOUND_SE_NULL
    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x50, SOUND_SE_NULL
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

