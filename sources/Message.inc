; Message.inc : メッセージ
;


; マクロの定義
;

; メッセージ
MESSAGE_STRING_L                =   0x00
MESSAGE_STRING_H                =   0x01
MESSAGE_PRINT_L                 =   0x02
MESSAGE_PRINT_H                 =   0x03
MESSAGE_CURSOR_L                =   0x04
MESSAGE_CURSOR_H                =   0x05
MESSAGE_FLAG                    =   0x06
MESSAGE_FRAME                   =   0x07
MESSAGE_COUNT                   =   0x08
MESSAGE_LENGTH                  =   0x09

; 文字列
MESSAGE_STRING_NULL             =   0x00

; 表示
MESSAGE_PRINT_NULL              =   0x00

; カーソル
MESSAGE_CURSOR_NULL             =   0x00

; フラグ
MESSAGE_FLAG_NULL               =   0x00
MESSAGE_FLAG_CENTERING_BIT      =   0x00
MESSAGE_FLAG_CENTERING          =   (1 << MESSAGE_FLAG_CENTERING_BIT)

; フレーム
MESSAGE_FRAME_NULL              =   0x00
MESSAGE_FRAME_TEXT              =   0x02
MESSAGE_FRAME_BLINK             =   0x08
MESSAGE_FRAME_DONE              =   0x50

; カウント
MESSAGE_COUNT_NULL              =   0x00

; 外部関数宣言
;

    .globl  _MessageInitialize
    .globl  _MessageStart
    .globl  _MessageStartCentering
    .globl  _MessagePrint
    .globl  _MessageIsDone

; 外部変数宣言
;

    .globl  _message
