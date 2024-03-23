; EnemyHomer.s : ホーマー
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
ENEMY_HOMER_LIMIT_LEFT          =   0x07
ENEMY_HOMER_LIMIT_RIGHT         =   0x06
ENEMY_HOMER_SPEED_X_MAXIMUM     =   0x0080
ENEMY_HOMER_SPEED_Y_JUMP        =   -0x0160
ENEMY_HOMER_SPEED_Y_MAXIMUM     =   0x0800
ENEMY_HOMER_ACCEL_X             =   0x000c
ENEMY_HOMER_ACCEL_JUMP          =   0x0007
ENEMY_HOMER_ACCEL_GRAVITY       =   0x0010
ENEMY_HOMER_BRAKE_X             =   0x0006
ENEMY_HOMER_LIFE_MAXIMUM        =   0x0028


; CODE 領域
;
    .area   _CODE

; エネミーを登場させる
;
_EnemyHomerSpawn::
    
    ; レジスタの保存

    ; ix < エネミー
    ; de < Y/X 位置
    ; c  < 向き
    ; b  < ディレイ
    
    ; エネミーの初期化
    push    bc
    push    de
    ld      hl, #enemyHomerDefault
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

    ; ENEMY_THINK_3 : 発射回数

    ; カウントの更新
    call    _EnemyIncCount

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーが準備する
;
EnemyHomerStandBy:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; アニメーションの開始
    ld      hl, #enemyHomerAnimationStandByLeft
    ld      de, #enemyHomerAnimationStandByRight
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
    ld      hl, #enemyHomerAnimationStandUpLeft
    ld      de, #enemyHomerAnimationStandUpRight
    call    _CharacterStartDirectionAnimation
    jr      190$

    ; アニメーションの監視
100$:
    call    _CharacterIsDoneAnimation
    jp      nc, 190$

    ; 処理の更新
    ld      hl, #EnemyHomerWalk
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
EnemyHomerWalk:
    
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

    ; アニメーションの開始
    ld      hl, #enemyHomerAnimationIdleLeft
    ld      de, #enemyHomerAnimationIdleRight
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
    ld      hl, #enemyHomerMuzzle
    ld      a, #ENEMY_AIM_0900
    call    _EnemyRay
    jr      nc, 113$
    ld      a, c
    sub     e
    jr      c, 111$
    call    _EnemyGetPlayerAim
    cp      #ENEMY_AIM_0430
    jp      c, 180$
    ld      a, #ENEMY_AIM_1200
    jp      180$
111$:
    ld      a, #ENEMY_AIM_1030
    jp      180$
112$:
    ld      a, CHARACTER_HIT_FRAME(ix)
    or      a
    jr      z, 113$
    ld      a, CHARACTER_POSITION_Y_H(ix)
    cp      b
    jr      nc, 170$
113$:
    ld      a, CHARACTER_POSITION_X_H(ix)
    ld      d, CHARACTER_POSITION_Y_H(ix)
    sub     #ENEMY_HOMER_LIMIT_LEFT
    jr      c, 170$
    ld      e, a
    call    _StageIsBlock
    jr      c, 160$
    ld      hl, #enemyHomerAnimationWalkLeft
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
    ld      hl, #enemyHomerMuzzle
    ld      a, #ENEMY_AIM_0300
    call    _EnemyRay
    jr      nc, 123$
    ld      a, e
    sub     c
    jr      c, 121$
    call    _EnemyGetPlayerAim
    cp      #ENEMY_AIM_0430
    jr      c, 180$
    ld      a, #ENEMY_AIM_0000
    jr      180$
121$:
    ld      a, #ENEMY_AIM_0130
    jr      180$
122$:
    ld      a, CHARACTER_HIT_FRAME(ix)
    or      a
    jr      z, 123$
    ld      a, CHARACTER_POSITION_Y_H(ix)
    cp      b
    jr      nc, 170$
123$:
    ld      a, CHARACTER_POSITION_X_H(ix)
    ld      d, CHARACTER_POSITION_Y_H(ix)
    add     a, #ENEMY_HOMER_LIMIT_RIGHT
    jr      c, 170$
    ld      e, a
    call    _StageIsBlock
    jr      c, 160$
    ld      hl, #enemyHomerAnimationWalkRight
    call    _CharacterStartAnimation
    jr      190$

    ; ジャンプ
160$:

    ; 処理の更新
    ld      hl, #EnemyHomerJump
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
    jr      190$

    ; 方向転換
170$:

    ; フラグの更新
    ld      a, CHARACTER_FLAG(ix)
    xor     #CHARACTER_FLAG_RIGHT
    ld      CHARACTER_FLAG(ix), a

    ; アニメーションの開始
    ld      hl, #enemyHomerAnimationTurnLeft
    ld      de, #enemyHomerAnimationTurnRight
    call    _CharacterStartDirectionAnimation
    jr      190$

    ; 発射
180$:

    ; ENEMY_THINK_2 : 照準
    ld      ENEMY_THINK_2(ix), a

    ; 処理の更新
    ld      hl, #EnemyHomerFire
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
;   jr      190$

    ; 歩くの完了
190$:

    ; 落下の判定
    call    EnemyHomerIsFallThen

    ; アニメーションの更新
    call    _CharacterUpdateAnimation

    ; 終了
    ret

; エネミーがジャンプする
;
EnemyHomerJump:

    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; フラグの設定
    set     #CHARACTER_FLAG_THROUGH_BIT, CHARACTER_FLAG(ix)

    ; Y の速度の設定
    ld      hl, #ENEMY_HOMER_SPEED_Y_JUMP
    ld      CHARACTER_SPEED_Y_L(ix), l
    ld      CHARACTER_SPEED_Y_H(ix), h

    ; アニメーションの開始
    ld      hl, #enemyHomerAnimationJumpLeft
    ld      de, #enemyHomerAnimationJumpRight
    call    _CharacterStartDirectionAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; アニメーションの監視
    call    _CharacterIsDoneAnimation
    jr      nc, 190$

    ; 向きの確認
    ld      a, CHARACTER_POSITION_X_H(ix)
    ld      d, CHARACTER_POSITION_Y_H(ix)
    bit     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    jr      nz, 120$

    ; 左向き
110$:
    sub     #ENEMY_HOMER_LIMIT_LEFT
    jr      c, 131$
    ld      e, a
    call    _StageIsBlock
    jr      c, 130$
    ld      de, #-ENEMY_HOMER_ACCEL_X
    ld      bc, #ENEMY_HOMER_SPEED_X_MAXIMUM
    call    _CharacterAccelX
    jr      131$

    ; 右向き
120$:
    add     a, #ENEMY_HOMER_LIMIT_RIGHT
    jp      c, 131$
    ld      e, a
    call    _StageIsBlock
    jr      c, 130$
    ld      de, #ENEMY_HOMER_ACCEL_X
    ld      bc, #ENEMY_HOMER_SPEED_X_MAXIMUM
    call    _CharacterAccelX
    jr      131$

    ; Y の加速
130$:
    ld      de, #ENEMY_HOMER_ACCEL_JUMP
    jr      139$
131$:
    ld      de, #ENEMY_HOMER_ACCEL_GRAVITY
;   jr      139$
139$:
    ld      bc, #ENEMY_HOMER_SPEED_Y_MAXIMUM
    call    _CharacterAccelY

    ; 移動
    call    _CharacterMoveY
    call    _CharacterMoveX

    ; 落下の開始
    bit     #0x07, CHARACTER_SPEED_Y_H(ix)
    jr      nz, 190$

    ; フラグの設定
    res     #CHARACTER_FLAG_THROUGH_BIT, CHARACTER_FLAG(ix)

    ; 処理の更新
    ld      hl, #EnemyHomerFall
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
;   jr      190$

    ; ジャンプの完了
190$:

    ;  アニメーションの更新
    call    _CharacterUpdateAnimation

    ; レジスタの復帰

    ; 終了
    ret

; エネミーが落下する
;
EnemyHomerFall:

    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; アニメーションの開始
    ld      hl, #enemyHomerAnimationFallLeft
    ld      de, #enemyHomerAnimationFallRight
    call    _CharacterStartDirectionAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; Y の移動
    ld      de, #ENEMY_HOMER_ACCEL_GRAVITY
    ld      bc, #ENEMY_HOMER_SPEED_Y_MAXIMUM
    call    _CharacterAccelY
    call    _CharacterMoveY

    ; X の移動
    ld      de, #ENEMY_HOMER_BRAKE_X
    call    _CharacterBrakeX
    call    _CharacterMoveX

    ; 着地
    call    _CharacterIsLand
    jr      nc, 190$

    ; 処理の更新
    ld      hl, #EnemyHomerLand
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
;   jr      190$

    ; 落下の完了
190$:

    ;  アニメーションの更新
    call    _CharacterUpdateAnimation

    ; レジスタの復帰

    ; 終了
    ret

; エネミーが着地する
;
EnemyHomerLand:

    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; アニメーションの開始
    ld      hl, #enemyHomerAnimationLandLeft
    ld      de, #enemyHomerAnimationLandRight
    call    _CharacterStartDirectionAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; X の移動
    ld      de, #ENEMY_HOMER_BRAKE_X
    call    _CharacterBrakeX
    call    _CharacterMoveX

    ; アニメーションの監視
    call    _CharacterIsDoneAnimation
    jr      nc, 190$

    ; 処理の更新
    ld      hl, #EnemyHomerWalk
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
;   jr      190$

    ; 着地の完了
190$:

    ; 落下の判定
    call    EnemyHomerIsFallThen

    ;  アニメーションの更新
    call    _CharacterUpdateAnimation

    ; レジスタの復帰

    ; 終了
    ret

; エネミーが発射する
;
EnemyHomerFire:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; ENEMY_THINK_3 : 発射回数
    ld      a, ENEMY_THINK_2(ix)
    cp      #ENEMY_AIM_1200
    jr      z, 00$
    cp      #ENEMY_AIM_0000
    jr      z, 00$
    ld      a, #0x01
    jr      01$
00$:
    ld      a, #0x03
01$:
    inc     a
    ld      ENEMY_THINK_3(ix), a

    ; アニメーションの開始
    ld      hl, #enemyHomerAnimationAim
    ld      a, ENEMY_THINK_2(ix)
    call    _CharacterStartIndexAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; アニメーションの監視
    call    _CharacterIsDoneAnimation
    jr      nc, 190$

    ; 発射回数の更新
    ld      a, ENEMY_THINK_3(ix)
    or      a
    jr      z, 180$
    dec     ENEMY_THINK_3(ix)
    jr      z, 170$

    ; ミサイルの発射
    ld      hl, #enemyHomerMuzzle
    ld      a, ENEMY_THINK_2(ix)
    cp      #ENEMY_AIM_1200
    jr      z, 101$
    cp      #ENEMY_AIM_0000
    jr      z, 101$
    cp      #ENEMY_AIM_1030
    jr      z, 100$
    cp      #ENEMY_AIM_0130
    jr      z, 100$
    call    _EnemyFireStraight
    jr      109$
100$:
    call    _EnemyFireHoming
    jr      109$
101$:
    call    _EnemyFireVertical
;   jr      109$
109$:

    ; アニメーションの開始
    ld      hl, #enemyHomerAnimationFire
    ld      a, ENEMY_THINK_2(ix)
    call    _CharacterStartIndexAnimation
    jr      190$

    ; 構えを直す
170$:
    ld      hl, #enemyHomerAnimationFixLeft
    ld      de, #enemyHomerAnimationFixRight
    call    _CharacterStartDirectionAnimation
    jr      190$

    ; 処理の更新
180$:
    ld      hl, #EnemyHomerWalk
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

; エネミーの落下を判定する
;
EnemyHomerIsFallThen:

    ; レジスタの保存

    ; 落下の判定
    call    _CharacterIsLand
    jr      c, 19$

    ; 速度の設定
    xor     a
    ld      CHARACTER_SPEED_Y_L(ix), a
    ld      CHARACTER_SPEED_Y_H(ix), a

    ; 処理の更新
    ld      hl, #EnemyHomerFall
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; エネミーの初期値
;
enemyHomerDefault:

    .dw     EnemyHomerStandBy
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
    .dw     ENEMY_HOMER_LIFE_MAXIMUM ; CHARACTER_LIFE_NULL
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
enemyHomerMuzzle:

    .db     -0x04, -0x07
    .db     -0x04, -0x0d
    .db      0x02, -0x0f
    .db     -0x04, -0x0f
    .db      0x03, -0x0d
    .db      0x03, -0x07
    .db      0x00,  0x00
    .db      0x00,  0x00
    .db      0x00,  0x00

; アニメーション
;
enemyHomerAnimationIdleLeft:

    .db     0xff,  0x00, -0x0f - 0x01, -0x08, 0x60, SOUND_SE_NULL

enemyHomerAnimationIdleRight:

    .db     0xff,  0x00, -0x0f - 0x01, -0x08, 0x70, SOUND_SE_NULL

enemyHomerAnimationStandByLeft:

    .db     0xff,  0x00, -0x0f - 0x01, -0x08, 0x67, SOUND_SE_NULL

enemyHomerAnimationStandByRight:

    .db     0xff,  0x00, -0x0f - 0x01, -0x08, 0x77, SOUND_SE_NULL

enemyHomerAnimationStandUpLeft:

    .db     0x18,  0x00, -0x0f - 0x01, -0x08, 0x60, SOUND_SE_NULL
    .db     0x00

enemyHomerAnimationStandUpRight:

    .db     0x18,  0x00, -0x0f - 0x01, -0x08, 0x70, SOUND_SE_NULL
    .db     0x00

enemyHomerAnimationTurnLeft:

    .db     0x06,  0x00, -0x0f - 0x01, -0x08, 0x68, SOUND_SE_NULL
    .db     0x06,  0x00, -0x0f - 0x01, -0x08, 0x60, SOUND_SE_NULL
    .db     0x00

enemyHomerAnimationTurnRight:

    .db     0x06,  0x00, -0x0f - 0x01, -0x08, 0x78, SOUND_SE_NULL
    .db     0x06,  0x00, -0x0f - 0x01, -0x08, 0x70, SOUND_SE_NULL
    .db     0x00

enemyHomerAnimationWalkLeft:

    .db     0x03, -0x02, -0x0f - 0x01, -0x08, 0x61, SOUND_SE_NULL
    .db     0x03,  0x00, -0x0f - 0x01, -0x08, 0x62, SOUND_SE_NULL
    .db     0x03, -0x02, -0x0f - 0x01, -0x08, 0x63, SOUND_SE_NULL
    .db     0x03,  0x00, -0x0f - 0x01, -0x08, 0x60, SOUND_SE_NULL
    .db     0x00

enemyHomerAnimationWalkRight:

    .db     0x03,  0x02, -0x0f - 0x01, -0x08, 0x71, SOUND_SE_NULL
    .db     0x03,  0x00, -0x0f - 0x01, -0x08, 0x72, SOUND_SE_NULL
    .db     0x03,  0x02, -0x0f - 0x01, -0x08, 0x73, SOUND_SE_NULL
    .db     0x03,  0x00, -0x0f - 0x01, -0x08, 0x70, SOUND_SE_NULL
    .db     0x00

enemyHomerAnimationJumpLeft:

    .db     0x0c,  0x00, -0x0f - 0x01, -0x08, 0x64, SOUND_SE_NULL
    .db     0xff,  0x00, -0x0f - 0x01, -0x08, 0x65, SOUND_SE_NULL

enemyHomerAnimationJumpRight:

    .db     0x0c,  0x00, -0x0f - 0x01, -0x08, 0x74, SOUND_SE_NULL
    .db     0xff,  0x00, -0x0f - 0x01, -0x08, 0x75, SOUND_SE_NULL

enemyHomerAnimationFallLeft:

    .db     0xff,  0x00, -0x0f - 0x01, -0x08, 0x66, SOUND_SE_NULL

enemyHomerAnimationFallRight:

    .db     0xff,  0x00, -0x0f - 0x01, -0x08, 0x76, SOUND_SE_NULL

enemyHomerAnimationLandLeft:

    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x64, SOUND_SE_NULL
    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x60, SOUND_SE_NULL
    .db     0x00

enemyHomerAnimationLandRight:

    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x74, SOUND_SE_NULL
    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x70, SOUND_SE_NULL
    .db     0x00

enemyHomerAnimationAim:

    .dw     enemyHomerAnimationAim_0900
    .dw     enemyHomerAnimationAim_1030
    .dw     enemyHomerAnimationAim_1200
    .dw     enemyHomerAnimationAim_0000
    .dw     enemyHomerAnimationAim_0130
    .dw     enemyHomerAnimationAim_0300
    .dw     0x0000
    .dw     0x0000
    .dw     0x0000

enemyHomerAnimationAim_0900:

    .db     0x04,  0x00, -0x0f - 0x01, -0x04, 0x6a, SOUND_SE_NULL
    .db     0x00

enemyHomerAnimationAim_1030:

    .db     0x04,  0x00, -0x0f - 0x01, -0x04, 0x6c, SOUND_SE_NULL
    .db     0x00

enemyHomerAnimationAim_1200:

    .db     0x04,  0x00, -0x0f - 0x01, -0x04, 0x6e, SOUND_SE_NULL
    .db     0x00

enemyHomerAnimationAim_0000:

    .db     0x04,  0x00, -0x0f - 0x01, -0x0c, 0x7e, SOUND_SE_NULL
    .db     0x00

enemyHomerAnimationAim_0130:

    .db     0x04,  0x00, -0x0f - 0x01, -0x0c, 0x7c, SOUND_SE_NULL
    .db     0x00

enemyHomerAnimationAim_0300:

    .db     0x04,  0x00, -0x0f - 0x01, -0x0c, 0x7a, SOUND_SE_NULL
    .db     0x00

enemyHomerAnimationFire:

    .dw     enemyHomerAnimationFire_0900
    .dw     enemyHomerAnimationFire_1030
    .dw     enemyHomerAnimationFire_1200
    .dw     enemyHomerAnimationFire_0000
    .dw     enemyHomerAnimationFire_0130
    .dw     enemyHomerAnimationFire_0300
    .dw     0x0000
    .dw     0x0000
    .dw     0x0000

enemyHomerAnimationFire_0900:

    .db     0x04,  0x00, -0x0f - 0x01, -0x04, 0x6b, SOUND_SE_NULL
    .db     0x10,  0x00, -0x0f - 0x01, -0x04, 0x6a, SOUND_SE_NULL
    .db     0x00

enemyHomerAnimationFire_1030:

    .db     0x04,  0x00, -0x0f - 0x01, -0x04, 0x6d, SOUND_SE_NULL
    .db     0x10,  0x00, -0x0f - 0x01, -0x04, 0x6c, SOUND_SE_NULL
    .db     0x00

enemyHomerAnimationFire_1200:

    .db     0x04,  0x00, -0x0f - 0x01, -0x04, 0x6f, SOUND_SE_NULL
    .db     0x10,  0x00, -0x0f - 0x01, -0x04, 0x6e, SOUND_SE_NULL
    .db     0x00

enemyHomerAnimationFire_0000:

    .db     0x04,  0x00, -0x0f - 0x01, -0x0c, 0x7f, SOUND_SE_NULL
    .db     0x10,  0x00, -0x0f - 0x01, -0x0c, 0x7e, SOUND_SE_NULL
    .db     0x00

enemyHomerAnimationFire_0130:

    .db     0x04,  0x00, -0x0f - 0x01, -0x0c, 0x7d, SOUND_SE_NULL
    .db     0x10,  0x00, -0x0f - 0x01, -0x0c, 0x7c, SOUND_SE_NULL
    .db     0x00

enemyHomerAnimationFire_0300:

    .db     0x04,  0x00, -0x0f - 0x01, -0x0c, 0x7b, SOUND_SE_NULL
    .db     0x10,  0x00, -0x0f - 0x01, -0x0c, 0x7a, SOUND_SE_NULL
    .db     0x00

enemyHomerAnimationFixLeft:

    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x64, SOUND_SE_NULL
    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x60, SOUND_SE_NULL
    .db     0x00

enemyHomerAnimationFixRight:

    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x74, SOUND_SE_NULL
    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x70, SOUND_SE_NULL
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

