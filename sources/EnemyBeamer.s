; EnemyBeamer.s : ビーマー
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
ENEMY_BEAMER_SPEED_Y_MAXIMUM    =   0x0800
ENEMY_BEAMER_ACCEL_GRAVITY      =   0x0010
ENEMY_BEAMER_LIFE_MAXIMUM       =   0xffff


; CODE 領域
;
    .area   _CODE

; エネミーを登場させる
;
_EnemyBeamerSpawn::
    
    ; レジスタの保存

    ; ix < エネミー
    
    ; エネミーの初期化
    push    bc
    push    de
    ld      hl, #enemyBeamerDefault
    push    ix
    pop     de
    ld      bc, #ENEMY_LENGTH
    ldir
    pop     de
    pop     bc

    ; 位置と向きの設定
    call    _PlayerGetPosition
    ld      a, e
    cp      #0x80
    jr      nc, 20$
    ld      a, #0xd0
    jr      21$
20$:
    ld      a, #0x30
    set     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
21$:
    ld      CHARACTER_POSITION_X_H(ix), a
    ld      CHARACTER_POSITION_Y_H(ix), #0x00

    ; ENEMY_THINK_0 : 歩数

    ; ENEMY_THINK_1-4 : ビームの位置
    xor     a
    ld      ENEMY_THINK_1(ix), a
    ld      ENEMY_THINK_2(ix), a
;   ld      ENEMY_THINK_3(ix), a
;   ld      ENEMY_THINK_4(ix), a

    ; ENEMY_THINK_5 : ビームの移動距離

    ; カウントの更新
    call    _EnemyIncCount

    ; レジスタの復帰
    
    ; 終了
    ret

; エネミーが落下する
;
EnemyBeamerFall:

    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; アニメーションの開始
    ld      hl, #enemyBeamerAnimationFallLeft
    ld      de, #enemyBeamerAnimationFallRight
    call    _CharacterStartDirectionAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; Y の移動
    ld      de, #ENEMY_BEAMER_ACCEL_GRAVITY
    ld      bc, #ENEMY_BEAMER_SPEED_Y_MAXIMUM
    call    _CharacterAccelY
    call    _CharacterMoveY

    ; 着地
    call    _CharacterIsLand
    jr      nc, 190$

    ; 処理の更新
    ld      hl, #EnemyBeamerLand
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
EnemyBeamerLand:

    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; アニメーションの開始
    ld      hl, #enemyBeamerAnimationLandLeft
    ld      de, #enemyBeamerAnimationLandRight
    call    _CharacterStartDirectionAnimation

    ; プレイヤを振り向かせる
    bit     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    jr      nz, 00$
    call    _PlayerSetTurnRight
    jr      01$
00$:
    call    _PlayerSetTurnLeft
01$:

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; アニメーションの監視
    call    _CharacterIsDoneAnimation
    jr      nc, 190$

    ; 処理の更新
    ld      hl, #EnemyBeamerWalk
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
;   jr      190$

    ; 着地の完了
190$:

    ;  アニメーションの更新
    call    _CharacterUpdateAnimation

    ; レジスタの復帰

    ; 終了
    ret

; エネミーが歩く
;
EnemyBeamerWalk:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; ENEMY_THINK_0: 歩数
    ld      ENEMY_THINK_0(ix), #(0x03 + 0x01)

    ; アニメーションの開始
    ld      hl, #enemyBeamerAnimationWalkLeft
    ld      de, #enemyBeamerAnimationWalkRight
    call    _CharacterStartDirectionAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

;   ; プレイの監視
;   call    _GameIsPlay
;   jr      nc, 190$

    ; アニメーションの監視
    call    _CharacterIsDoneAnimation
    jp      nc, 190$

    ; 歩数の更新
    dec     ENEMY_THINK_0(ix)
    jr      z, 180$

    ; アニメーションの開始
    ld      hl, #enemyBeamerAnimationWalkLeft
    ld      de, #enemyBeamerAnimationWalkRight
    call    _CharacterStartDirectionAnimation
    jr      190$

    ; 発射
180$:

    ; 処理の更新
    ld      hl, #EnemyBeamerFire
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
EnemyBeamerFire:
    
    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; アニメーションの開始
    ld      hl, #enemyBeamerAnimationAimLeft
    ld      de, #enemyBeamerAnimationAimRight
    call    _CharacterStartDirectionAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; アニメーションの監視
    call    _CharacterIsDoneAnimation
    jr      nc, 190$

    ; 0x01 : 発射
110$:
    ld      a, CHARACTER_STATE(ix)
    dec     a
    jr      nz, 120$

    ; アニメーションの開始
    ld      hl, #enemyBeamerAnimationFireLeft
    ld      de, #enemyBeamerAnimationFireRight
    call    _CharacterStartDirectionAnimation

    ; ビームの設定
    ld      a, CHARACTER_POSITION_X_H(ix)
    rrca
    rrca
    rrca
    and     #0x1f
    ld      e, a
    ld      c, a
    ld      a, CHARACTER_POSITION_Y_H(ix)
    sub     #0x08
    ld      d, #0x00
    add     a, a
    rl      d
    add     a, a
    rl      d
    and     a, #0xe0
    add     a, e
    ld      e, a
    ld      hl, #_stage
    add     hl, de
    ld      ENEMY_THINK_1(ix), l
    ld      ENEMY_THINK_2(ix), h
    ld      a, c
    bit     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    jr      z, 111$
    sub     #0x20
    neg
111$:
    inc     a
    ld      ENEMY_THINK_5(ix), a

    ; 状態の更新
    inc     CHARACTER_STATE(ix)
    jr      190$
    
    ; 0x02 : 
120$:
    dec     a
    jr      nz, 130$

    ; 状態の更新
    inc     CHARACTER_STATE(ix)
129$:
    jr      190$

    ; 0x03 : 
130$:
;   dec     a
;   jr      nz, 140$
;   jr      190$

    ; 発射の完了
190$:

    ; アニメーションの更新
    call    _CharacterUpdateAnimation
    
    ; ビームの移動
    ld      l, ENEMY_THINK_1(ix)
    ld      h, ENEMY_THINK_2(ix)
    ld      ENEMY_THINK_3(ix), l
    ld      ENEMY_THINK_4(ix), h
    ld      a, h
    or      l
    jr      z, 39$
    bit     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    jr      nz, 30$
    dec     hl
    jr      31$
30$:
    inc     hl
31$:
    ld      ENEMY_THINK_1(ix), l
    ld      ENEMY_THINK_2(ix), h
    dec     ENEMY_THINK_5(ix)
    jr      z, 38$

    ; プレイヤへのダメージ
    ld      de, #_stage
    or      a
    sbc     hl, de
    ld      a, l
    and     #0x1f
    ld      l, a
    call    _PlayerGetPosition
    ld      a, e
    rrca
    rrca
    rrca
    and     #0x1f
    cp      l
    ld      hl, #PLAYER_LIFE_MAXIMUM
    call    z, _PlayerSetDamage
    jr      39$

    ; ビームの完了
38$:
    xor     a
    ld      ENEMY_THINK_1(ix), a
    ld      ENEMY_THINK_2(ix), a
39$:

    ; 終了
    ret

; エネミーを描画する
;
EnemyBeamerPrint:

    ; レジスタの保存

    ; エネミーの描画
    call    _CharacterPrintSprite1x1

    ; ビームの消去
    ld      l, ENEMY_THINK_3(ix)
    ld      h, ENEMY_THINK_4(ix)
    ld      a, h
    or      l
    jr      z, 19$
    ld      (hl), #0x70
19$:

    ; ビームの描画
    ld      l, ENEMY_THINK_1(ix)
    ld      h, ENEMY_THINK_2(ix)
    ld      a, h
    or      l
    jr      z, 29$
    ld      (hl), #0x4f
29$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; エネミーの初期値
;
enemyBeamerDefault:

    .dw     EnemyBeamerFall
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
    .dw     ENEMY_BEAMER_LIFE_MAXIMUM ; CHARACTER_LIFE_NULL
    .dw     _EnemyDead1x1 ; ENEMY_DEAD_NULL
    .dw     EnemyBeamerPrint ; ENEMY_PRINT_NULL
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
enemyBeamerMuzzle:

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
enemyBeamerAnimationIdleLeft:

    .db     0xff,  0x00, -0x0f - 0x01, -0x08, 0x80, SOUND_SE_NULL

enemyBeamerAnimationIdleRight:

    .db     0xff,  0x00, -0x0f - 0x01, -0x08, 0x90, SOUND_SE_NULL

enemyBeamerAnimationFallLeft:

    .db     0xff,  0x00, -0x0f - 0x01, -0x08, 0x86, SOUND_SE_NULL

enemyBeamerAnimationFallRight:

    .db     0xff,  0x00, -0x0f - 0x01, -0x08, 0x96, SOUND_SE_NULL

enemyBeamerAnimationLandLeft:

    .db     0x48,  0x00, -0x0f - 0x01, -0x08, 0x84, SOUND_SE_LAND
    .db     0x18,  0x00, -0x0f - 0x01, -0x08, 0x80, SOUND_SE_NULL
    .db     0x00

enemyBeamerAnimationLandRight:

    .db     0x48,  0x00, -0x0f - 0x01, -0x08, 0x94, SOUND_SE_LAND
    .db     0x18,  0x00, -0x0f - 0x01, -0x08, 0x90, SOUND_SE_NULL
    .db     0x00

enemyBeamerAnimationWalkLeft:

    .db     0x08, -0x02, -0x0f - 0x01, -0x08, 0x81, SOUND_SE_NULL
    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x82, SOUND_SE_WALK
    .db     0x08, -0x02, -0x0f - 0x01, -0x08, 0x83, SOUND_SE_NULL
    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x80, SOUND_SE_NULL
    .db     0x00

enemyBeamerAnimationWalkRight:

    .db     0x08,  0x02, -0x0f - 0x01, -0x08, 0x91, SOUND_SE_NULL
    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x92, SOUND_SE_WALK
    .db     0x08,  0x02, -0x0f - 0x01, -0x08, 0x93, SOUND_SE_NULL
    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x90, SOUND_SE_NULL
    .db     0x00

enemyBeamerAnimationAimLeft:

    .db     0x18,  0x00, -0x0f - 0x01, -0x08, 0x80, SOUND_SE_NULL
    .db     0x30,  0x00, -0x0f - 0x01, -0x06, 0x8a, SOUND_SE_NULL
    .db     0x00

enemyBeamerAnimationAimRight:

    .db     0x18,  0x00, -0x0f - 0x01, -0x08, 0x90, SOUND_SE_NULL
    .db     0x30,  0x00, -0x0f - 0x01, -0x0a, 0x9a, SOUND_SE_NULL
    .db     0x00

enemyBeamerAnimationFireLeft:

    .db     0x02,  0x00, -0x0f - 0x01, -0x06, 0x8b, SOUND_SE_BEAM
    .db     0x1e,  0x00, -0x0f - 0x01, -0x06, 0x8c, SOUND_SE_NULL
    .db     0x00

enemyBeamerAnimationFireRight:

    .db     0x02,  0x00, -0x0f - 0x01, -0x0a, 0x9b, SOUND_SE_BEAM
    .db     0x1e,  0x00, -0x0f - 0x01, -0x0a, 0x9c, SOUND_SE_NULL
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

