; Sound.inc : サウンド
;


; マクロの定義
;

; SE
SOUND_SE_NULL                   =   0x00
SOUND_SE_BOOT                   =   0x01
SOUND_SE_CLICK                  =   0x02
SOUND_SE_BOMB                   =   0x03
SOUND_SE_BULLET                 =   0x04
SOUND_SE_WALK                   =   0x05
SOUND_SE_LAND                   =   0x06
SOUND_SE_SIT                    =   0x07
SOUND_SE_BEAM                   =   0x08

; 外部関数宣言
;

    .globl  _SoundPlaySeA
    .globl  _SoundPlaySeB
    .globl  _SoundPlaySeC
    .globl  _SoundStop

; 外部変数宣言
;
