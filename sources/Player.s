; Player.s : プレイヤ
;


; モジュール宣言
;
    .module Player

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include    "Stage.inc"
    .include    "Bullet.inc"
    .include    "Bomb.inc"
    .include    "Character.inc"
    .include	"Player.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; プレイヤを初期化する
;
_PlayerInitialize::
    
    ; レジスタの保存
    
    ; プレイヤの初期化
    ld      hl, #(_player + 0x0000)
    ld      de, #(_player + 0x0001)
    ld      bc, #(PLAYER_LENGTH - 0x0001)
    ld      (hl), #0x00
    ldir
    ld      hl, #playerDefault
    ld      de, #playerBackup
    ld      bc, #PLAYER_LENGTH
    ldir

    ; 爆発の初期化
    ld      hl, #(playerBomb + 0x0000)
    ld      de, #(playerBomb + 0x0001)
    ld      bc, #(PLAYER_BOMB_LENGTH * PLAYER_BOMB_ENTRY - 0x0001)
    ld      (hl), #0x00
    ldir
    ld      hl, #playerBomb
    ld      (playerBombEntry), hl

    ; ライフの初期化
    ld      hl, #playerLife
    ld      de, #0x0000
30$:
    ld      (hl), e
    inc     hl
    ld      (hl), d
    inc     hl
    ld      a, e
    add     a, #0x01
    daa
    jr      nc, 31$
    inc     d
31$:
    ld      e, a
    ld      a, d
    cp      #0x0a
    jr      c, 30$
    xor     a
    ld      (playerLifeFrame), a

    ; プレイヤの取得
    ld      ix, #_player

    ; 処理の設定
    ld      hl, #PlayerNull
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
    
    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを更新する
;
_PlayerUpdate::
    
    ; レジスタの保存

    ; プレイヤの取得
    ld      ix, #_player

    ; ヒットの更新
100$:
    bit     #CHARACTER_FLAG_HIT_BIT, CHARACTER_FLAG(ix)
    jr      z, 108$
    ld      a, CHARACTER_LIFE_H(ix)
    or      CHARACTER_LIFE_L(ix)
    jr      z, 103$
    ld      e, CHARACTER_HIT_SPEED_L(ix)
    ld      d, CHARACTER_HIT_SPEED_H(ix)
    ld      a, e
    or      d
    jr      z, 102$
    bit     #PLAYER_FLAG_GUARD_BIT, CHARACTER_FLAG(ix)
    jr      z, 101$
    sra     d
    rr      e
101$:
    ld      CHARACTER_SPEED_X_L(ix), e
    ld      CHARACTER_SPEED_X_H(ix), d
102$:
    ld      CHARACTER_HIT_FRAME(ix), #CHARACTER_HIT_FRAME_DAMAGE
    xor     a
    ld      CHARACTER_HIT_SPEED_L(ix), a
    ld      CHARACTER_HIT_SPEED_H(ix), a
103$:
    res     #CHARACTER_FLAG_HIT_BIT, CHARACTER_FLAG(ix)
    bit     #PLAYER_FLAG_GUARD_BIT, CHARACTER_FLAG(ix)
    jr      nz, 104$
    ld      e, CHARACTER_HIT_DAMAGE(ix)
    ld      d, #0x00
    ld      l, PLAYER_DAMAGE_L(ix)
    ld      h, PLAYER_DAMAGE_H(ix)
    add     hl, de
    ld      PLAYER_DAMAGE_L(ix), l
    ld      PLAYER_DAMAGE_H(ix), h
104$:
    ld      CHARACTER_HIT_DAMAGE(ix), #0x00
;   jr      108$
108$:
    ld      a, CHARACTER_HIT_FRAME(ix)
    or      a
    jr      z, 109$
    dec     CHARACTER_HIT_FRAME(ix)
109$:

    ; ダメージの更新
110$:
    ld      a, CHARACTER_LIFE_H(ix)
    or      CHARACTER_LIFE_L(ix)
    jr      z, 119$
    ld      l, PLAYER_DAMAGE_L(ix)
    ld      h, PLAYER_DAMAGE_H(ix)
    ld      a, h
    or      l
    jr      z, 119$
    ld      de, #100
    ld      a, h
    or      a
    jr      z, 111$
    or      a
    sbc     hl, de
    ld      PLAYER_DAMAGE_L(ix), l
    ld      PLAYER_DAMAGE_H(ix), h
    jr      117$
111$:
    ld      a, l
    sub     e
    jr      c, 112$
    ld      PLAYER_DAMAGE_L(ix), a
    jr      117$
112$:
    ld      a, l
    ld      e, #10
    sub     e
    jr      c, 113$
    ld      PLAYER_DAMAGE_L(ix), a
    jr      117$
113$:
    ld      e, #1
    dec     PLAYER_DAMAGE_L(ix)
;   jr      117$
117$:
    ld      l, CHARACTER_LIFE_L(ix)
    ld      h, CHARACTER_LIFE_H(ix)
    or      a
    sbc     hl, de
    jr      nc, 118$
    ld      hl, #0x0000
118$:
    ld      CHARACTER_LIFE_L(ix), l
    ld      CHARACTER_LIFE_H(ix), h
    ld      a, h
    or      l
    jr      nz, 119$
    ld      hl, #PlayerDead
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
119$:

    ; 点滅の更新
    ld      a, CHARACTER_BLINK(ix)
    or      a
    jr      z, 120$
    dec     CHARACTER_BLINK(ix)
120$:

    ; 状態別の処理
    ld      l, CHARACTER_PROC_L(ix)
    ld      h, CHARACTER_PROC_H(ix)
    ld      a, h
    or      l
    jr      z, 20$
    ld      de, #20$
    push    de
    jp      (hl)
;   pop     hl
20$:
    
    ; 矩形の取得
    call    _CharacterCalcRect

    ; 爆発の更新
    ld      hl, #playerBomb
    ld      de, #PLAYER_BOMB_LENGTH
    ld      b, #PLAYER_BOMB_ENTRY
40$:
    ld      a, (hl)
    or      a
    jr      z, 49$
    dec     (hl)
49$:
    add     hl, de
    djnz    40$

    ; レジスタの復帰
    
    ; 終了
    ret

; プレイヤを描画する
;
_PlayerRender::

    ; レジスタの保存

    ; プレイヤの取得
    ld      ix, #_player

    ; スプライトの描画
    ld      a, CHARACTER_PROC_H(ix)
    or      CHARACTER_PROC_L(ix)
    jr      z, 19$
    ld      a, CHARACTER_BLINK(ix)
    and     #CHARACTER_BLINK_INTERVAL
    jr      nz, 19$
    ld      de, #(_sprite + GAME_SPRITE_PLAYER + 0x000c)
    call    _CharacterPrintSprite1x1
19$:

    ; 爆発の描画
    ld      ix, #playerBomb
    ld      hl, #(_sprite + GAME_SPRITE_PLAYER + 0x0000)
    ld      de, #PLAYER_BOMB_LENGTH
    ld      b, #PLAYER_BOMB_ENTRY
20$:
    ld      a, PLAYER_BOMB_FRAME(ix)
    or      a
    jr      z, 29$
    ld      a, PLAYER_BOMB_POSITION_Y(ix)
    add     a, #(APP_VIEW_Y * APP_VIEW_PIXEL - 0x08 - 0x01)
    ld      (hl), a
    inc     hl
    ld      c, #0x00
    ld      a, PLAYER_BOMB_POSITION_X(ix)
    cp      #0x80
    jr      nc, 21$
    add     a, #0x20
    ld      c, #0x80
21$:
    add     a, #(APP_VIEW_X * APP_VIEW_PIXEL - 0x08)
    ld      (hl), a
    inc     hl
    ld      a, PLAYER_BOMB_FRAME(ix)
    add     a, #0x18
    ld      (hl), a
    inc     hl
    ld      a, #VDP_COLOR_MEDIUM_RED
    add     a, c
    ld      (hl), a
    inc     hl
29$:
    add     ix, de
    djnz    20$

    ; レジスタの復帰

    ; 終了
    ret

; 何もしない
;
PlayerNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが待機する
;
PlayerIdle:

    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; フラグの設定
    set     #PLAYER_FLAG_LAND_BIT, CHARACTER_FLAG(ix)

    ; アニメーションの開始
    ld      hl, #playerAnimationIdleLeft
    ld      de, #playerAnimationIdleRight
    call    _CharacterStartDirectionAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ;  アニメーションの更新
    call    _CharacterUpdateAnimation
    
    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが行動する
;
PlayerPlay:

    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; フラグの設定
    set     #PLAYER_FLAG_LAND_BIT, CHARACTER_FLAG(ix)

    ; アニメーションの開始
    ld      hl, #playerAnimationIdleLeft
    ld      de, #playerAnimationIdleRight
    call    _CharacterStartDirectionAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; アニメーションの監視
    call    _CharacterIsDoneAnimation
    jr      nc, 190$

    ; 攻撃
100$:
    ld      a, (_game + GAME_INPUT_FIRE)
    or      a
    jr      z, 110$

    ; 処理の更新
    ld      hl, #PlayerFire
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
    jr      190$

    ; ジャンプ
110$:
    ld      a, (_game + GAME_INPUT_JUMP)
    or      a
    jr      z, 120$

    ; 処理の更新
    ld      hl, #PlayerJump
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
    jr      190$

    ; 防御
120$:
    ld      a, (_game + GAME_INPUT_DOWN)
    or      a
    jr      z, 130$

    ; 処理の更新
    ld      hl, #PlayerGuard
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
    jr      190$

    ; ←
130$:
    ld      a, (_game + GAME_INPUT_LEFT)
    or      a
    jr      z, 140$
    bit     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    jr      z, 131$
    res     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    ld      hl, #playerAnimationTurnLeft
    call    _CharacterStartAnimation
    jr      190$
131$:
    ld      hl, #playerAnimationWalkLeft
    call    _CharacterStartAnimation
    jr      190$

    ; →
140$:
    ld      a, (_game + GAME_INPUT_RIGHT)
    or      a
    jr      z, 190$
    bit     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    jr      nz, 141$
    set     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    ld      hl, #playerAnimationTurnRight
    call    _CharacterStartAnimation
    jr      190$
141$:
    ld      hl, #playerAnimationWalkRight
    call    _CharacterStartAnimation
;   jr      190$

    ; 行動の完了
190$:

    ; X の移動
    ld      de, #PLAYER_BRAKE_X
    call    _CharacterBrakeX
    call    _CharacterMoveX

    ; 落下の判定
    call    PlayerIsFallThen

    ;  アニメーションの更新
    call    _CharacterUpdateAnimation
    
    ; レジスタの復帰

    ; 終了
    ret

; プレイヤがジャンプする
;
PlayerJump:

    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; フラグの設定
    set     #CHARACTER_FLAG_THROUGH_BIT, CHARACTER_FLAG(ix)
    res     #PLAYER_FLAG_LAND_BIT, CHARACTER_FLAG(ix)

    ; Y の速度の設定
    ld      hl, #PLAYER_SPEED_Y_JUMP
    ld      CHARACTER_SPEED_Y_L(ix), l
    ld      CHARACTER_SPEED_Y_H(ix), h

    ; Y の加速度の設定
    ld      hl, #PLAYER_ACCEL_JUMP
    ld      PLAYER_ACCEL_L(ix), l
    ld      PLAYER_ACCEL_H(ix), h

    ; アニメーションの開始
    ld      hl, #playerAnimationJumpLeft
    ld      de, #playerAnimationJumpRight
    call    _CharacterStartDirectionAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; X の加速
    call    PlayerAccelX

    ; アニメーションの監視
    call    _CharacterIsDoneAnimation
    jr      nc, 110$

    ; Y の加速
    ld      a, (_game + GAME_INPUT_JUMP)
    or      a
    jr      nz, 100$
    ld      hl, #PLAYER_ACCEL_GRAVITY
    ld      PLAYER_ACCEL_L(ix), l
    ld      PLAYER_ACCEL_H(ix), h
100$:
    ld      e, PLAYER_ACCEL_L(ix)
    ld      d, PLAYER_ACCEL_H(ix)
    ld      bc, #PLAYER_SPEED_Y_MAXIMUM
    call    _CharacterAccelY

    ; 移動
    call    _CharacterMoveY
    call    _CharacterMoveX

    ; 落下の開始
    bit     #0x07, CHARACTER_SPEED_Y_H(ix)
    jr      nz, 190$

    ; フラグの設定
    res     #CHARACTER_FLAG_THROUGH_BIT, CHARACTER_FLAG(ix)

    ; ブロックの確認
    ld      hl, #PlayerFall
    ld      e, CHARACTER_POSITION_X_H(ix)
    ld      d, CHARACTER_POSITION_Y_H(ix)
    call    _StageIsBlock
    jr      nc, 180$
    ld      hl, #PlayerDown
    jr      180$

    ; ↓
110$:
    ld      a, (_game + GAME_INPUT_DOWN)
    or      a
    jr      z, 190$
    ld      e, CHARACTER_POSITION_X_H(ix)
    ld      d, CHARACTER_POSITION_Y_H(ix)
    inc     d
    call    _StageIsBlockDownable
    jr      nc, 190$
    inc     CHARACTER_POSITION_Y_H(ix)
    xor     a
    ld      CHARACTER_SPEED_Y_L(ix), a
    ld      CHARACTER_SPEED_Y_H(ix), a
    ld      PLAYER_ACCEL_L(ix), a
    ld      PLAYER_ACCEL_H(ix), a
    ld      hl, #PlayerDown
;   jr      180$

    ; 処理の更新
180$:
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

; プレイヤが降下する
;
PlayerDown:

    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; フラグの設定
    set     #CHARACTER_FLAG_THROUGH_BIT, CHARACTER_FLAG(ix)
    res     #PLAYER_FLAG_LAND_BIT, CHARACTER_FLAG(ix)

    ; アニメーションの開始
    ld      hl, #playerAnimationFallLeft
    ld      de, #playerAnimationFallRight
    call    _CharacterStartDirectionAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; Y の移動
    ld      de, #PLAYER_ACCEL_GRAVITY
    ld      bc, #PLAYER_SPEED_Y_MAXIMUM
    call    _CharacterAccelY
    call    _CharacterMoveY

    ; X の移動
    call    PlayerAccelX
    call    _CharacterMoveX

    ; ブロックの通過
    ld      e, CHARACTER_POSITION_X_H(ix)
    ld      d, CHARACTER_POSITION_Y_H(ix)
    call    _StageIsBlock
    jr      c, 190$

    ; フラグの設定
    res     #CHARACTER_FLAG_THROUGH_BIT, CHARACTER_FLAG(ix)

    ; 処理の更新
    ld      hl, #PlayerFall
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
;   jr      190$

    ; 降下の完了
190$:

    ;  アニメーションの更新
    call    _CharacterUpdateAnimation

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが落下する
;
PlayerFall:

    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; フラグの設定
    res     #PLAYER_FLAG_LAND_BIT, CHARACTER_FLAG(ix)

    ; アニメーションの開始
    ld      hl, #playerAnimationFallLeft
    ld      de, #playerAnimationFallRight
    call    _CharacterStartDirectionAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; Y の移動
    ld      de, #PLAYER_ACCEL_GRAVITY
    ld      bc, #PLAYER_SPEED_Y_MAXIMUM
    call    _CharacterAccelY
    call    _CharacterMoveY

    ; X の移動
    call    PlayerAccelX
    call    _CharacterMoveX

    ; 着地
    call    _CharacterIsLand
    jr      nc, 190$

    ; 処理の更新
    ld      hl, #PlayerLand
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

; プレイヤが着地する
;
PlayerLand:

    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; フラグの設定
    set     #PLAYER_FLAG_LAND_BIT, CHARACTER_FLAG(ix)

    ; アニメーションの開始
    ld      hl, #playerAnimationLandLeft
    ld      de, #playerAnimationLandRight
    call    _CharacterStartDirectionAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; X の移動
    ld      de, #PLAYER_BRAKE_X
    call    _CharacterBrakeX
    call    _CharacterMoveX

    ; アニメーションの監視
    call    _CharacterIsDoneAnimation
    jr      nc, 190$

    ; 処理の更新
    ld      hl, #PlayerPlay
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
;   jr      190$

    ; 着地の完了
190$:

    ; 落下の判定
    call    PlayerIsFallThen

    ;  アニメーションの更新
    call    _CharacterUpdateAnimation

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが発射する
;
PlayerFire:

    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; 照準の取得
    call    PlayerAim

    ; アニメーションの開始
    ld      hl, #playerAnimationAim
    ld      a, PLAYER_AIM(ix)
    call    _CharacterStartIndexAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; X の移動
    ld      de, #PLAYER_BRAKE_X
    call    _CharacterBrakeX
    call    _CharacterMoveX

    ; アニメーションの監視
    call    _CharacterIsDoneAnimation
    jr      nc, 190$

    ; SPACE キーの入力
    ld      a, (_game + GAME_INPUT_FIRE)
    or      a
    jr      z, 180$

    ; 照準の取得
    call    PlayerAim

    ; レイを飛ばす
    call    PlayerRay

    ; アニメーションの開始
    ld      hl, #playerAnimationFire
    ld      a, PLAYER_AIM(ix)
    call    _CharacterStartIndexAnimation
    jr      190$

    ; 処理の更新
180$:
    ld      hl, #PlayerLand
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
;   jr      190$

    ; 発射の完了
190$:

    ; 落下の判定
    call    PlayerIsFallThen

    ;  アニメーションの更新
    call    _CharacterUpdateAnimation

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが防御する
;
PlayerGuard:

    ; レジスタの保存

    ; 初期化
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 09$

    ; フラグの更新
    set     #PLAYER_FLAG_GUARD_BIT, CHARACTER_FLAG(ix)

    ; アニメーションの開始
    ld      hl, #playerAnimationGuardLeft
    ld      de, #playerAnimationGuardRight
    call    _CharacterStartDirectionAnimation

    ; 初期化の完了
    inc     CHARACTER_STATE(ix)
09$:

    ; X の移動
    ld      de, #PLAYER_BRAKE_X
    call    _CharacterBrakeX
    call    _CharacterMoveX

    ; ↓
100$:
    ld      a, (_game + GAME_INPUT_DOWN)
    or      a
    jr      nz, 110$

    ; 処理の更新
    ld      hl, #PlayerLand
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
    jr      190$

    ; SHIFT キーの入力
110$:
    ld      a, (_game + GAME_INPUT_JUMP)
    or      a
    jr      z, 190$
    ld      e, CHARACTER_POSITION_X_H(ix)
    ld      d, CHARACTER_POSITION_Y_H(ix)
    inc     d
    call    _StageIsBlockDownable
    jr      nc, 190$
    inc     CHARACTER_POSITION_Y_H(ix)
    xor     a
    ld      CHARACTER_SPEED_Y_L(ix), a
    ld      CHARACTER_SPEED_Y_H(ix), a

    ; 処理の更新
    ld      hl, #PlayerDown
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
;   jr      190$

    ; 防御の完了
190$:

    ; 落下の判定
    call    PlayerIsFallThen

    ;  アニメーションの更新
    call    _CharacterUpdateAnimation

    ; 防御の監視
;   ld      l, CHARACTER_PROC_L(ix)
;   ld      h, CHARACTER_PROC_H(ix)
;   ld      de, #PlayerGuard
;   or      a
;   sbc     hl, de
;   jr      z, 90$
    ld      a, CHARACTER_STATE(ix)
    or      a
    jr      nz, 90$
    res     #PLAYER_FLAG_GUARD_BIT, CHARACTER_FLAG(ix)
90$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが死亡する
;
PlayerDead:

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
    or      a
    jr      nz, 19$

    ; 爆発
    ld      e, CHARACTER_RECT_O_X(ix)
    ld      d, CHARACTER_RECT_O_Y(ix)
    call    _BombEntry

    ; 処理の更新
    xor     a
    ld      CHARACTER_PROC_L(ix), a
    ld      CHARACTER_PROC_H(ix), a
    ld      CHARACTER_STATE(ix), a
    jr      90$

    ; 死亡の完了
19$:

    ; 爆発
    ld      a, CHARACTER_BLINK(ix)
    and     #0x03
    jr      nz, 29$
    ld      hl, (playerBombEntry)
    inc     hl
    call    _SystemGetRandom
    and     #0x0f
    sub     #0x08
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
    ld      (hl), a
    dec     hl
    ld      (hl), #(0x03 + 0x01)
    inc     hl
    inc     hl
    call    _SystemGetRandom
    and     #0x0f
    sub     CHARACTER_POSITION_Y_H(ix)
    neg
    ld      (hl), a
    inc     hl
    ld      de, #(playerBomb + PLAYER_BOMB_LENGTH * PLAYER_BOMB_ENTRY)
    or      a
    sbc     hl, de
    jr      nc, 22$
    add     hl, de
    jr      23$
22$:
    ld      hl, #playerBomb
23$:
    ld      (playerBombEntry), hl
    ld      a, #SOUND_SE_BOMB
    call    _SoundPlaySeB
29$:

    ; 死亡の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを登場させる
;
_PlayerSpawn::

    ; レジスタの保存

    ; de < Y/X 位置
    ; c  < 向き

    ; プレイヤのクリア
    push    bc
    push    de
    ld      hl, #playerDefault
    ld      de, #_player
    ld      bc, #PLAYER_LENGTH
    ldir
    pop     de
    pop     bc

    ; プレイヤの取得
    ld      ix, #_player

    ; フラグの設定
    ld      a, c
    or      a
    jr      z, 10$
    ld      a, #CHARACTER_FLAG_RIGHT
10$:
    ld      CHARACTER_FLAG(ix), a

    ; 位置の設定
    ld      CHARACTER_POSITION_X_H(ix), e
    ld      CHARACTER_POSITION_Y_H(ix), d

    ; 処理の設定
    ld      hl, #PlayerPlay
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが X 方向に加速する
;
PlayerAccelX:

    ; レジスタの保存

    ; 加速
    ld      a, (_game + GAME_INPUT_LEFT)
    or      a
    jr      z, 10$
    ld      de, #-PLAYER_ACCEL_X
    jr      11$
10$:
    ld      a, (_game + GAME_INPUT_RIGHT)
    or      a
    jr      z, 12$
    ld      de, #PLAYER_ACCEL_X
;   jr      11$
11$:
    ld      bc, #PLAYER_SPEED_X_MAXIMUM
    call    _CharacterAccelX
    jr      19$
12$:
    ld      de, #PLAYER_BRAKE_X
    call    _CharacterBrakeX
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤの落下を判定する
;
PlayerIsFallThen:

    ; レジスタの保存

    ; 落下の判定
    call    _CharacterIsLand
    jr      c, 19$

    ; フラグの設定
    res     #PLAYER_FLAG_LAND_BIT, CHARACTER_FLAG(ix)

    ; 速度の設定
    xor     a
    ld      CHARACTER_SPEED_Y_L(ix), a
    ld      CHARACTER_SPEED_Y_H(ix), a

    ; 処理の更新
    ld      hl, #PlayerFall
    ld      CHARACTER_PROC_L(ix), l
    ld      CHARACTER_PROC_H(ix), h
    ld      CHARACTER_STATE(ix), #0x00
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 照準を取得する
;
PlayerAim:

    ; レジスタの保存

    ; 照準の取得
    bit     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    jr      nz, 12$
    ld      a, (_game + GAME_INPUT_UP)
    or      a
    jr      nz, 10$
    ld      a, #PLAYER_AIM_0900
    jr      19$
10$:
    ld      a, (_game + GAME_INPUT_LEFT)
    or      a
    jr      nz, 11$
    ld      a, #PLAYER_AIM_1200
    jr      19$
11$:
    ld      a, #PLAYER_AIM_1030
    jr      19$
12$:
    ld      a, (_game + GAME_INPUT_UP)
    or      a
    jr      nz, 13$
    ld      a, #PLAYER_AIM_0300
    jr      19$
13$:
    ld      a, (_game + GAME_INPUT_RIGHT)
    or      a
    jr      nz, 14$
    ld      a, #PLAYER_AIM_0000
    jr      19$
14$:
    ld      a, #PLAYER_AIM_0130
;   jr      19$
19$:
    ld      PLAYER_AIM(ix), a

    ; レジスタの復帰

    ; 終了
    ret

; レイを飛ばす
;
PlayerRay:

    ; レジスタの保存

    ; 開始位置の取得
    ld      a, PLAYER_AIM(ix)
    ld      c, a
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #playerMuzzle
    add     hl, de
    ld      a, (hl)
    bit     #0x07, a
    jr      z, 10$
    cpl
    ld      b, a
    ld      a, CHARACTER_POSITION_X_H(ix)
    sub     b
    jr      c, 80$
    jr      11$
10$:
    add     a, CHARACTER_POSITION_X_H(ix)
    jr      c, 80$
11$:
    ld      PLAYER_RAY_X_0(ix), a
    ld      PLAYER_RAY_X_1(ix), a
    ld      e, a
    inc     hl
    ld      a, (hl)
    cpl
    ld      b, a
    ld      a, CHARACTER_POSITION_Y_H(ix)
    sub     b
    jr      c, 80$
    ld      PLAYER_RAY_Y_0(ix), a
    ld      PLAYER_RAY_Y_1(ix), a
    ld      d, a
;   inc     hl

    ; レイを飛ばす
    ld      a, c
    or      a
    jr      z, 20$
    dec     a
    jr      z, 21$
    dec     a
    jr      z, 22$
    dec     a
    jr      z, 22$
    dec     a
    jr      z, 23$
    jr      24$
20$:
    call    _StageRay_0900
    jr      29$
21$:
    call    _StageRay_1030
    jr      29$
22$:
    call    _StageRay_0000
    jr      29$
23$:
    call    _StageRay_0130
    jr      29$
24$:
    call    _StageRay_0300
;   jr      29$
29$:
    ld      PLAYER_RAY_X_1(ix), e
    ld      PLAYER_RAY_Y_1(ix), d
    jr      90$

    ; レイは飛ばせない
80$:
    xor     a
    ld      PLAYER_RAY_X_0(ix), a
    ld      PLAYER_RAY_Y_0(ix), a
    ld      PLAYER_RAY_X_1(ix), a
    ld      PLAYER_RAY_Y_1(ix), a
;   jr      90$

    ; レイの完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが生存しているかどうかを判定する
;
_PlayerIsLive::

    ; レジスタの保存
    push    hl

    ; cf > 1 = 生存している

    ; 生存の判定
    ld      hl, (_player + CHARACTER_LIFE_L)
    ld      a, h
    or      l
    jr      z, 19$
    scf
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

_PlayerIsOver::

    ; レジスタの保存
    push    hl

    ; cf > 1 = ゲームオーバー

    ; 生存の判定
    ld      hl, (_player + CHARACTER_PROC_L)
    ld      a, h
    or      l
    jr      nz, 19$
    scf
19$:

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; プレイヤの位置を取得する
;
_PlayerGetPosition::

    ; レジスタの保存

    ; de > Y/X 位置

    ; 位置の取得
    ld      a, (_player + CHARACTER_POSITION_X_H)
    ld      e, a
    ld      a, (_player + CHARACTER_POSITION_Y_H)
    ld      d, a

    ; レジスタの復帰

    ; 終了
    ret

_PlayerGetCenter::

    ; レジスタの保存

    ; de > Y/X 位置

    ; 位置の取得
    ld      de, (_player + CHARACTER_RECT_O_X)

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤが着地しているかどうかを判定する
;
_PlayerIsLand::

    ; レジスタの保存

    ; cf > 1 = 着地している

    ; 着地の判定
    ld      a, (_player + CHARACTER_FLAG)
    or      a
    bit     #PLAYER_FLAG_LAND_BIT, a
    jr      z, 10$
    scf
10$:

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤのダメージをクリアする
;
_PlayerClearDamage::

    ; レジスタの保存
    push    hl

    ; ダメージのクリア
    ld      hl, #0x0000
    ld      (_player + PLAYER_DAMAGE_L), hl

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; プレイヤにダメージを与える
;
_PlayerSetDamage::

    ; レジスタの保存

    ; hl < ダメージ

    ; ダメージのクリア
    ld      (_player + PLAYER_DAMAGE_L), hl

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤを反転させる
;
_PlayerSetTurnLeft::

    ; レジスタの保存
    push    ix

    ; ←
    ld      ix, #_player
    bit     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    jr      z, 19$
    res     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    ld      hl, #playerAnimationTurnLeft
    call    _CharacterStartAnimation
19$:

    ; レジスタの復帰
    pop     ix

    ; 終了
    ret
    
_PlayerSetTurnRight::

    ; レジスタの保存
    push    ix

    ; ←
    ld      ix, #_player
    bit     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    jr      nz, 19$
    set     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    ld      hl, #playerAnimationTurnRight
    call    _CharacterStartAnimation
19$:

    ; レジスタの復帰
    pop     ix

    ; 終了
    ret
    
; プレイヤを保存する
;
_PlayerStore::

    ; レジスタの保存

    ; プレイヤの保存
    ld      hl, #_player
    ld      de, #playerBackup
    ld      bc, #PLAYER_LENGTH
    ldir

    ; レジスタの復帰

    ; 終了
    ret

; 保存されたプレイヤを復帰する
;
_PlayerRestoreX::

    ; レジスタの保存

    ; プレイヤの復帰
    ld      ix, #_player

    ; 位置の復帰
    ld      a, (playerBackup + CHARACTER_POSITION_X_H)
    ld      CHARACTER_POSITION_X_H(ix), a

    ; 向きの復帰
    ld      a, (playerBackup + CHARACTER_FLAG)
    and     #CHARACTER_FLAG_RIGHT
    jr      nz, 20$
    res     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    jr      21$
20$:
    set     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
21$:

    ; ライフの復帰
    ld      hl, (playerBackup + CHARACTER_LIFE_L)
    ld      CHARACTER_LIFE_L(ix), l
    ld      CHARACTER_LIFE_H(ix), h

    ; レジスタの復帰

    ; 終了
    ret

_PlayerRestoreY::

    ; レジスタの保存

    ; プレイヤの復帰
    ld      ix, #_player

    ; 位置の復帰
    ld      a, (playerBackup + CHARACTER_POSITION_Y_H)
    ld      CHARACTER_POSITION_Y_H(ix), a

    ; 向きの復帰
    ld      a, (playerBackup + CHARACTER_FLAG)
    and     #CHARACTER_FLAG_RIGHT
    jr      nz, 20$
    res     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
    jr      21$
20$:
    set     #CHARACTER_FLAG_RIGHT_BIT, CHARACTER_FLAG(ix)
21$:

    ; ライフの復帰
    ld      hl, (playerBackup + CHARACTER_LIFE_L)
    ld      CHARACTER_LIFE_L(ix), l
    ld      CHARACTER_LIFE_H(ix), h

    ; レジスタの復帰

    ; 終了
    ret

; プレイヤのライフを表示する
;
_PlayerPrintLife::

    ; レジスタの保存

    ; 色の取得
    ld      hl, (_player + PLAYER_DAMAGE_L)
    ld      a, h
    or      l
    jr      z, 10$
    ld      a, #0x10
10$:
    add     a, #0x40
    ld      c, a

    ; ライフの描画
    ld      hl, (_player + CHARACTER_LIFE_L)
    add     hl, hl
    ld      de, #playerLife
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    ld      hl, #(_patternName + APP_VIEW_Y * APP_VIEW_SIZE_X)
    ld      a, #0x0a
    add     a, c
    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a
    inc     a
    inc     hl
    ld      (hl), a
    inc     a
    inc     hl
;   inc     hl
    ld      a, d
    add     a, c
    ld      (hl), a
    inc     hl
    ld      a, e
    srl     a
    srl     a
    srl     a
    srl     a
    add     a, c
    ld      (hl), a
    inc     hl
    ld      a, e
    and     #0x0f
    add     a, c
    ld      (hl), a
;   inc     hl

;   ; フレームの更新
;   ld      hl, #playerLifeFrame
;   inc     (hl)

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; プレイヤの初期値
;
playerDefault:

    .dw     CHARACTER_PROC_NULL
    .db     CHARACTER_STATE_NULL
    .db     CHARACTER_FLAG_NULL
    .dw     0x0800 ; CHARACTER_POSITION_NULL
    .dw     0x0000 ; CHARACTER_POSITION_NULL
    .dw     CHARACTER_SPEED_NULL
    .dw     CHARACTER_SPEED_NULL
    .db     0x08 ; CHARACTER_RECT_NULL
    .db     0x0e ; CHARACTER_RECT_NULL
    .db     CHARACTER_RECT_NULL
    .db     CHARACTER_RECT_NULL
    .db     CHARACTER_RECT_NULL
    .db     CHARACTER_RECT_NULL
    .db     CHARACTER_RECT_NULL
    .db     CHARACTER_RECT_NULL
    .dw     CHARACTER_ANIMATION_NULL
    .db     VDP_COLOR_BLACK ; CHARACTER_ANIMATION_NULL
    .db     CHARACTER_ANIMATION_NULL
    .db     CHARACTER_BLINK_NULL
    .db     CHARACTER_HIT_NULL
    .db     CHARACTER_HIT_NULL
    .db     CHARACTER_HIT_NULL
    .db     CHARACTER_HIT_NULL
    .dw     PLAYER_LIFE_MAXIMUM ; CHARACTER_LIFE_NULL
    .dw     PLAYER_DAMAGE_NULL
    .dw     PLAYER_ACCEL_NULL
    .db     PLAYER_AIM_NULL
    .db     PLAYER_RAY_NULL
    .db     PLAYER_RAY_NULL
    .db     PLAYER_RAY_NULL
    .db     PLAYER_RAY_NULL

; 銃口
;
playerMuzzle:

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
playerAnimationIdleLeft:

    .db     0xff,  0x00, -0x0f - 0x01, -0x08, 0x20, SOUND_SE_NULL

playerAnimationIdleRight:

    .db     0xff,  0x00, -0x0f - 0x01, -0x08, 0x30, SOUND_SE_NULL

playerAnimationTurnLeft:

    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x28, SOUND_SE_NULL
    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x20, SOUND_SE_NULL
    .db     0x00

playerAnimationTurnRight:

    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x38, SOUND_SE_NULL
    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x30, SOUND_SE_NULL
    .db     0x00

playerAnimationWalkLeft:

    .db     0x04, -0x02, -0x0f - 0x01, -0x08, 0x21, SOUND_SE_NULL
    .db     0x04,  0x00, -0x0f - 0x01, -0x08, 0x22, SOUND_SE_WALK
    .db     0x04, -0x02, -0x0f - 0x01, -0x08, 0x23, SOUND_SE_NULL
    .db     0x04,  0x00, -0x0f - 0x01, -0x08, 0x20, SOUND_SE_NULL
    .db     0x00

playerAnimationWalkRight:

    .db     0x04,  0x02, -0x0f - 0x01, -0x08, 0x31, SOUND_SE_NULL
    .db     0x04,  0x00, -0x0f - 0x01, -0x08, 0x32, SOUND_SE_WALK
    .db     0x04,  0x02, -0x0f - 0x01, -0x08, 0x33, SOUND_SE_NULL
    .db     0x04,  0x00, -0x0f - 0x01, -0x08, 0x30, SOUND_SE_NULL
    .db     0x00

playerAnimationJumpLeft:

    .db     0x0c,  0x00, -0x0f - 0x01, -0x08, 0x24, SOUND_SE_NULL
    .db     0xff,  0x00, -0x0f - 0x01, -0x08, 0x25, SOUND_SE_NULL

playerAnimationJumpRight:

    .db     0x0c,  0x00, -0x0f - 0x01, -0x08, 0x34, SOUND_SE_NULL
    .db     0xff,  0x00, -0x0f - 0x01, -0x08, 0x35, SOUND_SE_NULL

playerAnimationFallLeft:

    .db     0xff,  0x00, -0x0f - 0x01, -0x08, 0x26, SOUND_SE_NULL

playerAnimationFallRight:

    .db     0xff,  0x00, -0x0f - 0x01, -0x08, 0x36, SOUND_SE_NULL

playerAnimationLandLeft:

    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x24, SOUND_SE_LAND
    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x20, SOUND_SE_NULL
    .db     0x00

playerAnimationLandRight:

    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x34, SOUND_SE_LAND
    .db     0x08,  0x00, -0x0f - 0x01, -0x08, 0x30, SOUND_SE_NULL
    .db     0x00

playerAnimationAim:

    .dw     playerAnimationAim_0900
    .dw     playerAnimationAim_1030
    .dw     playerAnimationAim_1200
    .dw     playerAnimationAim_0000
    .dw     playerAnimationAim_0130
    .dw     playerAnimationAim_0300
    .dw     0x0000
    .dw     0x0000
    .dw     0x0000

playerAnimationAim_0900:

    .db     0x04,  0x00, -0x0f - 0x01, -0x04, 0x2a, SOUND_SE_NULL
    .db     0x00

playerAnimationAim_1030:

    .db     0x04,  0x00, -0x0f - 0x01, -0x04, 0x2c, SOUND_SE_NULL
    .db     0x00

playerAnimationAim_1200:

    .db     0x04,  0x00, -0x0f - 0x01, -0x04, 0x2e, SOUND_SE_NULL
    .db     0x00

playerAnimationAim_0000:

    .db     0x04,  0x00, -0x0f - 0x01, -0x0c, 0x3e, SOUND_SE_NULL
    .db     0x00

playerAnimationAim_0130:

    .db     0x04,  0x00, -0x0f - 0x01, -0x0c, 0x3c, SOUND_SE_NULL
    .db     0x00

playerAnimationAim_0300:

    .db     0x04,  0x00, -0x0f - 0x01, -0x0c, 0x3a, SOUND_SE_NULL
    .db     0x00

playerAnimationFire:

    .dw     playerAnimationFire_0900
    .dw     playerAnimationFire_1030
    .dw     playerAnimationFire_1200
    .dw     playerAnimationFire_0000
    .dw     playerAnimationFire_0130
    .dw     playerAnimationFire_0300
    .dw     0x0000
    .dw     0x0000
    .dw     0x0000

playerAnimationFire_0900:

    .db     0x01,  0x00, -0x0f - 0x01, -0x04, 0x2b, SOUND_SE_BULLET
    .db     0x01,  0x00, -0x0f - 0x01, -0x04, 0x2a, SOUND_SE_NULL
    .db     0x00

playerAnimationFire_1030:

    .db     0x01,  0x00, -0x0f - 0x01, -0x04, 0x2d, SOUND_SE_BULLET
    .db     0x01,  0x00, -0x0f - 0x01, -0x04, 0x2c, SOUND_SE_NULL
    .db     0x00

playerAnimationFire_1200:

    .db     0x01,  0x00, -0x0f - 0x01, -0x04, 0x2f, SOUND_SE_BULLET
    .db     0x01,  0x00, -0x0f - 0x01, -0x04, 0x2e, SOUND_SE_NULL
    .db     0x00

playerAnimationFire_0000:

    .db     0x01,  0x00, -0x0f - 0x01, -0x0c, 0x3f, SOUND_SE_BULLET
    .db     0x01,  0x00, -0x0f - 0x01, -0x0c, 0x3e, SOUND_SE_NULL
    .db     0x00

playerAnimationFire_0130:

    .db     0x01,  0x00, -0x0f - 0x01, -0x0c, 0x3d, SOUND_SE_BULLET
    .db     0x01,  0x00, -0x0f - 0x01, -0x0c, 0x3c, SOUND_SE_NULL
    .db     0x00

playerAnimationFire_0300:

    .db     0x01,  0x00, -0x0f - 0x01, -0x0c, 0x3b, SOUND_SE_BULLET
    .db     0x01,  0x00, -0x0f - 0x01, -0x0c, 0x3a, SOUND_SE_NULL
    .db     0x00

playerAnimationGuardLeft:

    .db     0xff,  0x00, -0x0f - 0x01, -0x06, 0x27, SOUND_SE_SIT

playerAnimationGuardRight:

    .db     0xff,  0x00, -0x0f - 0x01, -0x0a, 0x37, SOUND_SE_SIT


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; プレイヤ
;
_player::
    
    .ds     PLAYER_LENGTH

playerBackup:

    .ds     PLAYER_LENGTH

; 爆発
;
playerBomb:

    .ds     PLAYER_BOMB_LENGTH * PLAYER_BOMB_ENTRY

playerBombEntry:

    .ds     0x02

; ライフ
;
playerLife:

    .ds     (PLAYER_LIFE_MAXIMUM + 1) * 0x02

playerLifeFrame:

    .ds     0x01

