; App.inc : アプリケーション
;


; マクロの定義
;

; ビデオ
APP_COLOR_TABLE_NORMAL          =   0x2000
APP_COLOR_TABLE_REVERSE         =   0x2040
APP_PATTERN_NAME_TABLE          =   0x2800
APP_PATTERN_GENERATOR_TABLE     =   0x0000
APP_SPRITE_ATTRIBUTE_TABLE      =   0x1b00
APP_SPRITE_GENERATOR_TABLE      =   0x3800

; アプリケーション
APP_STATE                       =   0x00
APP_FRAME                       =   0x01
APP_LENGTH                      =   0x02

; 状態
APP_STATE_NULL                  =   0x00
APP_STATE_TITLE_INITIALIZE      =   0x01
APP_STATE_TITLE_UPDATE          =   0x02
APP_STATE_GAME_INITIALIZE       =   0x03
APP_STATE_GAME_UPDATE           =   0x04

; フレーム
APP_FRAME_NULL                  =   0x00

; ビュー
APP_VIEW_X                      =   0x00
APP_VIEW_Y                      =   0x05
APP_VIEW_PIXEL                  =   0x08
APP_VIEW_SIZE_X                 =   0x20
APP_VIEW_SIZE_Y                 =   0x0c

; パターンネーム
APP_PATTERN_NAME_BLANK          =   0x87


; 外部関数宣言
;

    .globl  _AppInitialize
    .globl  _AppUpdate
    .globl  _AppTransfer
    .globl  _AppNull

; 外部変数宣言
;

; 状態
    .globl  _app
    