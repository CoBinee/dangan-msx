; EnemyHead.s : ヘッド
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
ENEMY_HEAD_OFFSET_Y             =   -0x16
ENEMY_HEAD_EJECT_SPEED          =   -0x00c0
ENEMY_HEAD_EJECT_BRAKE          =   0x0008
ENEMY_HEAD_MOVE_SPEED_X         =   0x0400
ENEMY_HEAD_MOVE_ACCEL_X         =   0x0010
ENEMY_HEAD_MOVE_SPEED_Y         =   0x0400
ENEMY_HEAD_MOVE_ACCEL_Y         =   0x0010
ENEMY_HEAD_FIRE_DISTANCE        =   0x04
ENEMY_HEAD_FIRE_INTERVAL        =   0x0c
ENEMY_HEAD_LIMIT_LEFT           =   0x08
ENEMY_HEAD_LIMIT_RIGHT          =   0xf8
ENEMY_HEAD_LIFE_MAXIMUM         =   0x0020


; CODE 領域
;
    .area   _CODE

; エネミーを登場させる
;
_EnemyHeadSpawn::
    
    ; レジスタの保存

    ; ix < エネミー
    ; de < Y/X位置
    
    ; エネミーの初期化
    push    bc
    push    de
    ld      hl, #enemyHeadDefault
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    pop     de
    pop     bc

    ; 位置の設定
    ld      CHARACTER_POSITION_X_H(ix), e
    ld      a, d
    add     a, #ENEMY_HEAD_OFFSET_Y
    ld      CHARACTER_POSITION_Y_H(ix), a

    ; 向きの設定
    call    _SystemGetRandom
    and     #0x08
    jr      z, 39$
    set     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
39$:

    ; ENEMY_THINK_0 : 待機時間

    ; ENEMY_THINK_1-2 : 移動先

    ; ENEMY_THINK_3 : 発射までの時間
    
    ; カウントの更新
    call    _EnemyIncCount

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーがイジェクトする
;
EnemyHeadEject:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; 速度の設定
    ld      hl, #ENEMY_HEAD_EJECT_SPEED
    ld      CHARACTER_SPEED_Y_L(ix), l
    ld      CHARACTER_SPEED_Y_H(ix), h

    ; ENEMY_THINK_0 :  待機時間
    ld      ENEMY_THINK_0(ix), #0x18

    ; アニメーションの開始
    ld      hl, #enemyHeadAnimationIdle
    call    _CharacterStartAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; 移動
    ld      de, #ENEMY_HEAD_EJECT_BRAKE
    call    _CharacterBrakeY
    call    _CharacterMoveY
    ld      a, CHARACTER_SPEED_Y_H(ix)
    or      CHARACTER_SPEED_Y_L(ix)
    jr      nz, 190$

    ; 時間の更新
    dec     ENEMY_THINK_0(ix)
    jr      nz, 190$

    ; 処理の更新
    ld      hl, #EnemyHeadMove
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
;   jr      190$

    ; イジェクトの完了
190$:

    ; アニメーションの更新
    call    _CharacterUpdateAnimation

    ; 終了
    ret

; エネミーが移動する
;
EnemyHeadMove:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; ENEMY_THINK_1-2 : 移動先
    call    180$

    ; ENEMY_THINK_3 :  発射までの時間
    ld      ENEMY_THINK_0(ix), #0x00

    ; アニメーションの開始
    ld      hl, #enemyHeadAnimationIdle
    call    _CharacterStartAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; X の移動
    ld      a, ENEMY_THINK_2(ix)
    ld      e, CHARACTER_POSITION_X_H(ix)
    bit     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    jr      nz, 100$
    cp      e
    jr      nc, 108$
    ld      de, #-ENEMY_HEAD_MOVE_ACCEL_X
    ld      bc, #ENEMY_HEAD_MOVE_SPEED_X
    call    _CharacterAccelX
    jr      109$
100$:
    cp      e
    jr      c, 108$
    ld      de, #ENEMY_HEAD_MOVE_ACCEL_X
    ld      bc, #ENEMY_HEAD_MOVE_SPEED_X
    call    _CharacterAccelX
    jr      109$
108$:
    ld      de, #ENEMY_HEAD_MOVE_ACCEL_X
    call    _CharacterBrakeX
;   jr      109$
109$:
    call    _CharacterMoveX

    ; Y の移動
    ld      a, CHARACTER_POSITION_Y_H(ix)
    cp      #0x20
    jr      nc, 110$
    ld      de, #ENEMY_HEAD_MOVE_ACCEL_Y
    jr      111$
110$:
    ld      de, #-ENEMY_HEAD_MOVE_ACCEL_Y
111$:
    ld      bc, #ENEMY_HEAD_MOVE_SPEED_Y
    call    _CharacterAccelY
    call    _CharacterMoveY

    ; 移動の監視
    ld      a, CHARACTER_SPEED_X_H(ix)
    or      CHARACTER_SPEED_X_L(ix)
    call    z, 180$
    jr      190$

    ; 移動先の設定
180$:
    call    _PlayerGetPosition
    ld      a, CHARACTER_POSITION_X_H(ix)
    cp      e
    jr      c, 182$
    ld      a, e
    sub     #0x40
    jr      nc, 181$
    xor     a
181$:
    jr      183$
182$:
    ld      a, e
    cp      #0xc0
    jr      c, 183$
    ld      a, #0xc0
183$:
    ld      e, a
    call    _SystemGetRandom
    and     #0x3f
    add     a, e
    ld      ENEMY_THINK_1(ix), a
    ld      e, CHARACTER_POSITION_X_H(ix)
    sub     e
    sra     a
    add     a, e
    ld      ENEMY_THINK_2(ix), a
    ld      a, ENEMY_THINK_1(ix)
    cp      CHARACTER_POSITION_X_H(ix)
    jr      nc, 184$
    res     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    jr      185$
184$:
    set     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
185$:
    ret

    ; 移動の完了
190$:

    ; 発射までの時間の更新
    ld      a, ENEMY_THINK_3(ix)
    or      a
    jr      z, 20$
    dec     ENEMY_THINK_3(ix)
    jr      nz, 29$
20$:

    ; 距離の確認
    call    _PlayerGetPosition
    ld      a, CHARACTER_POSITION_X_H(ix)
    sub     e
    jr      nc, 21$
    neg
21$:
    cp      #ENEMY_HEAD_FIRE_DISTANCE
    jr      nc, 29$

    ; ミサイルの発射
    ld      hl, #enemyHeadMuzzle
    ld      a, #ENEMY_AIM_0600
    call    _EnemyFireStraight

    ; 発射までの時間の更新
    ld      ENEMY_THINK_3(ix), #ENEMY_HEAD_FIRE_INTERVAL

    ; 発射の完了
29$:

    ; アニメーションの更新
    call    _CharacterUpdateAnimation

    ; 終了
    ret

; エネミーが死亡する
;
EnemyHeadDead:
    
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
    and     #0x1f
    sub     #0x10
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
    and     #0x0f
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
enemyHeadDefault:

    .dw     EnemyHeadEject
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
    .dw     ENEMY_HEAD_LIFE_MAXIMUM ; CHARACTER_LIFE_NULL
    .dw     EnemyHeadDead ; ENEMY_DEAD_NULL
    .dw     _CharacterPrintSprite2x1 ; ENEMY_PRINT_NULL
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
enemyHeadMuzzle:

    .db      0x00,  0x00
    .db      0x00,  0x00
    .db      0x00,  0x00
    .db      0x00,  0x00
    .db      0x00,  0x00
    .db      0x00,  0x00
    .db      0x00,  0x00
    .db      0x00,  0x00
    .db      0x00,  0x00

; アニメーション
;
enemyHeadAnimationIdle:

    .db     0xff,  0x00, -0x0f - 0x01, -0x10, 0xae, SOUND_SE_NULL


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

