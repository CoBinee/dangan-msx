; Sound.s : サウンド
;


; モジュール宣言
;
    .module Sound

; 参照ファイル
;
    .include    "bios.inc"
    .include    "System.inc"
    .include	"Sound.inc"

; 外部変数宣言
;

; マクロの定義
;


; CODE 領域
;
    .area   _CODE

; SE を再生する
;
SoundPlaySe:

    ; レジスタの保存
    push    de

    ; hl < チャンネル
    ; a  < SE

    ; サウンドの再生
    push    hl
    add     a, a
    ld      e, a
    ld      d, #0x00
    ld      hl, #soundSe
    add     hl, de
    ld      e, (hl)
    inc     hl
    ld      d, (hl)
;   inc     hl
    pop     hl
    ld      (hl), e
    inc     hl
    ld      (hl), d
    dec     hl

    ; レジスタの復帰
    pop     de

    ; 終了
    ret

_SoundPlaySeA::

    ; レジスタの保存
    push    hl

    ; a  < SE

    ; サウンドの再生
    ld      hl, #(_soundChannel + SOUND_CHANNEL_A + SOUND_CHANNEL_REQUEST)
    call    SoundPlaySe

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

_SoundPlaySeB::

    ; レジスタの保存
    push    hl

    ; a  < SE

    ; サウンドの再生
    ld      hl, #(_soundChannel + SOUND_CHANNEL_B + SOUND_CHANNEL_REQUEST)
    call    SoundPlaySe

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

_SoundPlaySeC::

    ; レジスタの保存
    push    hl

    ; a  < SE

    ; サウンドの再生
    ld      hl, #(_soundChannel + SOUND_CHANNEL_C + SOUND_CHANNEL_REQUEST)
    call    SoundPlaySe

    ; レジスタの復帰
    pop     hl

    ; 終了
    ret

; サウンドを停止する
;
_SoundStop::

    ; レジスタの保存

    ; サウンドの停止
    call    _SystemStopSound

    ; レジスタの復帰

    ; 終了
    ret

; 定数の定義
;

; 共通
;
soundNull:

    .ascii  "T1@0"
    .db     0x00

; SE
;
soundSe:

    .dw     soundNull
    .dw     soundSeBoot
    .dw     soundSeClick
    .dw     soundSeBomb
    .dw     soundSeBullet
    .dw     soundSeWalk
    .dw     soundSeLand
    .dw     soundSeSit
    .dw     soundSeBeam

; ブート
soundSeBoot:

    .ascii  "T2V15L3O6BO5BR9"
    .db     0x00

; クリック
soundSeClick:

    .ascii  "T2V135O4B0"
    .db     0x00

; 爆発
soundSeBomb:

;   .ascii  "T1V13L0O4GO3D-O4EO3D-O4CO3D-O3GO3D-O3EO3D-O3CO3D-O2GO3D-O2EO3D-"
;   .ascii  "O3CO2D-O3D-O2CO3CO2D-O3D-O2C"
;   .ascii  "O3CO2D-O3D-O2CO3CO2D-O3D-O2C"
    .ascii  "T3V13,8O1C9"
    .db     0x00

; 銃弾
soundSeBullet:

;   .ascii  "T1V13O2A1"
    .ascii  "T1V11O1C1"
    .db     0x00

; 歩行
soundSeWalk:

    .ascii  "T3V9,5O1C9"
    .db     0x00

; 着地
soundSeLand:

    .ascii  "T3V9,3O1C9"
    .db     0x00

; しゃがむ
soundSeSit:

    .ascii  "T3V9,3O1C9"
    .db     0x00

; ビーム
soundSeBeam:

    .ascii  "T1V13L0O2GO6C+O2G+O5G+O2AO5D+O2AO5D+O2AO5D+O2AO5D+"
    .db     0x00


; DATA 領域
;
    .area   _DATA

; 変数の定義
;
