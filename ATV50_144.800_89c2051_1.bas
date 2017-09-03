' Program do testow nadajnika ATV50 Gorke
' PLL - MB1502
' w oryginalnym ukladzie byl ATMEGA 8
' do testow uzyty zostal 89C2051
' Czestotliwosc REF: 12.8 MHz , krok syntezy: 12.5kHz , czestotliwosc nadajnika: 144.800 MHz
' http://sq5eku.blogspot.com

$regfile = "89c2051.dat"
$crystal = 11059000                                           ' zegar 11.059 MHz

Dim Tmp As Bit                                                ' odcinanie nadawania po jednej rundzie
Dim C As Byte
Dim A As Byte


Ld Alias P1.0                                                 ' pin 12 Lock Detect MB1502 H=brak synchro L=synchro OK
Led Alias P3.0                                                ' pin 2  LED PTT H=zgaszona , L=swieci
Drv Alias P3.1                                                ' pin 3  VCC +9V wzmacniacze w.cz. , H=wylaczone , L=wlaczone
Vco Alias P3.2                                                ' pin 6  VCC +8V VCO i PLL , H=wylaczone , L=zalaczone
Ptt Alias P3.3                                                ' pin 7  PTT , H=wylaczone , L=zalaczone
Le Alias P3.4                                                 ' pin 8  MB1502 pin 11 (LE)
Clk Alias P3.5                                                ' pin 9  MB1502 pin 9 (CLOCK)
Data Alias P3.7                                               ' pin 11 MB1502 pin 10 (DATA)

Declare Sub Mb_r
Declare Sub Mb_na
Declare Sub Zegarek1
Declare Sub Zegarek2
Declare Sub Le_pulse

Ld = 1
Led = 1
Drv = 1
Vco = 1
Ptt = 1
Tmp = 1
Le = 0
Clk = 0
Reset Data


'-------------------------------------------------------------  glowna petla
Do
If Tmp = 0 Then
 If Ptt = 0 Then                                              ' jesli PTT wlaczone idz dalej
  Vco = 0                                                     ' wlacz zasilanie VCO i PLL
  Waitms 10                                                   ' czekaj 10 ms az zalapie VCO
  Gosub Mb_r
  Delay
  Gosub Mb_na
  Waitms 50                                                   ' odczekaj 50ms na synchro PLL
   If Ld = 0 Then
    Drv = 0                                                   ' wlacz zasilanie wzmacniaczy w.cz.
    Led = 0                                                   ' wlacz LED PTT
    Tmp = 1
   End If
 End If
End If
If Tmp = 1 Then
 If Ptt = 1 Then
  Vco = 1                                                     ' wylacz zasilanie VCO i PLL
  Drv = 1                                                     ' wylacz zasilanie wzmaniaczy w.cz
  Led = 1                                                     ' wylacz LED PTT
  Tmp = 0
 End If
End If

Loop
End

'-------------------------------------------------------------  koniec glownej petli programu

Mb_r:
 Restore Dat
 For A = 1 To 16
 Read C
  If C = 1 Then
   Gosub Zegarek1
  Else
   Gosub Zegarek2
  End If
 Next A
 Gosub Le_pulse
Return

Mb_na:
 Restore Dat1
 For A = 1 To 19
 Read C
  If C = 1 Then
   Gosub Zegarek1
  Else
   Gosub Zegarek2
  End If
 Next A
 Gosub Le_pulse
Return

Zegarek1:
 Set Data
 nop
 Set Clk
 nop
 Reset Clk
 nop
 Reset Data
Return

Zegarek2:
 Set Clk
 nop
 Reset Clk
 nop
Return

Le_pulse:
 nop
 Set Le
 nop
 Reset Le
 nop
 Reset Data
Return


Dat:
'
' 1 bitowy SW = 1 , 14 bitowy dzielnik R = 1024 , 1 bitowy adres = 1:
'   |SW| |------------------------R---------------------------| |adr|
Data 1 , 0 , 0 , 0 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 1       ' Zamieniamy miejscami SW / R / adr
'
'
Dat1:
'
' 11 bitowy dzielnik N = 181 , 7 bitowy dzielnik A = 0 , 1 bitowy adres = 0
'    |--------------------N------------------|   |-----------A-----------|  |adr|
Data 0 , 0 , 0 , 1 , 0 , 1 , 1 , 0 , 1 , 0 , 1 , 0 , 0 , 0 , 0 , 0 , 0 , 0 , 0       ' Zamieniamy miejscami N / A / adr