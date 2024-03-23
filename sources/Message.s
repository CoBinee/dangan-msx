; Message.s : メッセージ
;


; モジュール宣言
;
    .module Message

; 参照ファイル
;
    .include    "bios.inc"
    .include    "vdp.inc"
    .include    "System.inc"
    .include    "Sound.inc"
    .include    "App.inc"
    .include    "Game.inc"
    .include	"Message.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; メッセージを初期化する
;
_MessageInitialize::
    
    ; レジスタの保存
    
    ; メッセージの初期化
    ld      hl, #(_message + 0x0000)
    ld      de, #(_message + 0x0001)
    ld      bc, #(MESSAGE_LENGTH - 0x0001)
    ld      (hl), #0x00
    ldir

    ; レジスタの復帰
    
    ; 終了
    ret

; メッセージを開始する
;
_MessageStart::

    ; レジスタの保存
    push    hl
    push    de

    ; hl < 文字列
    ; de < Y/X 位置

    ; メッセージの開始
    ld      (_message + MESSAGE_STRING_L), hl
    xor     a
    srl     d
    rra
    srl     d
    rra
    srl     d
    rra
    add     a, e
    ld      e, a
    ld      hl, #(_patternName + APP_VIEW_SIZE_X * APP_VIEW_Y)
    add     hl, de
    ld      (_message + MESSAGE_PRINT_L), hl
    ld      (_message + MESSAGE_CURSOR_L), hl
    xor     a
    ld      (_message + MESSAGE_FLAG), a
    ld      (_message + MESSAGE_FRAME), a
    ld      (_message + MESSAGE_COUNT), a

    ; レジスタの復帰
    pop     de
    pop     hl

    ; 終了
    ret

_MessageStartCentering::

    ; レジスタの保存
    push    de

    ; hl < 文字列
    ; d  < Y 位置

    ; メッセージの開始
    ld      e, #0x00
    call    _MessageStart

    ; フラグの設定
    ld      a, #MESSAGE_FLAG_CENTERING
    ld      (_message + MESSAGE_FLAG), a

    ; センタリング
    ld      hl, (_message + MESSAGE_PRINT_L)
    ld      de, (_message + MESSAGE_STRING_L)
    call    MessageCentering
    ld      (_message + MESSAGE_PRINT_L), hl
    ld      (_message + MESSAGE_CURSOR_L), hl

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

; メッセージを表示する
;
_MessagePrint::

    ; レジスタの保存

    ; メッセージの存在
    ld      de, (_message + MESSAGE_STRING_L)
    ld      a, d
    or      e
    jr      z, 90$

    ; カーソルを消す
    ld      hl, (_message + MESSAGE_CURSOR_L)
    ld      (hl), #0x00

    ; フレームの更新
    ld      hl, #(_message + MESSAGE_FRAME)
    inc     (hl)

    ; 文字数の更新
    ld      a, (_message + MESSAGE_COUNT)
    ld      l, a
    ld      h, #0x00
    add     hl, de
    ld      a, (hl)
    or      a
    jr      z, 19$
    ld      bc, #(_message + MESSAGE_FRAME)
    ld      a, (bc)
    cp      #MESSAGE_FRAME_TEXT
    jr      c, 19$
    xor     a
    ld      (bc), a
    ld      a, (_message + MESSAGE_COUNT)
    ld      c, a
10$:
    inc     hl
    inc     c
    ld      a, (hl)
    cp      #0x0a
    jr      z, 10$
    ld      a, c
    ld      (_message + MESSAGE_COUNT), a
19$:

    ; 文字列の描画
    ld      hl, (_message + MESSAGE_PRINT_L)
    ld      a, (_message + MESSAGE_COUNT)
    or      a
    jr      z, 29$
    ld      b, a
20$:
    ld      a, (de)
    inc     de
    sub     #0x20
    jr      c, 21$
    ld      (hl), a
    inc     hl
    jr      23$
21$:
    push    bc
    ld      bc, #(_patternName + APP_VIEW_SIZE_X * APP_VIEW_Y)
    or      a
    sbc     hl, bc
    ld      a, l
    add     a, #0x20
    ld      l, a
    jr      nc, 22$
    inc     h
22$:
    add     hl, bc
    pop     bc
    ld      a, (_message + MESSAGE_FLAG)
    bit     #MESSAGE_FLAG_CENTERING_BIT, a
    call    nz, MessageCentering
23$:
    djnz    20$
    ld      (_message + MESSAGE_CURSOR_L), hl
29$:

    ; カーソルの描画
    ld      a, (_message + MESSAGE_FRAME)
    and     #MESSAGE_FRAME_BLINK
    jr      nz, 39$
    ld      hl, (_message + MESSAGE_CURSOR_L)
    ld      (hl), #0x3f
39$:

    ; 描画の完了
90$:

    ; レジスタの復帰

    ; 終了
    ret

; センタリング位置を設定する
;
MessageCentering:

    ; レジスタの保存
    push    bc
    push    de

    ; hl < 描画位置
    ; de < 文字列
    ; hl > 描画位置

    ; センタリング
    ld      bc, #(_patternName + APP_VIEW_SIZE_X * APP_VIEW_Y)
    or      a
    sbc     hl, bc
    ld      b, #0x00
10$:
    ld      a, (de)
    cp      #0x20
    jr      c, 11$
    inc     de
    inc     b
    jr      10$
11$:
    ld      a, l
    and     #0xe0
    ld      l, a
    ld      a, #0x20
    sub     b
    srl     a
    or      l
    ld      l, a
    ld      bc, #(_patternName + APP_VIEW_SIZE_X * APP_VIEW_Y)
    add     hl, bc

    ; レジスタの復帰
    pop     de
    pop     bc

    ; 終了
    ret

; メッセージの表示が完了したかどうかを判定する
;
_MessageIsDone::

    ; レジスタの保存

    ; c  < 完了までの時間
    ; cf > 1 = 完了

    ; 表示の判定
    ld      a, (_message + MESSAGE_FRAME)
    cp      c
    ccf

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;


; DATA 領域
;
    .area   _DATA

; 変数の定義
;

; メッセージ
;
_message::
    
    .ds     MESSAGE_LENGTH

