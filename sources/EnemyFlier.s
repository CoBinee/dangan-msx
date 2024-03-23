; EnemyFlier.s : フライア
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
    .include    "Missile.inc"
    .include    "Bomb.inc"
    .include    "Character.inc"
    .include    "Player.inc"
    .include	"Enemy.inc"

; 外部変数宣言
;

; マクロの定義
;
ENEMY_FLIER_LIFE_MAXIMUM        =   0x00e0
ENEMY_FLIER_LIFE_EJECT          =   0x00b0
ENEMY_FLIER_LIFE_HOMING         =   0x0080


; CODE 領域
;
    .area   _CODE

; エネミーを登場させる
;
_EnemyFlierSpawn::
    
    ; レジスタの保存

    ; ix < エネミー
    ; de < Y/X 位置
    
    ; エネミーの初期化
    push    bc
    push    de
    ld      hl, #enemyFlierDefault
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    pop     de
    pop     bc

    ; 位置の設定
    ld      CHARACTER_POSITION_X_H(ix), e
    ld      CHARACTER_POSITION_Y_H(ix), d

    ; ENEMY_THINK_0 : 移動
    ld      ENEMY_THINK_0(ix), #0x40

    ; ENEMY_THINK_1 : 発射までの時間

    ; ENEMY_THINK_2 : 発射回数

    ; ENEMY_THINK_3-4 : 発射テーブル

    ; ENEMY_THINK_5-6 : ミサイル

    ; カウントの更新
    call    _EnemyIncCount

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーが準備する
;
EnemyFlierStandBy:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; 速度の設定
    ld      CHARACTER_SPEED_Y_L(ix), #<-0x0400
    ld      CHARACTER_SPEED_Y_H(ix), #>-0x0400

    ; アニメーションの開始
    ld      hl, #enemyFlierAnimationIdle
    call    _CharacterStartAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; プレイの監視
    call    _GameIsPlay
    jr      nc, 190$

    ; 移動
    ld      de, #0x0018
    ld      l, CHARACTER_SPEED_Y_L(ix)
    ld      h, CHARACTER_SPEED_Y_H(ix)
    or      a
    adc     hl, de
    jr      nc, 100$
    ld      hl, #0x0000
100$:
    ex      de, hl
    ld      l, CHARACTER_POSITION_Y_L(ix)
    ld      h, CHARACTER_POSITION_Y_H(ix)
    add     hl, de
    ld      CHARACTER_SPEED_Y_L(ix), e
    ld      CHARACTER_SPEED_Y_H(ix), d
    ld      CHARACTER_POSITION_Y_L(ix), l
    ld      CHARACTER_POSITION_Y_H(ix), h
    ld      a, d
    or      e
    jr      nz, 190$

    ; 処理の更新
    ld      hl, #EnemyFlierIdle
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

; エネミーが待機する
;
EnemyFlierIdle:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; ENEMY_THINK_1 : 発射までの時間
    call    _SystemGetRandom
    or      #0x80
    ld      ENEMY_THINK_1(ix), a

    ; アニメーションの開始
    ld      hl, #enemyFlierAnimationIdle
    call    _CharacterStartAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

;   ; プレイの監視
;   call    _GameIsPlay
;   jr      nc, 190$

    ; 移動
    ld      de, #0x0001
    ld      a, ENEMY_THINK_0(ix)
    cp      #0x80
    jr      c, 100$
    ld      de, #-0x0001
100$:
    ld      l, CHARACTER_SPEED_Y_L(ix)
    ld      h, CHARACTER_SPEED_Y_H(ix)
    add     hl, de
    ex      de, hl
    ld      l, CHARACTER_POSITION_Y_L(ix)
    ld      h, CHARACTER_POSITION_Y_H(ix)
    add     hl, de
    ld      CHARACTER_SPEED_Y_L(ix), e
    ld      CHARACTER_SPEED_Y_H(ix), d
    ld      CHARACTER_POSITION_Y_L(ix), l
    ld      CHARACTER_POSITION_Y_H(ix), h
    inc     ENEMY_THINK_0(ix)

    ; 時間の更新
    dec     ENEMY_THINK_1(ix)
    jr      nz, 190$

    ; プレイヤの存在
    call    _PlayerIsLive
    jr      nc, 189$

    ; 処理の更新
    ld      hl, #EnemyFlierFire
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
189$:
    ld      CHARACTER_STATE(ix), #0x00
;   jr      190$

    ; 待機の完了
190$:

    ; アニメーションの更新
    call    _CharacterUpdateAnimation

    ; イジェクトの更新
    ld      l, CHARACTER_LIFE_L(ix)
    ld      h, CHARACTER_LIFE_H(ix)
    ld      de, #ENEMY_FLIER_LIFE_EJECT
    or      a
    sbc     hl, de
    jr      nc, 30$
    set     #ENEMY_FLAG_EJECT_BIT, CHARACTER_FLAG(ix)
30$:

    ; 終了
    ret

; エネミーが発射する
;
EnemyFlierFire:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; 発射の設定
    ld      l, CHARACTER_LIFE_L(ix)
    ld      h, CHARACTER_LIFE_H(ix)
    ld      de, #ENEMY_FLIER_LIFE_HOMING
    or      a
    sbc     hl, de
    jr      nc, 00$
    call    _SystemGetRandom
    and     #0x44
    jr      z, 00$
    ld      hl, #enemyFlierFireHoming
    ld      de, #_MissileFireHomingSharp
    jr      01$
00$:
    ld      hl, #enemyFlierFireVertical
    ld      de, #_MissileFireVertical
01$:
    ld      ENEMY_THINK_2(ix), #(0x06 + 0x01)
    ld      ENEMY_THINK_3(ix), l
    ld      ENEMY_THINK_4(ix), h
    ld      ENEMY_THINK_5(ix), e
    ld      ENEMY_THINK_6(ix), d
    
    ; アニメーションの開始
    ld      hl, #enemyFlierAnimationIdle
    call    _CharacterStartAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; アニメーションの監視
    call    _CharacterIsDoneAnimation
    jr      nc, 190$

    ; 発射回数の更新
    dec     ENEMY_THINK_2(ix)
    jr      z, 180$

    ; ミサイルの発射
    ld      l, ENEMY_THINK_3(ix)
    ld      h, ENEMY_THINK_4(ix)
    ld      a, CHARACTER_POSITION_X_H(ix)
    add     a, (hl)
    ld      e, a
    inc     hl
    ld      a, CHARACTER_POSITION_Y_H(ix)
    add     a, (hl)
    ld      d, a
    inc     hl
    ld      c, (hl)
    inc     hl
    ld      ENEMY_THINK_3(ix), l
    ld      ENEMY_THINK_4(ix), h
    ld      hl, #100$
    push    hl
    ld      l, ENEMY_THINK_5(ix)
    ld      h, ENEMY_THINK_6(ix)
    jp      (hl)
;   pop     hl
100$:

    ; アニメーションの開始
    ld      hl, #enemyFlierAnimationFire
    call    _CharacterStartAnimation
    jr      190$

    ; 処理の更新
180$:
    ld      hl, #EnemyFlierIdle
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
EnemyFlierDead:
    
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
    and     #0x1f
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
enemyFlierDefault:

    .dw     EnemyFlierStandBy
    .db     CHARACTER_STATE_NULL
    .db     ENEMY_FLAG_COUNT ; CHARACTER_FLAG_NULL
    .dw     CHARACTER_POSITION_NULL
    .dw     CHARACTER_POSITION_NULL
    .dw     CHARACTER_SPEED_NULL
    .dw     CHARACTER_SPEED_NULL
    .db     0x1c ; CHARACTER_RECT_NULL
    .db     0x1c ; CHARACTER_RECT_NULL
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
    .dw     ENEMY_FLIER_LIFE_MAXIMUM ; CHARACTER_LIFE_NULL
    .dw     EnemyFlierDead ; ENEMY_DEAD_NULL
    .dw     _CharacterPrintSprite2x2 ; ENEMY_PRINT_NULL
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

; 発射
;
enemyFlierFireVertical:

    .db     -0x05, -0x19, 0x00
    .db      0x05, -0x19, 0x00
    .db     -0x05, -0x19, 0x00
    .db      0x05, -0x19, 0x00
    .db     -0x05, -0x19, 0x00
    .db      0x05, -0x19, 0x00

enemyFlierFireHoming:

    .db      0x0f, -0x19, 0x30
    .db     -0x0f, -0x19, 0xd0
    .db      0x11, -0x15, 0x40
    .db     -0x11, -0x15, 0xc0
    .db      0x0f, -0x11, 0x50
    .db     -0x0f, -0x11, 0xb0

; アニメーション
;
enemyFlierAnimationIdle:

    .db     0xff,  0x00, -0x1f - 0x01, -0x0f, 0xa0, SOUND_SE_NULL

enemyFlierAnimationFire:

    .db     0x08,  0x00, -0x1f - 0x01, -0x0f, 0xa0, SOUND_SE_NULL
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

