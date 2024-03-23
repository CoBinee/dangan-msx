; Game.s : ゲーム
;


; モジュール宣言
;
    .module Game

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include	"Game.inc"
    .include    "Fade.inc"
    .include    "Message.inc"
    .include    "Level.inc"
    .include    "Stage.inc"
    .include    "Character.inc"
    .include    "Player.inc"
    .include    "Enemy.inc"
    .include    "Bullet.inc"
    .include    "Missile.inc"
    .include    "Bomb.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; ゲームを初期化する
;
_GameInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite
    
    ; パターンネームのクリア
    ld      a, #APP_PATTERN_NAME_BLANK
    call    _SystemClearPatternName
    
    ; ゲームの初期化
    ld      hl, #gameDefault
    ld      de, #_game
    ld      bc, #GAME_LENGTH
    ldir

    ; フェードの初期化
    call    _FadeInitialize

    ; メッセージの初期化
    call    _MessageInitialize

    ; レベルの初期化
    call    _LevelInitialize

    ; ステージの初期化
    call    _StageInitialize

    ; プレイヤの初期化
    call    _PlayerInitialize

    ; エネミーの初期化
    call    _EnemyInitialize

    ; 銃弾の初期化
    call    _BulletInitialize

    ; ミサイルの初期化
    call    _MissileInitialize

    ; 爆発の初期化
    call    _BombInitialize

    ; 転送の設定
;   ld      hl, #_SystemUpdatePatternName
    ld      hl, #_AppTransfer
    ld      (_transfer), hl

    ; カラーテーブルの切替
    ld      a, #(APP_COLOR_TABLE_NORMAL >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; 描画の開始
    ld      hl, #(_videoRegister + VDP_R1)
    set     #VDP_R1_BL, (hl)
    
    ; 処理の設定
    ld      hl, #GameIdle
    ld      (_game + GAME_PROC_L), hl
    xor     a
    ld      (_game + GAME_STATE), a

    ; アプリケーションの更新
    ld      a, #APP_STATE_GAME_UPDATE
    ld      (_app + APP_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; ゲームを更新する
;
_GameUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      hl, (_game + GAME_PROC_L)
    jp      (hl)
;   pop     hl
10$:

    ; スプライトの更新
    ld      hl, (_game + GAME_SPRITE_MISSILE_L)
    ld      de, (_game + GAME_SPRITE_ENEMY_L)
    ld      (_game + GAME_SPRITE_MISSILE_L), de
    ld      (_game + GAME_SPRITE_ENEMY_L), hl

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
GameNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを待機する
;
GameIdle:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    or      a
    jr      nz, 09$

    ; メッセージの開始
    ld      hl, #gameStringStart
    ld      d, #0x03
    call    _MessageStartCentering

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; メッセージの表示
    call    _MessagePrint

    ; メッセージの監視
90$:
    ld      c, #0x30
    call    _MessageIsDone
    jr      nc, 99$

    ; 処理の更新
    ld      hl, #GameBuild
    ld      (_game + GAME_PROC_L), hl
    xor     a
    ld      (_game + GAME_STATE), a
99$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを作成する
;
GameBuild:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    or      a
    jr      nz, 09$

    ; フラグの設定
    ld      hl, #(_game + GAME_FLAG)
    res     #GAME_FLAG_PLAY_BIT, (hl)

    ; レベルの更新
    ld      hl, #(_game + GAME_LEVEL)
    inc     (hl)

    ; レベルの作成
    call    _LevelBuild

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; 処理の更新
    ld      hl, #GameStart
    ld      (_game + GAME_PROC_L), hl
    xor     a
    ld      (_game + GAME_STATE), a

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを開始する
;
GameStart:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    or      a
    jr      nz, 09$

    ; フラグの設定
    ld      hl, #(_game + GAME_FLAG)
    res     #GAME_FLAG_PLAY_BIT, (hl)

    ; フェードの開始
    call    _FadeInStart

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; ゲームの更新
    call    GameCallUpdate

    ; フェードの更新
    call    _FadeInUpdate

    ; ゲームの描画
    call    GameCallRender

    ; フェードの描画
    call    _FadeRender

    ; フェードの監視
90$:
    call    _FadeInIsDone
    jr      nc, 99$

    ; 着地の監視
    call    _PlayerIsLand
    jr      nc, 99$

    ; 処理の更新
    ld      hl, #GamePlay
    ld      (_game + GAME_PROC_L), hl
    xor     a
    ld      (_game + GAME_STATE), a
99$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをプレイする
;
GamePlay:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    or      a
    jr      nz, 09$

    ; フラグの設定
    ld      hl, #(_game + GAME_FLAG)
    set     #GAME_FLAG_PLAY_BIT, (hl)

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; ヒット判定
    call    GameHit

    ; ゲームの更新
    call    GameCallUpdate

    ;  レベルの更新
    call    _LevelUpdate

    ; ゲームの描画
    call    GameCallRender

    ;  レベルの描画
    call    _LevelRender

    ; ゲームの判定
90$:
    call    _PlayerIsOver
    jr      nc, 91$
    ld      hl, #GameOver
    jr      98$
91$:
    call    _LevelIsClear
    jr      nc, 99$
    call    _LevelIsExist
    jr      nc, 92$
    ld      hl, #GameNext
    jr      98$
92$:
    ld      hl, #GameClear
;   jr      98$

    ; 処理の更新
98$:
    ld      (_game + GAME_PROC_L), hl
    xor     a
    ld      (_game + GAME_STATE), a
99$:

    ; レジスタの復帰

    ; 終了
    ret

; レベルをクリアする
;
GameNext:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    or      a
    jr      nz, 09$

    ; フラグの設定
    ld      hl, #(_game + GAME_FLAG)
    res     #GAME_FLAG_PLAY_BIT, (hl)

    ; ダメージのクリア
    call    _PlayerClearDamage

    ; プレイヤの保存
    call    _PlayerStore

    ; フェードの開始
    call    _FadeOutStart

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; ゲームの更新
    call    GameCallUpdate

    ; フェードの更新
    call    _FadeOutUpdate

    ; ゲームの描画
    call    GameCallRender

    ; フェードの描画
    call    _FadeRender

    ; フェードの監視
90$:
    call    _FadeOutIsDone
    jr      nc, 99$

    ; 処理の更新
    ld      hl, #GameBuild
    ld      (_game + GAME_PROC_L), hl
    xor     a
    ld      (_game + GAME_STATE), a
99$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームをクリアする
;
GameClear:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    or      a
    jr      nz, 09$

    ; フラグの設定
    ld      hl, #(_game + GAME_FLAG)
    res     #GAME_FLAG_PLAY_BIT, (hl)

    ; ダメージのクリア
    call    _PlayerClearDamage

    ; メッセージの開始
    ld      hl, #gameStringComplete
    ld      d, #0x05
    call    _MessageStartCentering

    ; カラーテーブルの切替
    ld      a, #(APP_COLOR_TABLE_REVERSE >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; フレームの設定
    ld      a, #0x18
    ld      (_game + GAME_FRAME), a

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; 0x01 : メッセージ１
10$:
    ld      a, (_game + GAME_STATE)
    dec     a
    jr      nz, 20$

    ; ゲームの更新
    call    GameCallUpdate

    ; ゲームの描画
    call    GameCallRender

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    ld      a, (hl)
    or      a
    jr      z, 11$
    dec     (hl)
    jp      nz, 90$
11$:

    ; メッセージの表示
    call    _MessagePrint

    ; メッセージの監視
    ld      c, #0x7f
    call    _MessageIsDone
    jp      nc, 90$

    ; エネミーの作成
    ld      ix, #(_enemy + 0 * ENEMY_LENGTH)
    call    _EnemyBeamerSpawn

    ; フレームの設定
    ld      a, #0x30
    ld      (_game + GAME_FRAME), a
    jp      80$

    ; 0x02 : ビーマー
20$:
    dec     a
    jr      nz, 30$

    ; ゲームの更新
    call    GameCallUpdate

    ; ゲームの描画
    call    GameCallRender

    ; プレイヤの死亡
    call    _PlayerIsOver
    jp      nc, 90$

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    dec     (hl)
    jp      nz, 90$

    ; カラーテーブルの切替
    ld      a, #(APP_COLOR_TABLE_NORMAL >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; フェードの開始
    call    _FadeOutStart
    jr      80$

    ; 0x03 : フェードアウト１
30$:
    dec     a
    jr      nz, 40$

    ; ゲームの更新
    call    GameCallUpdate

    ; フェードの更新
    call    _FadeOutUpdate

    ; ゲームの描画
    call    GameCallRender

    ; フェードの描画
    call    _FadeRender

    ; フェードの監視
    call    _FadeOutIsDone
    jr      nc, 90$

    ; フェードの開始
    call    _FadeOutStart

    ; メッセージの開始
    ld      hl, #gameStringBeamAttack
    ld      d, #0x05
    call    _MessageStartCentering
    jr      80$

    ; 0x04 : メッセージ２
40$:
    dec     a
    jr      nz, 50$

    ; メッセージの表示
    call    _MessagePrint

    ; メッセージの監視
    ld      c, #0x7f
    call    _MessageIsDone
    jr      nc, 90$

    ; フェードの更新
    call    _FadeOutUpdate

    ; フェードの描画
    call    _FadeRender

    ; フェードの監視
    call    _FadeOutIsDone
    jr      nc, 90$

    ; メッセージの開始
    ld      hl, #gameStringNewPhase
    ld      d, #0x05
    call    _MessageStartCentering
    jr      80$

    ; 0x05 : メッセージ３
50$:
    dec     a
    jr      nz, 60$

    ; メッセージの表示
    call    _MessagePrint

    ; メッセージの監視
    ld      c, #0x10
    call    _MessageIsDone
    jr      nc, 90$
    jr      80$

    ; 0x06 : キー入力待ち
60$:
    dec     a
    jr      nz, 70$

    ; メッセージの表示
    call    _MessagePrint

    ; SPACE キー
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 90$

    ; SE の再生
    ld      a, #SOUND_SE_CLICK
    call    _SoundPlaySeC
    
    ; フェードの開始
    call    _FadeOutStart
    jr      80$

    ; 0x07 : フェードアウト
70$:
;   dec     a
;   jr      nz, 80$

    ; フェードの更新
    call    _FadeOutUpdate

    ; フェードの描画
    call    _FadeRender

    ; フェードの監視
    call    _FadeOutIsDone
    jr      nc, 90$

    ; アプリケーションの更新
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_app + APP_STATE), a
    jr      90$

    ; 状態の更新
80$:
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
;   jr      90$

    ; クリアの完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームオーバーになる
;
GameOver:

    ; レジスタの保存

    ; 初期化
    ld      a, (_game + GAME_STATE)
    or      a
    jr      nz, 09$

    ; フラグの設定
    ld      hl, #(_game + GAME_FLAG)
    res     #GAME_FLAG_PLAY_BIT, (hl)

    ; フレームの設定
    ld      a, #0x18
    ld      (_game + GAME_FRAME), a

    ; フェードの開始
    call    _FadeOutStart

    ; 初期化の完了
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
09$:

    ; 0x01 : 待機
10$:
    ld      a, (_game + GAME_STATE)
    dec     a
    jr      nz, 20$

    ; ゲームの更新
    call    GameCallUpdate

    ; ゲームの描画
    call    GameCallRender

    ; フレームの更新
    ld      hl, #(_game + GAME_FRAME)
    dec     (hl)
    jr      nz, 90$
    jr      80$

    ; 0x02 : フェードアウト
20$:
    dec     a
    jr      nz, 30$

    ; ゲームの更新
    call    GameCallUpdate

    ; フェードの更新
    call    _FadeOutUpdate

    ; ゲームの描画
    call    GameCallRender

    ; フェードの描画
    call    _FadeRender

    ; フェードの監視
    call    _FadeOutIsDone
    jr      nc, 90$

    ; メッセージの開始
    ld      hl, #gameStringIncomplete
    ld      d, #0x05
    call    _MessageStartCentering

    ; フェードの開始
    call    _FadeOutStart
    jr      80$

    ; 0x03 : メッセージ
30$:
    dec     a
    jr      nz, 40$

    ; メッセージの表示
    call    _MessagePrint

    ; メッセージの監視
    ld      c, #0x10
    call    _MessageIsDone
    jr      nc, 90$
    jr      80$

    ; 0x04 : キー入力待ち
40$:
    dec     a
    jr      nz, 50$

    ; メッセージの表示
    call    _MessagePrint

    ; SPACE キー
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 90$

    ; SE の再生
    ld      a, #SOUND_SE_CLICK
    call    _SoundPlaySeC

    ; フェードの開始
    call    _FadeOutStart
    jr      80$

    ; 0x05 : フェードアウト
50$:
;   dec     a
;   jr      nz, 60$

    ; フェードの更新
    call    _FadeOutUpdate

    ; フェードの描画
    call    _FadeRender

    ; フェードの監視
    call    _FadeOutIsDone
    jr      nc, 90$

    ; アプリケーションの更新
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_app + APP_STATE), a
    jr      90$

    ; 状態の更新
80$:
    ld      hl, #(_game + GAME_STATE)
    inc     (hl)
;   jr      90$

    ; ゲームオーバーの完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームを更新処理を呼び出す
;
GameCallUpdate:

    ; レジスタの保存

    ; 入力の更新
    call    GameInput

    ; ステージの更新
    call    _StageUpdate

    ; プレイヤの更新
    call    _PlayerUpdate

    ; エネミーの更新
    call    _EnemyUpdate

    ; 銃弾の更新
    call    _BulletUpdate

    ; ミサイルの更新
    call    _MissileUpdate

    ; 爆発の更新
    call    _BombUpdate

    ; レジスタの復帰

    ; 終了
    ret

; ゲームの描画処理を呼び出す
;
GameCallRender:

    ; レジスタの保存

    ; プレイヤの描画
    call    _PlayerRender

    ; エネミーの描画 
    call    _EnemyRender

    ; ステージの描画
    call    _StageRender

    ; 銃弾の描画
    call    _BulletRender

    ; ミサイルの描画
    call    _MissileRender

    ; 爆発の描画
    call    _BombRender

    ; ライフの描画
    call    _PlayerPrintLife

    ; レジスタの復帰

    ; 終了
    ret

; 入力を更新する
;
GameInput:

    ; レジスタの保存

    ; 入力の更新
    ld      hl, #(_input + INPUT_KEY_UP)
    ld      de, #(_game + GAME_INPUT_UP)
    ld      a, (_game + GAME_FLAG)
    and     #GAME_FLAG_PLAY
    jr      z, 10$
    ld      a, #0xff
10$:
    ld      c, a
    ld      b, #(INPUT_BUTTON_SHIFT + 0x01)
11$:
    ld      a, (hl)
    and     c
    ld      (de), a
    inc     hl
    inc     de
    djnz    11$

    ; レジスタの復帰

    ; 終了
    ret

; ヒット判定を行う
;
GameHit:

    ; レジスタの保存

    ; 銃弾とエネミーのヒット判定
    ld      hl, #0x0000
    ld      (gameHitCharacter), hl
    ld      a, #0xff
    ld      (gameHitDistance), a
    ld      hl, (_player + PLAYER_RAY_X_0)
    ld      de, (_player + PLAYER_RAY_X_1)
    or      a
    sbc     hl, de
    jp      z, 199$
    add     hl, de
100$:
    ld      a, (_player + PLAYER_AIM)
    or      a
    jr      z, 110$
    dec     a
    jr      z, 120$
    dec     a
    jp      z, 130$
    dec     a
    jp      z, 130$
    dec     a
    jp      z, 140$
    jp      150$

    ; 0900
110$:
    ld      ix, #_enemy
    ld      bc, #((ENEMY_ENTRY << 8) | 0xff)
111$:
    ld      a, CHARACTER_PROC_H(ix)
    or      CHARACTER_PROC_L(ix)
    jr      z, 119$
    ld      a, h
    cp      CHARACTER_RECT_TOP(ix)
    jr      c, 119$
    ld      a, CHARACTER_RECT_BOTTOM(ix)
    cp      h
    jr      c, 119$
    ld      a, l
    cp      CHARACTER_RECT_LEFT(ix)
    jr      c, 119$
    ld      a, CHARACTER_RECT_RIGHT(ix)
    cp      e
    jr      c, 119$
    ld      a, l
    sub     CHARACTER_RECT_O_X(ix)
    jr      nc, 112$
    xor     a
112$:
    cp      c
    jr      nc, 119$
    ld      (gameHitCharacter), ix
    ld      c, a
;   jr      119$
119$:
    push    bc
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    111$
    jp      190$

    ; 1030
120$:
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
121$:
    push    bc
    ld      a, CHARACTER_PROC_H(ix)
    or      CHARACTER_PROC_L(ix)
    jr      z, 129$
    ld      a, l
    cp      CHARACTER_RECT_LEFT(ix)
    jr      c, 129$
    ld      a, CHARACTER_RECT_RIGHT(ix)
    cp      e
    jr      c, 129$
    ld      a, h
    cp      CHARACTER_RECT_TOP(ix)
    jr      c, 129$
    ld      a, CHARACTER_RECT_BOTTOM(ix)
    cp      d
    jr      c, 129$
    ld      a, l
    sub     CHARACTER_RECT_RIGHT(ix)
    ld      c, a
    ld      a, h
    sub     c
    jr      nc, 122$
    xor     a
122$:
    cp      CHARACTER_RECT_TOP(ix)
    jr      c, 129$
    ld      a, l
    sub     CHARACTER_RECT_LEFT(ix)
    ld      c, a
    ld      a, h
    sub     c
    jr      nc, 123$
    xor     a
123$:
    cp      CHARACTER_RECT_BOTTOM(ix)
    jr      nc, 129$
    ld      a, (gameHitDistance)
    ld      c, a
    ld      a, l
    sub     CHARACTER_RECT_RIGHT(ix)
    jr      nc, 124$
    xor     a
124$:
    cp      c
    jr      nc, 129$
    ld      (gameHitCharacter), ix
    ld      (gameHitDistance), a
;   jr      129$
129$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    121$
    jp      190$

    ; 0000
    ; 1200
130$:
    ld      ix, #_enemy
    ld      bc, #((ENEMY_ENTRY << 8) | 0xff)
131$:
    ld      a, CHARACTER_PROC_H(ix)
    or      CHARACTER_PROC_L(ix)
    jr      z, 139$
    ld      a, l
    cp      CHARACTER_RECT_LEFT(ix)
    jr      c, 139$
    ld      a, CHARACTER_RECT_RIGHT(ix)
    cp      l
    jr      c, 139$
    ld      a, h
    cp      CHARACTER_RECT_TOP(ix)
    jr      c, 139$
    ld      a, CHARACTER_RECT_BOTTOM(ix)
    cp      d
    jr      c, 139$
    ld      a, h
    sub     CHARACTER_RECT_O_Y(ix)
    jr      nc, 132$
    xor     a
132$:
    cp      c
    jr      nc, 139$
    ld      (gameHitCharacter), ix
    ld      c, a
;   jr      139$
139$:
    push    bc
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    131$
    jp      190$

    ; 0130
140$:
    ld      ix, #_enemy
    ld      b, #ENEMY_ENTRY
141$:
    push    bc
    ld      a, CHARACTER_PROC_H(ix)
    or      CHARACTER_PROC_L(ix)
    jr      z, 149$
    ld      a, e
    cp      CHARACTER_RECT_LEFT(ix)
    jr      c, 149$
    ld      a, CHARACTER_RECT_RIGHT(ix)
    cp      l
    jr      c, 149$
    ld      a, h
    cp      CHARACTER_RECT_TOP(ix)
    jr      c, 149$
    ld      a, CHARACTER_RECT_BOTTOM(ix)
    cp      d
    jr      c, 149$
    ld      a, CHARACTER_RECT_LEFT(ix)
    sub     l
    ld      c, a
    ld      a, h
    sub     c
    jr      nc, 142$
    xor     a
142$:
    cp      CHARACTER_RECT_TOP(ix)
    jr      c, 149$
    ld      a, CHARACTER_RECT_RIGHT(ix)
    sub     l
    ld      c, a
    ld      a, h
    sub     c
    jr      nc, 143$
    xor     a
143$:
    cp      CHARACTER_RECT_BOTTOM(ix)
    jr      nc, 149$
    ld      a, (gameHitDistance)
    ld      c, a
    ld      a, CHARACTER_RECT_LEFT(ix)
    sub     l
    jr      nc, 144$
    xor     a
144$:
    cp      c
    jr      nc, 149$
    ld      (gameHitCharacter), ix
    ld      (gameHitDistance), a
;   jr      149$
149$:
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    141$
    jr      190$

    ; 0300
150$:
    ld      ix, #_enemy
    ld      bc, #((ENEMY_ENTRY << 8) | 0xff)
151$:
    ld      a, CHARACTER_PROC_H(ix)
    or      CHARACTER_PROC_L(ix)
    jr      z, 159$
    ld      a, h
    cp      CHARACTER_RECT_TOP(ix)
    jr      c, 159$
    ld      a, CHARACTER_RECT_BOTTOM(ix)
    cp      h
    jr      c, 159$
    ld      a, e
    cp      CHARACTER_RECT_LEFT(ix)
    jr      c, 159$
    ld      a, CHARACTER_RECT_RIGHT(ix)
    cp      l
    jr      c, 159$
    ld      a, CHARACTER_RECT_O_X(ix)
    sub     l
    jr      nc, 152$
    xor     a
152$:
    cp      c
    jr      nc, 159$
    ld      (gameHitCharacter), ix
    ld      c, a
;   jr      159$
159$:
    push    bc
    ld      bc, #ENEMY_LENGTH
    add     ix, bc
    pop     bc
    djnz    151$
;   jr      190$

    ; 銃弾の完了
190$:
    ld      hl, (gameHitCharacter)
    ld      a, h
    or      l
    jr      z, 191$
    ld      bc, #CHARACTER_FLAG
    add     hl, bc
    set     #CHARACTER_FLAG_HIT_BIT, (hl)
    jr      192$
191$:
    call    _BulletEntry
;   jr      192$
192$:
    ld      hl, #0x0000
    ld      (_player + PLAYER_RAY_X_0), hl
    ld      (_player + PLAYER_RAY_X_1), hl
199$:

    ; ミサイルのヒット判定
200$:
    ld      ix, #_missile
    ld      b, #MISSILE_ENTRY
201$:
    push    bc

    ; ミサイルの存在
    ld      a, MISSILE_PROC_H(ix)
    or      MISSILE_PROC_L(ix)
    jr      z, 290$
    bit     #0x07, MISSILE_STATE(ix)
    jr      nz, 290$

    ; 地面との判定
    ld      e, MISSILE_POSITION_X_H(ix)
    ld      d, MISSILE_POSITION_Y_H(ix)
    call    _StageIsBlock
    jr      c, 280$

    ; プレイヤとの判定
    ld      hl, (_player + CHARACTER_RECT_LEFT)
    ld      bc, (_player + CHARACTER_RECT_RIGHT)
    ld      a, e
    cp      l
    jr      c, 290$
    cp      c
    jr      z, 210$
    jr      nc, 290$
210$:
    ld      a, d
    cp      h
    jr      c, 290$
    cp      b
    jr      z, 211$
    jr      nc, 290$
211$:

    ; 爆発
280$:
    call    _BombEntry
    xor     a
    ld      MISSILE_PROC_L(ix), a
    ld      MISSILE_PROC_H(ix), a
;   jr      290$

    ; 次のミサイルへ
290$:
    ld      bc, #MISSILE_LENGTH
    add     ix, bc
    pop     bc
    djnz    201$
299$:


    ; プレイヤとステージの接触判定
    ld      iy, #_player
;   bit     #CHARACTER_FLAG_HIT_BIT, CHARACTER_FLAG(iy)
;   jr      nz, 399$
300$:
    ld      de, (_player + CHARACTER_RECT_O_X)
    call    _StageIsDamage
    jr      nc, 399$

    ; ヒット
    ld      de, #0x0000
    ld      (_player + CHARACTER_HIT_SPEED_L), de
    set     #CHARACTER_FLAG_HIT_BIT, CHARACTER_FLAG(iy)
    inc     CHARACTER_HIT_DAMAGE(iy)
;   jr      399$
399$:

    ; プレイヤとエネミーの接触判定
;   ld      iy, #_player
;   bit     #CHARACTER_FLAG_HIT_BIT, CHARACTER_FLAG(iy)
;   jr      nz, 499$
400$:
    ld      hl, (_player + CHARACTER_RECT_O_X)
    ld      ix, #_enemy
    ld      de, #ENEMY_LENGTH
    ld      b, #ENEMY_ENTRY
401$:

    ; エネミーの存在
    ld      a, CHARACTER_PROC_H(ix)
    or      CHARACTER_PROC_L(ix)
    jr      z, 490$

    ; プレイヤとの判定
    ld      a, l
    cp      CHARACTER_RECT_LEFT(ix)
    jr      c, 490$
    cp      CHARACTER_RECT_RIGHT(ix)
    jr      z, 410$
    jr      nc, 490$
410$:
    ld      a, h
    cp      CHARACTER_RECT_TOP(ix)
    jr      c, 490$
    cp      CHARACTER_RECT_BOTTOM(ix)
    jr      z, 411$
    jr      nc, 490$
411$:

    ; ヒット
    ld      de, #0x0000
    ld      (_player + CHARACTER_HIT_SPEED_L), de
    set     #CHARACTER_FLAG_HIT_BIT, CHARACTER_FLAG(iy)
    inc     CHARACTER_HIT_DAMAGE(iy)
;   jr      490$

    ; 次のエネミーへ
490$:
    add     ix, de
    djnz    401$
499$:

    ; 爆発のヒット判定
;   ld      iy, #_player
;   bit     #CHARACTER_FLAG_HIT_BIT, CHARACTER_FLAG(iy)
;   jr      nz, 599$
500$:
    ld      hl, (_player + CHARACTER_RECT_O_X)
    ld      ix, #_bomb
    ld      b, #BOMB_ENTRY
501$:

    ; 爆発の存在
    ld      a, BOMB_R(ix)
    or      a
    jr      z, 590$
    ld      c, a

    ; プレイヤとの判定
    ld      a, BOMB_POSITION_Y(ix)
    sub     h
    jr      nc, 510$
    neg
510$:
    cp      c
    jr      nc, 590$
    ld      a, BOMB_POSITION_X(ix)
    sub     l
    jr      nz, 511$
    ld      de, #0x0000
    jr      513$
511$:
    jr      nc, 512$
    neg
    cp      c
    jr      nc, 590$
    ld      de, #PLAYER_SPEED_X_HIT
    jr      513$
512$:
    cp      c
    jr      nc, 590$
    ld      de, #-PLAYER_SPEED_X_HIT
;   jr      513$
513$:

    ; ヒット
    ld      (_player + CHARACTER_HIT_SPEED_L), de
    set     #CHARACTER_FLAG_HIT_BIT, CHARACTER_FLAG(iy)
    ld      a, CHARACTER_HIT_DAMAGE(iy)
    add     a, #CHARACTER_HIT_DAMAGE_BOMB
    ld      CHARACTER_HIT_DAMAGE(iy), a
;   jr      590$

    ; 次の爆発へ
590$:
    ld      de, #BOMB_LENGTH
    add     ix, de
    djnz    501$
599$:

    ; レジスタの復帰

    ; 終了
    ret

; ゲームがプレイ中かどうかを判定する
;
_GameIsPlay::

    ; レジスタの保存

    ; cf > 1 = プレイ中

    ; プレイの判定
    ld      a, (_game + GAME_FLAG)
    and     #GAME_FLAG_PLAY
    jr      z, 10$
    scf
10$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; ゲームの初期値
;
gameDefault:

    .dw     GAME_PROC_NULL
    .db     GAME_STATE_NULL
    .db     GAME_FLAG_NULL
    .db     GAME_INPUT_NULL
    .db     GAME_INPUT_NULL
    .db     GAME_INPUT_NULL
    .db     GAME_INPUT_NULL
    .db     GAME_INPUT_NULL
    .db     GAME_INPUT_NULL
    .dw     _sprite + GAME_SPRITE_MISSILE ; GAME_SPRITE_NULL
    .dw     _sprite + GAME_SPRITE_ENEMY   ; GAME_SPRITE_NULL
    .dw     GAME_SPRITE_NULL
    .db     GAME_LEVEL_NULL
    .db     GAME_FRAME_NULL

; 文字列
;
gameStringStart:

    .ascii  "MISSION"
    .db     0x0a, 0x0a
    .ascii  "INVADE ENEMY TERRITORY"
    .db     0x0a, 0x0a
    .ascii  "AND DESTROY ALL TARGETS"
    .db     0x00

gameStringIncomplete:

    .ascii  "MISSION INCOMPLETE"
    .db     0x00

gameStringComplete:

    .ascii  "MISSION COMPLETE"
    .db     0x00

gameStringBeamAttack:

    .ascii  "BEAMS ATTACK"
    .db     0x00

gameStringNewPhase:

    .ascii  "THE WAR ENTERS NEW PHASE"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; ゲーム
;
_game::

    .ds     GAME_LENGTH

; ヒット判定
;
gameHitCharacter:

    .ds     0x02

gameHitDistance:

    .ds     0x01

