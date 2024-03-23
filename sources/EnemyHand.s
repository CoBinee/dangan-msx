; EnemyHand.s : ハンド
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
ENEMY_HAND_SPEED_EJECT          =   0x0100
ENEMY_HAND_BRAKE_EJECT          =   0x0010
ENEMY_HAND_LIFE_MAXIMUM         =   0x0030
ENEMY_HAND_LIFE_EJECT           =   0x0020


; CODE 領域
;
    .area   _CODE

; エネミーを登場させる
;
_EnemyHandSpawn::
    
    ; レジスタの保存

    ; ix < エネミー
    ; de < フライア
    ; c  < 1 = 右手
    
    ; エネミーの初期化
    push    bc
    push    de
    ld      hl, #enemyHandDefault
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    pop     de
    pop     bc

    ; 向きの設定
    ld      a, c
    or      a
    jr      nz, 30$
    ld      a, #ENEMY_AIM_0430
;   res     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    jr      39$
30$:
    ld      a, #ENEMY_AIM_0730
    set     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
;   jr      39$
39$:

    ; ENEMY_THINK_0 : 照準
    ld      ENEMY_THINK_0(ix), a

    ; ENEMY_THINK_1-2 : 移動先
    
    ; ENEMY_THINK_6-7 : フライア
    ld      ENEMY_THINK_6(ix), e
    ld      ENEMY_THINK_7(ix), d

    ; 位置の設定
    call    EnemyHandSetConnectPosition

    ; カウントの更新
    call    _EnemyIncCount

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーが待機する
;
EnemyHandIdle:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; アニメーションの開始
    ld      hl, #enemyHandAnimationIdle
    ld      a, ENEMY_THINK_0(ix)
    call    _CharacterStartIndexAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

;   ; プレイの監視
;   call    _GameIsPlay
;   jr      nc, 190$

    ; ライフの確認
    ld      l, CHARACTER_LIFE_L(ix)
    ld      h, CHARACTER_LIFE_H(ix)
    ld      de, #ENEMY_HAND_LIFE_EJECT
    or      a
    sbc     hl, de
    jr      c, 180$

    ; フライヤの監視
    ld      l, ENEMY_THINK_6(ix)
    ld      h, ENEMY_THINK_7(ix)
    ld      de, #CHARACTER_FLAG
    add     hl, de
    bit     #ENEMY_FLAG_EJECT_BIT, (hl)
    jr      z, 190$
    
    ; 処理の更新
180$:
    ld      hl, #EnemyHandEject
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
;   jr      190$

    ; 待機の完了
190$:

    ; アニメーションの更新
    call    _CharacterUpdateAnimation

    ; フライアに接続
    call    EnemyHandSetConnectPosition

    ; 死亡の確認
    call    EnemyHandIsFlierDeadThen

    ; 終了
    ret

; エネミーがイジェクトする
;
EnemyHandEject:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; 速度の設定
    ld      hl, #ENEMY_HAND_SPEED_EJECT
    ld      CHARACTER_SPEED_Y_L(ix), l
    ld      CHARACTER_SPEED_Y_H(ix), h
    bit     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    jr      nz, 00$
;   ld      hl, #ENEMY_HAND_SPEED_EJECT
    jr      01$
00$:
    ld      hl, #-ENEMY_HAND_SPEED_EJECT
01$:
    ld      CHARACTER_SPEED_X_L(ix), l
    ld      CHARACTER_SPEED_X_H(ix), h

    ; アニメーションの開始
    ld      hl, #enemyHandAnimationIdle
    ld      a, ENEMY_THINK_0(ix)
    call    _CharacterStartIndexAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; 移動
    ld      de, #ENEMY_HAND_BRAKE_EJECT
    call    _CharacterBrakeX
    call    _CharacterBrakeY
    call    _CharacterMoveX
    call    _CharacterMoveY
    ld      a, CHARACTER_SPEED_X_H(ix)
    or      CHARACTER_SPEED_X_L(ix)
    jr      nz, 190$

    ; 処理の更新
    ld      hl, #EnemyHandAim
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
;   jr      190$

    ; イジェクトの完了
190$:

    ; アニメーションの更新
    call    _CharacterUpdateAnimation

    ; 死亡の確認
    call    EnemyHandIsFlierDeadThen

    ; 終了
    ret

; エネミーが狙いを定める
;
EnemyHandAim:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; ENEMY_THINK_1-2 : 移動先
    call    _SystemGetRandom
    and     #0x30
    add     a, #0x10
    ld      ENEMY_THINK_2(ix), a
    call    _SystemGetRandom
    and     #0x7f
    bit     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    jr      nz, 00$
    add     a, #0x70
    jr      01$
00$:
    add     a, #0x10
01$:
    ld      ENEMY_THINK_1(ix), a

    ; アニメーションの開始
    ld      hl, #enemyHandAnimationIdle
    ld      a, ENEMY_THINK_0(ix)
    call    _CharacterStartIndexAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; 移動
    ld      e, ENEMY_THINK_1(ix)
    ld      a, CHARACTER_POSITION_X_H(ix)
    call    100$
    ld      CHARACTER_POSITION_X_H(ix), a
    ld      e, ENEMY_THINK_2(ix)
    ld      a, CHARACTER_POSITION_Y_H(ix)
    call    100$
    ld      CHARACTER_POSITION_Y_H(ix), a
    jr      109$
100$:
    sub     e
    jr      z, 104$
    jr      nc, 102$
    neg
    ld      c, a
    srl     c
    srl     c
    jr      nz, 101$
    inc     c
101$:
    sub     c
    ccf
    jr      nc, 104$
    sub     e
    neg
    jr      105$
102$:
    ld      c, a
    srl     c
    srl     c
    jr      nz, 103$
    inc     c
103$:
    sub     c
    ccf
    jr      nc, 104$
    add     a, e
    jr      105$
104$:
    ld      a, e
105$:
    ret
109$:

    ; 照準の設定
    call    _PlayerGetPosition
    ld      a, CHARACTER_POSITION_X_H(ix)
    sub     e
    jr      nc, 110$
    neg
    cp      #(APP_VIEW_SIZE_Y * APP_VIEW_PIXEL / 4)
    jr      c, 111$
    ld      a, #ENEMY_AIM_0430
    jr      112$
110$:
    cp      #(APP_VIEW_SIZE_Y * APP_VIEW_PIXEL / 4)
    jr      c, 111$
    ld      a, #ENEMY_AIM_0730
    jr      112$
111$:
    ld      a, #ENEMY_AIM_0600
;   jr      112$
112$:
    cp      ENEMY_THINK_0(ix)
    jr      z, 119$
    ld      ENEMY_THINK_0(ix), a

    ; アニメーションの開始
    ld      hl, #enemyHandAnimationIdle
;   ld      a, ENEMY_THINK_0(ix)
    call    _CharacterStartIndexAnimation
119$:

    ; 移動の監視
    ld      a, CHARACTER_POSITION_X_H(ix)
    cp      ENEMY_THINK_1(ix)
    jr      nz, 190$
    ld      a, CHARACTER_POSITION_Y_H(ix)
    cp      ENEMY_THINK_2(ix)
    jr      nz, 190$

    ; プレイヤの存在
    call    _PlayerIsLive
    jr      nc, 189$

    ; ランダムに発射
    call    _SystemGetRandom
    and     #0x11
    jr      nz, 189$

    ; 処理の更新
    ld      hl, #EnemyHandFire
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
189$:
    ld      CHARACTER_STATE(ix), #0x00

    ; 狙うの完了
190$:

    ; アニメーションの更新
    call    _CharacterUpdateAnimation

    ; 死亡の確認
    call    EnemyHandIsFlierDeadThen

    ; 終了
    ret

; エネミーが発射する
;
EnemyHandFire:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; アニメーションの開始
    ld      hl, #enemyHandAnimationFire
    ld      a, ENEMY_THINK_0(ix)
    call    _CharacterStartIndexAnimation

    ; ミサイルの発射
    ld      hl, #enemyHandMuzzle
    ld      a, ENEMY_THINK_0(ix)
    call    _EnemyFireStraight

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; アニメーションの監視
    call    _CharacterIsDoneAnimation
    jr      nc, 190$

    ; 処理の更新
    ld      hl, #EnemyHandAim
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
;   jr      190$

    ; 発射の完了
190$:

    ; アニメーションの更新
    call    _CharacterUpdateAnimation

    ; 死亡の確認
    call    EnemyHandIsFlierDeadThen

    ; 終了
    ret

; フライアに接続する位置を設定する
;
EnemyHandSetConnectPosition:

    ; レジスタの保存

    ; フライアに接続
    ld      l, ENEMY_THINK_6(ix)
    ld      h, ENEMY_THINK_7(ix)
    push    hl
    pop     iy
    ld      hl, #(enemyHandConnect + 0x0000)
    bit     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    jr      z, 10$
    ld      hl, #(enemyHandConnect + 0x0002)
10$:
    ld      a, CHARACTER_POSITION_X_H(iy)
    add     a, (hl)
    ld      CHARACTER_POSITION_X_H(ix), a
    ld      a, CHARACTER_POSITION_X_L(iy)
    ld      CHARACTER_POSITION_X_L(ix), a
    inc     hl
    ld      a, CHARACTER_POSITION_Y_H(iy)
    add     a, (hl)
    ld      CHARACTER_POSITION_Y_H(ix), a
    ld      a, CHARACTER_POSITION_Y_L(iy)
    ld      CHARACTER_POSITION_Y_L(ix), a
;   inc     hl

    ; レジスタの復帰

    ; 終了
    ret

; フライアが死んだら死ぬ
;
EnemyHandIsFlierDeadThen:

    ; レジスタの保存

    ; フライアの死亡
    ld      l, ENEMY_THINK_6(ix)
    ld      h, ENEMY_THINK_7(ix)
    ld      de, #CHARACTER_PROC_L
    add     hl, de
    ld      a, (hl)
    inc     hl
    or      (hl)
    jr      nz, 19$

    ; 処理の更新
    ld      l, ENEMY_DEAD_L(ix)
    ld      CHARACTER_PROC_L(ix), l
    ld      h, ENEMY_DEAD_H(ix)
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
enemyHandDefault:

    .dw     EnemyHandIdle
    .db     CHARACTER_STATE_NULL
    .db     ENEMY_FLAG_COUNT ; CHARACTER_FLAG_NULL
    .dw     CHARACTER_POSITION_NULL
    .dw     CHARACTER_POSITION_NULL
    .dw     CHARACTER_SPEED_NULL
    .dw     CHARACTER_SPEED_NULL
    .db     0x0e ; CHARACTER_RECT_NULL
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
    .dw     ENEMY_HAND_LIFE_MAXIMUM ; CHARACTER_LIFE_NULL
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
enemyHandMuzzle:

    .db      0x00,  0x00
    .db      0x00,  0x00
    .db      0x00,  0x00
    .db      0x00,  0x00
    .db      0x00,  0x00
    .db      0x00,  0x00
    .db      0x07,  0x00
    .db      0x00,  0x00
    .db     -0x05,  0x00

; 接続
;
enemyHandConnect:

    .db      0x15, -0x04
    .db     -0x15, -0x04

; アニメーション
;
enemyHandAnimationIdle:

    .dw     0x0000
    .dw     0x0000
    .dw     0x0000
    .dw     0x0000
    .dw     0x0000
    .dw     0x0000
    .dw     enemyHandAnimationIdle_0430
    .dw     enemyHandAnimationIdle_0600
    .dw     enemyHandAnimationIdle_0730

enemyHandAnimationIdle_0430:

    .db     0xff,  0x00, -0x0f - 0x01, -0x08, 0xaa, SOUND_SE_NULL

enemyHandAnimationIdle_0600:

    .db     0xff,  0x00, -0x0f - 0x01, -0x08, 0xa6, SOUND_SE_NULL

enemyHandAnimationIdle_0730:

    .db     0xff,  0x00, -0x0f - 0x01, -0x08, 0xa2, SOUND_SE_NULL

enemyHandAnimationFire:

    .dw     0x0000
    .dw     0x0000
    .dw     0x0000
    .dw     0x0000
    .dw     0x0000
    .dw     0x0000
    .dw     enemyHandAnimationFire_0430
    .dw     enemyHandAnimationFire_0600
    .dw     enemyHandAnimationFire_0730

enemyHandAnimationFire_0430:

    .db     0x04,  0x00, -0x0f - 0x01, -0x08, 0xac, SOUND_SE_NULL
    .db     0x1c,  0x00, -0x0f - 0x01, -0x08, 0xaa, SOUND_SE_NULL
    .db     0x00

enemyHandAnimationFire_0600:

    .db     0x04,  0x00, -0x0f - 0x01, -0x08, 0xa8, SOUND_SE_NULL
    .db     0x1c,  0x00, -0x0f - 0x01, -0x08, 0xa6, SOUND_SE_NULL
    .db     0x00

enemyHandAnimationFire_0730:

    .db     0x04,  0x00, -0x0f - 0x01, -0x08, 0xa4, SOUND_SE_NULL
    .db     0x1c,  0x00, -0x0f - 0x01, -0x08, 0xa2, SOUND_SE_NULL
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

