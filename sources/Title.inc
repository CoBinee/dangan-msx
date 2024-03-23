; Title.inc : タイトル
;


; マクロの定義
;

; スプライト
TITLE_SPRITE_NULL               =   0x00

; タイトル
TITLE_PROC_L                    =   0x00
TITLE_PROC_H                    =   0x01
TITLE_STATE                     =   0x02
TITLE_FLAG                      =   0x03
TITLE_ANIMATION_L               =   0x04
TITLE_ANIMATION_H               =   0x05
TITLE_ANIMATION_FRAME           =   0x06
TITLE_LOGO                      =   0x07
TITLE_FRAME                     =   0x08
TITLE_LENGTH                    =   0x09

; 処理
TITLE_PROC_NULL                 =   0x00

; 状態
TITLE_STATE_NULL                =   0x00
TITLE_STATE_IDLE                =   0x10
TITLE_STATE_START               =   0x20

; フラグ
TITLE_FLAG_NULL                 =   0x00

; アニメーション
TITLE_ANIMATION_NULL            =   0x00
TITLE_ANIMATION_INTERVAL        =   0x00
TITLE_ANIMATION_X               =   0x01
TITLE_ANIMATION_PATTERN         =   0x02
TITLE_ANIMATION_MASK            =   0x03
TITLE_ANIMATION_SOUND           =   0x04
TITLE_ANIMATION_LENGTH          =   0x05

; ロゴ
TITLE_LOGO_NULL                 =   0x00
TITLE_LOGO_LENGTH               =   0x0e

; フレーム
TITLE_FRAME_NULL                =   0x00
TITLE_FRAME_START               =   0x18

; デモ
TITLE_DEMO_NULL                 =   0x00
TITLE_DEMO_X                    =   APP_VIEW_X
TITLE_DEMO_Y                    =   APP_VIEW_Y + 0x02
TITLE_DEMO_SIZE_X               =   APP_VIEW_SIZE_X
TITLE_DEMO_SIZE_Y               =   0x08
TITLE_DEMO_PATTERN_NAME_BACK    =   0x70
TITLE_DEMO_PATTERN_NAME_FRONT   =   0x87

; 外部関数宣言
;

    .globl  _TitleInitialize
    .globl  _TitleUpdate
    
; 外部変数宣言
;

    .globl  _title
