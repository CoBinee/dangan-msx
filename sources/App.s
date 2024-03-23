; App.s : アプリケーション
;


; モジュール宣言
;
    .module App

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include	"App.inc"
    .include    "Title.inc"
    .include    "Game.inc"

; 外部変数宣言
;
    .globl  _spriteTable
    .globl  _patternTable
    

; CODE 領域
;
    .area   _CODE

; アプリケーションを初期化する
;
_AppInitialize::
    
    ; レジスタの保存
    
    ; 画面表示の停止
    call    DISSCR
    
    ; ビデオの設定
    ld      hl, #videoScreen1
    ld      de, #_videoRegister
    ld      bc, #0x08
    ldir
    
    ; 割り込みの禁止
    di
    
    ; VDP ポートの取得
    ld      a, (_videoPort + 1)
    ld      c, a
    
    ; スプライトジェネレータの転送
    ld      hl, #(_spriteTable + 0x0000)
    ld      de, #(APP_SPRITE_GENERATOR_TABLE + 0x0000)
    ld      bc, #0x0800
    call    LDIRVM
    
    ; パターンジェネレータの転送
    ld      hl, #(_patternTable + 0x0000)
    ld      de, #(APP_PATTERN_GENERATOR_TABLE + 0x0000)
    ld      bc, #0x0800
    call    LDIRVM

    ; カラーテーブルの転送
;   ld      hl, #(APP_COLOR_TABLE + 0x0000)
;   ld      a, #((VDP_COLOR_WHITE << 4) | VDP_COLOR_BLACK)
;   ld      bc, #0x0020
;   call    FILVRM
    ld      hl, #(colorTable + 0x0000)
    ld      de, #(APP_COLOR_TABLE_NORMAL + 0x0000)
    ld      bc, #0x0020
    call    LDIRVM
    ld      hl, #(colorTable + 0x0020)
    ld      de, #(APP_COLOR_TABLE_REVERSE + 0x0000)
    ld      bc, #0x0020
    call    LDIRVM

    ; パターンネームの初期化
    ld      hl, #APP_PATTERN_NAME_TABLE
    xor     a
    ld      bc, #0x0300
    call    FILVRM
    
    ; 割り込み禁止の解除
    ei

    ; アプリケーションの初期化
    ld      hl, #appDefault
    ld      de, #_app
    ld      bc, #APP_LENGTH
    ldir
    
    ; パターンネームのクリア
    ld      a, #APP_PATTERN_NAME_BLANK
    call    _SystemClearPatternName

    ; 状態の初期化
    ld      a, #APP_STATE_TITLE_INITIALIZE
    ld      (_app + APP_STATE), a
    
    ; レジスタの復帰
    
    ; 終了
    ret

; アプリケーションを更新する
;
_AppUpdate::
    
    ; レジスタの保存

    ; 状態別の処理
    ld      hl, #10$
    push    hl
    ld      a, (_app + APP_STATE)
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #appProc
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
    ex      de, hl
    jp      (hl)
;   pop     hl
10$:

    ; 乱数を混ぜる
    call    _SystemGetRandom

;   ; デバッグ表示
    ld      hl, #(_debug + DEBUG_7)
    inc     (hl)
    call    AppPrintDebug

    ; 更新の終了
90$:

    ; レジスタの復帰
    
    ; 終了
    ret

; 画面を転送する
;
_AppTransfer::
    
    ; レジスタの保存
    
    ; d < ポート #0
    ; e < ポート #1

    ; パターンネームテーブルの取得
    ld      a, (_videoRegister + VDP_R2)
    add     a, a
    add     a, a
    add     a, #((APP_VIEW_Y * APP_VIEW_SIZE_X) >> 8)
    ld      l, #(APP_VIEW_Y * APP_VIEW_SIZE_X)

    ; VRAM アドレスの設定
    ld      c, e
    out     (c), l
    or      #0b01000000
    out     (c), a

    ; パターンネームテーブルの転送
    ld      c, d
    ld      hl, #(_patternName + APP_VIEW_Y * APP_VIEW_SIZE_X)
    ld      b, #0x00
;   otir
;   nop
10$:
    outi
    jp      nz, 10$
    ld      b, #((APP_VIEW_SIZE_Y - 0x08) * APP_VIEW_SIZE_X)
;   otir
;   nop
11$:
    outi
    jp      nz, 11$

    ; デバッグ
    jr      29$

    ; パターンネームテーブルの取得
    ld      a, (_videoRegister + VDP_R2)
    add     a, a
    add     a, a
    add     a, #0x02
    ld      l, #0xe0

    ; VRAM アドレスの設定
    ld      c, e
    out     (c), l
    or      #0b01000000
    out     (c), a

    ; パターンネームテーブルの転送
    ld      c, d
    ld      hl, #(_patternName + 0x02e0)
    ld      b, #0x20
;   otir
;   nop
20$:
    outi
    jp      nz, 20$
29$:
    
    ; レジスタの復帰
    
    ; 終了
    ret

; 処理なし
;
_AppNull::

    ; レジスタの保存
    
    ; レジスタの復帰
    
    ; 終了
    ret

; デバッグ情報を表示する
;
AppPrintDebug:

    ; レジスタの保存

    ; デバッグ数値の表示
    ld      de, #(_patternName + 0x02e0)
    ld      hl, #appDebugStringNumber
    call    70$
    ld      hl, #_debug
    ld      b, #DEBUG_SIZE
10$:
    ld      a, (hl)
    call    80$
    inc     hl
    djnz    10$
    jr      90$

    ; 文字列の表示
70$:
    ld      a, (hl)
    sub     #0x20
    ret     c
    ld      (de), a
    inc     hl
    inc     de
    jr      70$

    ; 16 進数の表示
80$:
    push    af
    rrca
    rrca
    rrca
    rrca
    call    81$
    pop     af
    call    81$
    ret
81$:
    and     #0x0f
    cp      #0x0a
    jr      c, 82$
    add     a, #0x07
82$:
    add     a, #0x10
    ld      (de), a
    inc     de
    ret

    ; デバッグ表示の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; VDP レジスタ値（スクリーン１）
;
videoScreen1:

    .db     0b00000000
    .db     0b10100001
    .db     APP_PATTERN_NAME_TABLE >> 10
    .db     APP_COLOR_TABLE_NORMAL >> 6
    .db     APP_PATTERN_GENERATOR_TABLE >> 11
    .db     APP_SPRITE_ATTRIBUTE_TABLE >> 7
    .db     APP_SPRITE_GENERATOR_TABLE >> 11
    .db     0b00000111

; カラーテーブル
;
colorTable:

    ; normal
    .db     (VDP_COLOR_WHITE << 4) | VDP_COLOR_BLACK, (VDP_COLOR_WHITE << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE << 4) | VDP_COLOR_BLACK, (VDP_COLOR_WHITE << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE << 4) | VDP_COLOR_BLACK, (VDP_COLOR_WHITE << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_WHITE << 4) | VDP_COLOR_BLACK, (VDP_COLOR_WHITE << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE, (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_MEDIUM_RED << 4) | VDP_COLOR_WHITE, (VDP_COLOR_MEDIUM_RED << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_WHITE << 4) | VDP_COLOR_BLACK, (VDP_COLOR_WHITE << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE, (VDP_COLOR_MEDIUM_RED << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE, (VDP_COLOR_MEDIUM_RED << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE, (VDP_COLOR_MEDIUM_RED << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE, (VDP_COLOR_MEDIUM_RED << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE, (VDP_COLOR_MEDIUM_RED << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE, (VDP_COLOR_MEDIUM_RED << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE, (VDP_COLOR_MEDIUM_RED << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE, (VDP_COLOR_MEDIUM_RED << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE, (VDP_COLOR_MEDIUM_RED << 4) | VDP_COLOR_WHITE
    ; reverse
    .db     (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE, (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE, (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE, (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE, (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE, (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_MEDIUM_RED << 4) | VDP_COLOR_WHITE, (VDP_COLOR_MEDIUM_RED << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_WHITE << 4) | VDP_COLOR_BLACK, (VDP_COLOR_WHITE << 4) | VDP_COLOR_BLACK
    .db     (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE, (VDP_COLOR_MEDIUM_RED << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE, (VDP_COLOR_MEDIUM_RED << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE, (VDP_COLOR_MEDIUM_RED << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE, (VDP_COLOR_MEDIUM_RED << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE, (VDP_COLOR_MEDIUM_RED << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE, (VDP_COLOR_MEDIUM_RED << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE, (VDP_COLOR_MEDIUM_RED << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE, (VDP_COLOR_MEDIUM_RED << 4) | VDP_COLOR_WHITE
    .db     (VDP_COLOR_BLACK << 4) | VDP_COLOR_WHITE, (VDP_COLOR_MEDIUM_RED << 4) | VDP_COLOR_WHITE

; 状態別の処理
;
appProc:
    
    .dw     _AppNull
    .dw     _TitleInitialize
    .dw     _TitleUpdate
    .dw     _GameInitialize
    .dw     _GameUpdate

; アプリケーションの初期値
;
appDefault:

    .db     APP_STATE_NULL
    .db     APP_FRAME_NULL

; デバッグ
;
appDebugStringNumber:

    .ascii  "DBG="
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; アプリケーション
;
_app::

    .ds     APP_LENGTH

