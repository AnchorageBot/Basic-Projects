' ============================================================
'  CATCH!  -  a minimal arcade skeleton for PicoCalc / PicoMite
'  Move the paddle, catch the falling blocks. Miss 3 and it's over.
'
'  Language : PicoMite MMBasic (RP2040 or RP2350)
'  Controls : Left / Right arrows  (or A / D)   Q = quit
'
'  This is a SKELETON. The four pieces you asked for are marked:
'    [PLAYER]  [INPUT]  [COLLISION]  [SCORE]
'  Everything else is scaffolding to hang your own ideas on.
' ============================================================

Option Explicit
Option Default None

' ---- screen (auto-fits whatever panel your PicoCalc reports) ----
Dim integer SW = MM.HRES
Dim integer SH = MM.VRES

' ---- colours ----
Dim integer CBG   = RGB(black)
Dim integer CPLR  = RGB(cyan)
Dim integer CDROP = RGB(yellow)
Dim integer CTXT  = RGB(white)

' ---- [PLAYER] paddle ----
Dim integer PW = 44, PH = 8       ' paddle width / height
Dim integer PX, PY                ' paddle position (top-left)
Dim integer PSPD = 8              ' pixels moved per key press

' ---- falling block ----
Dim integer DX, DY                ' block position (top-left)
Dim integer DS                    ' fall speed (pixels/frame)
Dim integer DSIZE = 12            ' block is a DSIZE x DSIZE square

' ---- game state ----
Dim integer score, lives, playing

' ---- key codes (PicoMite arrow keys; adjust if your keyboard differs)
Const KLEFT  = 130
Const KRIGHT = 131

Randomize Timer
Init_Game

' ---- main loop: input -> update -> draw -> wait -----------------
Do While playing
  Handle_Input
  Update_Faller
  Draw_Frame
  Pause 30                        ' ~33 frames/second
Loop

Game_Over_Screen
End

' ================= subroutines =================

Sub Init_Game
  score = 0 : lives = 3 : playing = 1
  PX = (SW - PW) \ 2
  PY = SH - PH - 6
  Spawn_Faller
  CLS CBG
End Sub

Sub Spawn_Faller
  DX = Int(Rnd * (SW - DSIZE))    ' random x across the screen
  DY = 0
  DS = 4 + Int(Rnd * 4)          ' random fall speed 4..7
End Sub

' ---- [INPUT] read one key, move & clamp the paddle ----
Sub Handle_Input
  Local a$
  a$ = Inkey$
  If a$ <> "" Then
    Select Case Asc(a$)
      Case KLEFT,  Asc("a"), Asc("A") : PX = PX - PSPD
      Case KRIGHT, Asc("d"), Asc("D") : PX = PX + PSPD
      Case Asc("q"), Asc("Q")         : playing = 0
    End Select
  End If
  If PX < 0        Then PX = 0
  If PX > SW - PW  Then PX = SW - PW
End Sub

' ---- [COLLISION] fall, test catch, test floor ----
Sub Update_Faller
  DY = DY + DS
  ' is the block overlapping the paddle's vertical band?
  If DY + DSIZE >= PY And DY <= PY + PH Then
    ' ...and overlapping horizontally? -> caught
    If DX + DSIZE >= PX And DX <= PX + PW Then
      score = score + 1           ' [SCORE]
      Spawn_Faller
      Exit Sub
    End If
  End If
  ' hit the floor uncaught -> lose a life
  If DY > SH Then
    lives = lives - 1
    If lives <= 0 Then playing = 0 Else Spawn_Faller
  End If
End Sub

Sub Draw_Frame
  CLS CBG
  Box PX, PY, PW, PH, 1, CPLR, CPLR        ' [PLAYER] paddle
  Box DX, DY, DSIZE, DSIZE, 1, CDROP, CDROP ' falling block
  Text 2,    2, "SCORE " + Str$(score), "LT", 1, 1, CTXT, CBG  ' [SCORE]
  Text SW-2, 2, "LIVES " + Str$(lives), "RT", 1, 1, CTXT, CBG
End Sub

Sub Game_Over_Screen
  CLS CBG
  Text SW\2, SH\2 - 12, "GAME OVER",            "CM", 1, 2, RGB(red), CBG
  Text SW\2, SH\2 + 12, "Score " + Str$(score), "CM", 1, 1, CTXT, CBG
  Text SW\2, SH\2 + 32, "Press any key",        "CM", 1, 1, CTXT, CBG
  Do While Inkey$ = "" : Loop
End Sub
