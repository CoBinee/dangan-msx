; Title.s : タイトル
;


; モジュール宣言
;
    .module Title

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Fade.inc"
    .include    "Message.inc"
    .include	"Title.inc"

; 外部変数宣言
;
    .globl  _spriteTable

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; タイトルを初期化する
;
_TitleInitialize::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite
    
    ; パターンネームのクリア
    ld      a, #APP_PATTERN_NAME_BLANK
    call    _SystemClearPatternName
    
    ; タイトルの初期化
    ld      hl, #titleDefault
    ld      de, #_title
    ld      bc, #TITLE_LENGTH
    ldir

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
    ld      hl, #TitleDemo
    ld      (_title + TITLE_PROC_L), hl
    xor     a
    ld      (_title + TITLE_STATE), a

    ; アプリケーションの更新
    ld      a, #APP_STATE_TITLE_UPDATE
    ld      (_app + APP_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; タイトルを更新する
;
_TitleUpdate::
    
    ; レジスタの保存
    
    ; スプライトのクリア
    call    _SystemClearSprite

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      hl, (_title + TITLE_PROC_L)
    jp      (hl)
;   pop     hl
10$:

    ; レジスタの復帰
    
    ; 終了
    ret

; 何もしない
;
TitleNull:

    ; レジスタの保存

    ; レジスタの復帰

    ; 終了
    ret

; タイトルデモを表示する
;
TitleDemo:

    ; レジスタの保存

    ; 初期化
    ld      a, (_title + TITLE_STATE)
    or      a
    jr      nz, 09$

    ; アニメーションの開始
    ld      hl, #titleAnimationDemo1
    call    TitleStartAnimation

    ; フェードの開始
    call    _FadeInStart

    ; カラーテーブルの切替
    ld      a, #(APP_COLOR_TABLE_NORMAL >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; 初期化の完了
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
09$:

    ; 0x01 : アニメーション１
110$:
    ld      a, (_title + TITLE_STATE)
    dec     a
    jr      nz, 120$
    ld      hl, #titleStringDemo1
    call    700$
    jp      nc, 90$
    jp      80$

    ; 0x02 : メッセージ１
120$:
    dec     a
    jr      nz, 130$
    ld      hl, #titleAnimationDemo2
    call    710$
    jp      nc, 90$
    jp      80$

    ; 0x03 : アニメーション２
130$:
    dec     a
    jr      nz, 140$
    ld      hl, #titleStringDemo2
    call    700$
    jp      nc, 90$
    jr      80$

    ; 0x04 : メッセージ２
140$:
    dec     a
    jr      nz, 150$
    ld      hl, #titleAnimationDemo3
    call    710$
    jr      nc, 90$
    jr      80$

    ; 0x05 : アニメーション３
150$:
    dec     a
    jr      nz, 160$
    ld      hl, #titleStringDemo3
    call    700$
    jr      nc, 90$
    jr      80$

    ; 0x06 : メッセージ３
160$:
;   dec     a
;   jr      nz, 170$
    ld      hl, #0x0000
    call    710$
    jr      nc, 90$
    jr      91$

    ; アニメーションの再生
700$:
    push    hl

    ; アニメーションの更新
    call    TitleUpdateAnimation

    ; フェードの更新
    call    _FadeInUpdate

    ; アニメーションの描画
    call    TitleEraseScreen
    call    TitlePrintAnimation

    ; フェードの描画
    call    _FadeRender

    ; アニメーションの監視
    call    TitleIsDoneAnimation
    jr      nc, 709$

    ; フェードの開始
    call    _FadeOutStart

    ; メッセージの開始
    ld      hl, #0x0000
    add     hl, sp
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    ld      a, h
    or      l
    ld      d, #0x05
    call    nz, _MessageStartCentering
    scf

    ; 終了
709$:
    pop     hl
    ret

    ; メッセージの表示
710$:
    push    hl

    ; フェードの更新
    call    _FadeOutUpdate

    ; フェードの描画
    call    _FadeRender

    ; フェードの監視
    call    _FadeOutIsDone
    jr      nc, 719$

    ; メッセージの表示
    call    _MessagePrint

    ; メッセージの監視
    ld      c, #0x38
    call    _MessageIsDone
    jr      nc, 719$

    ; アニメーションの開始
    ld      hl, #0x0000
    add     hl, sp
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    ld      a, h
    or      l
    call    nz, TitleStartAnimation
    scf
    
    ; 終了
719$:
    pop     hl
    ret

    ; 状態の更新
80$:
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
;   jr      90$

    ; デモの完了
90$:

    ; SPACE キーの入力
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 99$

    ; SE の再生
    ld      a, #SOUND_SE_CLICK
    call    _SoundPlaySeA
    
    ; 処理の更新
91$:
    ld      hl, #TitleLogo
    ld      (_title + TITLE_PROC_L), hl
    xor     a
    ld      (_title + TITLE_STATE), a
99$:

    ; レジスタの復帰

    ; 終了
    ret

; タイトルロゴを表示する
;
TitleLogo:

    ; レジスタの保存

    ; 初期化
    ld      a, (_title + TITLE_STATE)
    or      a
    jr      nz, 09$

    ; アニメーションの開始
    ld      hl, #titleAnimationLogoAim
    call    TitleStartAnimation

    ; フェードの開始
    call    _FadeInStart

    ; カラーテーブルの切替
    ld      a, #(APP_COLOR_TABLE_REVERSE >> 6)
    ld      (_videoRegister + VDP_R3), a

    ; 初期化の完了
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
09$:

    ; アニメーションの更新
    call    TitleUpdateAnimation

    ; フェードの更新
    call    _FadeInUpdate

    ; アニメーションの描画
    call    TitleEraseScreen
    call    TitlePrintAnimation

    ; ロゴの描画
    call    TitlePrintLogo

    ; フェードの描画
    call    _FadeRender

    ; 0x01 : 照準
10$:
    ld      a, (_title + TITLE_STATE)
    dec     a
    jr      nz, 20$

    ; アニメーションの監視
    call    TitleIsDoneAnimation
    jr      nc, 90$

    ; アニメーションの開始
    ld      hl, #titleAnimationLogoFire
    call    TitleStartAnimation

    ; ロゴの更新
    ld      hl, #(_title + TITLE_LOGO)
    inc     (hl)
    jr      80$

    ; 0x02 : 発射
20$:
;   dec     a
;   jr      nz, 30$

    ; アニメーションの監視
    call    TitleIsDoneAnimation
    jr      nc, 90$

    ; ロゴの監視
    ld      a, (_title + TITLE_LOGO)
    cp      #TITLE_LOGO_LENGTH
    jr      nc, 91$

    ; アニメーションの開始
    ld      hl, #titleAnimationLogoFire
    call    TitleStartAnimation

    ; ロゴの更新
    ld      hl, #(_title + TITLE_LOGO)
    inc     (hl)
    jr      90$

    ; 状態の更新
80$:
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
;   jr      90$

    ; ロゴの完了
90$:

    ; SPACE キーの入力
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 99$
    
    ; SE の再生
    ld      a, #SOUND_SE_CLICK
    call    _SoundPlaySeA
    
    ; 処理の更新
91$:
    ld      hl, #TitleIdle
    ld      (_title + TITLE_PROC_L), hl
    xor     a
    ld      (_title + TITLE_STATE), a
99$:
    ; レジスタの復帰

    ; 終了
    ret

; タイトルを待機する
;
TitleIdle:

    ; レジスタの保存

    ; 初期化
    ld      a, (_title + TITLE_STATE)
    or      a
    jr      nz, 09$

    ; ロゴの設定
    ld      a, #TITLE_LOGO_LENGTH
    ld      (_title + TITLE_LOGO), a

    ; アニメーションの開始
    ld      hl, #titleAnimationIdle
    call    TitleStartAnimation

    ; 初期化の完了
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
09$:

    ; アニメーションの更新
    call    TitleUpdateAnimation

    ; アニメーションの描画
    call    TitleEraseScreen
    call    TitlePrintAnimation

    ; ロゴの描画
    call    TitlePrintLogo

    ; 0x01 : キー入力
10$:
    ld      a, (_title + TITLE_STATE)
    dec     a
    jr      nz, 20$

    ; SPACE キー
    ld      a, (_input + INPUT_BUTTON_SPACE)
    dec     a
    jr      nz, 90$

    ; SE の再生
    ld      a, #SOUND_SE_BOOT
    call    _SoundPlaySeA

    ; フレームの設定
    ld      a, #TITLE_FRAME_START
    ld      (_title + TITLE_FRAME), a
    jr      80$

    ; 0x02 : SE の再生
20$:
    dec     a
    jr      nz, 30$

    ; フレームの更新
    ld      hl, #(_title + TITLE_FRAME)
    dec     (hl)
    jr      nz, 90$

    ; フェードの開始
    call    _FadeOutStart
    jr      80$

    ; 0x03 : フェードアウト
30$:
;   dec     a
;   jr      nz, 40$

    ; フェードの更新
    call    _FadeOutUpdate

    ; フェードの描画
    call    _FadeRender

    ; フェードの監視
    call    _FadeOutIsDone
    jr      nc, 90$

    ; アプリケーションの更新
    ld      a, #APP_STATE_GAME_INITIALIZE
    ld      (_app + APP_STATE), a
    jr      90$

    ; 状態の更新
80$:
    ld      hl, #(_title + TITLE_STATE)
    inc     (hl)
;   jr      90$

    ; 待機の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 画面を消す
;
TitleEraseScreen:

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; 画面の消去
    ld      hl, #(_patternName + APP_VIEW_Y * APP_VIEW_SIZE_X + 0x0000)
    ld      de, #(_patternName + APP_VIEW_Y * APP_VIEW_SIZE_X + 0x0001)
    ld      bc, #(APP_VIEW_SIZE_Y * APP_VIEW_SIZE_X - 0x0001)
    ld      (hl), #APP_PATTERN_NAME_BLANK
    ldir

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; アニメーションを開始する
;
TitleStartAnimation:
    
    ; レジスタの保存
    push    hl
    push    de

    ; hl < アニメーション

    ; フレームの設定
    ld      a, (hl)
    ld      (_title + TITLE_ANIMATION_FRAME), a

    ; アニメーションの設定
    ld      (_title + TITLE_ANIMATION_L), hl

    ; SE の再生
    ld      de, #TITLE_ANIMATION_SOUND
    add     hl, de
    ld      a, (hl)
    or      a
    call    nz, _SoundPlaySeA

    ; レジスタの復帰
    pop     de
    pop     hl
    
    ; 終了
    ret

; アニメーションを更新する
;
TitleUpdateAnimation:

    ; レジスタの保存
    push    hl
    push    de

    ; フレームの更新
    ld      hl, #(_title + TITLE_ANIMATION_FRAME)
    ld      a, (hl)
    or      a
    jr      z, 10$
    inc     a
    jr      z, 90$
    dec     (hl)
    jr      90$

    ; 次のアニメーション
10$:
    ld      hl, (_title + TITLE_ANIMATION_L)
    ld      de, #TITLE_ANIMATION_LENGTH
    add     hl, de
    ld      a, (hl)
    or      a
    jr      z, 11$
    call    TitleStartAnimation
    jr      90$
11$:
    ld      a, #0xff
    ld      (_title + TITLE_ANIMATION_FRAME), a
;   jr      90$

    ; 更新の完了
90$:

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

; アニメーションを表示する
;
TitlePrintAnimation:

    ; レジスタの保存
    push    hl
    push    bc
    push    de

    ; アニメーションの取得
    ld      hl, (_title + TITLE_ANIMATION_L)
    inc     hl
    ld      e, (hl)
    inc     hl
    ld      b, (hl)
    inc     hl
    ld      c, (hl)
;   inc     hl

    ; マスクの描画
    push    bc
    ld      hl, #(_patternName + TITLE_DEMO_Y * TITLE_DEMO_SIZE_X)
    ld      b, #0x08
10$:
    rl      c
    jr      c, 11$
    ld      a, #APP_PATTERN_NAME_BLANK
    jr      12$
11$:
    ld      a, #TITLE_DEMO_PATTERN_NAME_BACK
12$:
    ld      d, #TITLE_DEMO_SIZE_X
13$:
    ld      (hl), a
    inc     hl
    dec     d
    jr      nz, 13$
    djnz    10$
    pop     bc

    ; 表示位置の取得
    ld      d, #0x00
    ld      hl, #(_patternName + TITLE_DEMO_Y * TITLE_DEMO_SIZE_X)
    add     hl, de

    ; パターンの取得
    push    hl
    ld      a, b
;   ld      d, #0x00
    add     a, a
    rl      d
    add     a, a
    rl      d
    add     a, a
    rl      d
    ld      e, a
    ld      hl, #_spriteTable
    add     hl, de
    ex      de, hl
    pop     hl

    ; パターンの描画
    ld      b, #0x08
20$:
    push    hl
    rl      c
    jr      nc, 29$
    ld      a, (de)
21$:
    add     a, a
    jr      nc, 22$
    ld      (hl), #TITLE_DEMO_PATTERN_NAME_FRONT
22$:
    inc     hl
    or      a
    jr      nz, 21$
29$:
    pop     hl
    push    bc
    ld      bc, #TITLE_DEMO_SIZE_X
    add     hl, bc
    pop     bc
    inc     de
    djnz    20$

    ; レジスタの復帰
    pop     de
    pop     bc
    pop     hl

    ; 終了
    ret

; アニメーションが完了したかどうかを判定する
;
TitleIsDoneAnimation:

    ; レジスタの保存

    ; cf > 1 = 完了

    ; アニメーションの判定
    ld      a, (_title + TITLE_ANIMATION_FRAME)
    inc     a
    jr      z, 10$
    or      a
    jr      19$
10$:
    scf
;   jr      19$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; ロゴを表示する
;
TitlePrintLogo:

    ; レジスタの保存

    ; ロゴの描画
    ld      a, (_title + TITLE_LOGO)
    or      a
    jr      z, 19$
    ld      b, a
    ld      hl, #titleStringLogo
    ld      de, #(_patternName + (TITLE_DEMO_Y + 0x04) * TITLE_DEMO_SIZE_X + 0x0a + (0x16 - TITLE_LOGO_LENGTH) / 2)
10$:
    ld      a, (hl)
    sub     #0x20
    ld      (de), a
    inc     hl
    inc     de
    djnz    10$
19$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; タイトルの初期値
;
titleDefault:

    .dw     TITLE_PROC_NULL
    .db     TITLE_STATE_NULL
    .db     TITLE_FLAG_NULL
    .db     TITLE_ANIMATION_NULL
    .db     TITLE_ANIMATION_NULL
    .db     TITLE_ANIMATION_NULL
    .db     TITLE_ANIMATION_NULL
    .db     TITLE_LOGO_NULL

; アニメーション
;
titleAnimationDemo1:

    .db     0x30, 0x02, 0x34, 0b00011111, SOUND_SE_NULL
    .db     0x30, 0x02, 0x30, 0b00011111, SOUND_SE_NULL
    .db     0x00

titleAnimationDemo2:

    .db     0x30, 0x16, 0x40, 0b00111110, SOUND_SE_NULL
    .db     0x30, 0x18, 0x4a, 0b00111110, SOUND_SE_NULL
    .db     0x00

titleAnimationDemo3:

    .db     0x08, 0x08, 0x20, 0b11111000, SOUND_SE_NULL
    .db     0x08, 0x06, 0x21, 0b11111000, SOUND_SE_NULL
    .db     0x08, 0x06, 0x22, 0b11111000, SOUND_SE_WALK
    .db     0x08, 0x04, 0x23, 0b11111000, SOUND_SE_NULL
    .db     0x08, 0x04, 0x20, 0b11111000, SOUND_SE_NULL
    .db     0x08, 0x02, 0x21, 0b11111000, SOUND_SE_NULL
    .db     0x08, 0x02, 0x22, 0b11111000, SOUND_SE_WALK
    .db     0x08, 0x00, 0x23, 0b11111000, SOUND_SE_NULL
    .db     0x08, 0x00, 0x20, 0b11111000, SOUND_SE_NULL
    .db     0x18, 0x00, 0x38, 0b11111000, SOUND_SE_NULL
    .db     0x00

titleAnimationLogoAim:

    .db     0x18, 0x00, 0x38, 0b11111111, SOUND_SE_NULL
    .db     0x08, 0x00, 0x30, 0b11111111, SOUND_SE_NULL
    .db     0x08, 0x02, 0x31, 0b11111111, SOUND_SE_NULL
    .db     0x08, 0x02, 0x32, 0b11111111, SOUND_SE_WALK
    .db     0x08, 0x04, 0x33, 0b11111111, SOUND_SE_NULL
    .db     0x18, 0x04, 0x30, 0b11111111, SOUND_SE_NULL
    .db     0x18, 0x02, 0x3a, 0b11111111, SOUND_SE_NULL
    .db     0x00

titleAnimationLogoFire:

    .db     0x01, 0x02, 0x3b, 0b11111111, SOUND_SE_BULLET
    .db     0x01, 0x02, 0x3a, 0b11111111, SOUND_SE_NULL
    .db     0x00

titleAnimationIdle:

    .db     0xff, 0x02, 0x3a, 0b11111111, SOUND_SE_NULL

; 文字列
;
titleStringDemo1:

    .ascii  "ULTIMATE IS BULLETS"
    .db     0x00

titleStringDemo2:

    .ascii  "SHELLS ARE SUPREME"
    .db     0x00

titleStringDemo3:

    .ascii  "THE WAR BEGAN"
    .db     0x00

titleStringLogo:

    .ascii  "DANGAN TROOPER"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; タイトル
;
_title::

    .ds     TITLE_LENGTH

