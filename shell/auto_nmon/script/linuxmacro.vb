Sub Macro1()
'
' Macro1 Macro
'

'
    Sheets("CPU_ALL").Select
    ActiveWindow.SmallScroll Down:=-8
    ActiveSheet.ChartObjects("Chart 1").Activate
    ActiveSheet.Shapes("Chart 1").IncrementLeft -6
    ActiveSheet.Shapes("Chart 1").IncrementTop 48.75
    Range("A1444").Select
    ActiveCell.FormulaR1C1 = "Max"
    Range("J1444").Select
    ActiveCell.FormulaR1C1 = "=MAX(R[-1442]C:R[-3]C)"
    Range("J1445").Select
    ActiveWindow.TabRatio = 0.872
    Sheets("DISKBUSY").Select
    ActiveWindow.SmallScroll Down:=-16
    Range("A1444").Select
    Selection.ClearContents
    ActiveSheet.ChartObjects("Chart 1").Activate
    ActiveSheet.Shapes("Chart 1").IncrementLeft 3
    ActiveSheet.Shapes("Chart 1").IncrementTop 70.5
    Range("B1445").Select
    ActiveCell.FormulaR1C1 = "=MAX(R[-1443]C:R[-4]C)"
    Range("B1445").Select
    Selection.AutoFill Destination:=Range("B1445:X1445"), Type:=xlFillDefault
    Range("B1445:X1445").Select
    ActiveWindow.ScrollColumn = 4
    ActiveWindow.ScrollColumn = 18
    ActiveWindow.ScrollColumn = 29
    ActiveWindow.ScrollColumn = 33
    ActiveWindow.ScrollColumn = 36
    ActiveWindow.ScrollColumn = 39
    ActiveWindow.ScrollColumn = 41
    ActiveWindow.ScrollColumn = 44
    ActiveWindow.ScrollColumn = 46
    ActiveWindow.ScrollColumn = 47
    ActiveWindow.ScrollColumn = 50
    ActiveWindow.ScrollColumn = 52
    ActiveWindow.ScrollColumn = 54
    ActiveWindow.ScrollColumn = 55
    ActiveWindow.ScrollColumn = 57
    ActiveWindow.ScrollColumn = 58
    ActiveWindow.ScrollColumn = 60
    ActiveWindow.ScrollColumn = 62
    ActiveWindow.ScrollColumn = 65
    ActiveWindow.ScrollColumn = 66
    ActiveWindow.ScrollColumn = 68
    ActiveWindow.ScrollColumn = 70
    ActiveWindow.ScrollColumn = 71
    ActiveWindow.ScrollColumn = 73
    ActiveWindow.ScrollColumn = 75
    ActiveWindow.ScrollColumn = 78
    ActiveWindow.ScrollColumn = 79
    ActiveWindow.ScrollColumn = 81
    ActiveWindow.ScrollColumn = 84
    ActiveWindow.ScrollColumn = 86
    ActiveWindow.ScrollColumn = 87
    ActiveWindow.ScrollColumn = 89
    ActiveWindow.ScrollColumn = 91
    ActiveWindow.ScrollColumn = 92
    ActiveWindow.ScrollColumn = 95
    ActiveWindow.ScrollColumn = 97
    ActiveWindow.ScrollColumn = 99
    ActiveWindow.ScrollColumn = 100
    ActiveWindow.ScrollColumn = 102
    ActiveWindow.ScrollColumn = 104
    ActiveWindow.ScrollColumn = 105
    ActiveWindow.ScrollColumn = 107
    ActiveWindow.ScrollColumn = 108
    ActiveWindow.ScrollColumn = 110
    ActiveWindow.ScrollColumn = 112
    ActiveWindow.ScrollColumn = 113
    ActiveWindow.ScrollColumn = 115
    ActiveWindow.ScrollColumn = 116
    ActiveWindow.ScrollColumn = 118
    ActiveWindow.ScrollColumn = 120
    ActiveWindow.ScrollColumn = 121
    ActiveWindow.ScrollColumn = 123
    ActiveWindow.ScrollColumn = 124
    ActiveWindow.ScrollColumn = 126
    ActiveWindow.ScrollColumn = 128
    ActiveWindow.ScrollColumn = 129
    ActiveWindow.ScrollColumn = 131
    ActiveWindow.ScrollColumn = 133
    ActiveWindow.ScrollColumn = 136
    ActiveWindow.ScrollColumn = 137
    ActiveWindow.ScrollColumn = 139
    ActiveWindow.ScrollColumn = 141
    ActiveWindow.ScrollColumn = 142
    ActiveWindow.ScrollColumn = 144
    ActiveWindow.ScrollColumn = 145
    ActiveWindow.ScrollColumn = 147
    ActiveWindow.ScrollColumn = 149
    ActiveWindow.ScrollColumn = 150
    ActiveWindow.ScrollColumn = 152
    ActiveWindow.ScrollColumn = 153
    ActiveWindow.ScrollColumn = 155
    ActiveWindow.ScrollColumn = 157
    ActiveWindow.ScrollColumn = 158
    ActiveWindow.ScrollColumn = 160
    ActiveWindow.ScrollColumn = 163
    ActiveWindow.ScrollColumn = 166
    ActiveWindow.ScrollColumn = 168
    ActiveWindow.ScrollColumn = 171
    ActiveWindow.ScrollColumn = 173
    ActiveWindow.ScrollColumn = 174
    ActiveWindow.ScrollColumn = 176
    ActiveWindow.ScrollColumn = 178
    ActiveWindow.ScrollColumn = 179
    ActiveWindow.ScrollColumn = 181
    ActiveWindow.ScrollColumn = 182
    ActiveWindow.ScrollColumn = 184
    ActiveWindow.ScrollColumn = 186
    ActiveWindow.ScrollColumn = 187
    ActiveWindow.ScrollColumn = 189
    ActiveWindow.ScrollColumn = 191
    ActiveWindow.ScrollColumn = 192
    ActiveWindow.ScrollColumn = 194
    ActiveWindow.ScrollColumn = 195
    ActiveWindow.ScrollColumn = 197
    ActiveWindow.ScrollColumn = 195
    ActiveWindow.ScrollColumn = 192
    ActiveWindow.ScrollColumn = 191
    ActiveWindow.ScrollColumn = 189
    ActiveWindow.ScrollColumn = 187
    ActiveWindow.ScrollColumn = 186
    ActiveWindow.ScrollColumn = 184
    ActiveWindow.ScrollColumn = 182
    ActiveWindow.ScrollColumn = 181
    ActiveWindow.ScrollColumn = 179
    ActiveWindow.ScrollColumn = 178
    ActiveWindow.ScrollColumn = 176
    ActiveWindow.ScrollColumn = 174
    ActiveWindow.ScrollColumn = 173
    ActiveWindow.ScrollColumn = 171
    ActiveWindow.ScrollColumn = 170
    ActiveWindow.ScrollColumn = 168
    ActiveWindow.ScrollColumn = 166
    ActiveWindow.ScrollColumn = 165
    Range("FZ1443").Select
    ActiveCell.FormulaR1C1 = "=AVERAGE(RC[-180]:RC[-1])"
    Range("FZ1445").Select
    ActiveCell.FormulaR1C1 = "=MAX(RC[-180]:RC[-1])"
    Range("FZ1446").Select
    Sheets("MEM").Select
    Sheets("MEM").Name = "MEM"
    ActiveSheet.ChartObjects("Chart 1").Activate
    ActiveChart.Axes(xlValue).MajorGridlines.Select
    ActiveWindow.SmallScroll Down:=-24
    ActiveWindow.LargeScroll Down:=-15
    ActiveWindow.ScrollRow = 938
    ActiveWindow.ScrollRow = 936
    ActiveWindow.ScrollRow = 934
    ActiveWindow.ScrollRow = 932
    ActiveWindow.ScrollRow = 925
    ActiveWindow.ScrollRow = 918
    ActiveWindow.ScrollRow = 909
    ActiveWindow.ScrollRow = 902
    ActiveWindow.ScrollRow = 886
    ActiveWindow.ScrollRow = 872
    ActiveWindow.ScrollRow = 863
    ActiveWindow.ScrollRow = 852
    ActiveWindow.ScrollRow = 831
    ActiveWindow.ScrollRow = 813
    ActiveWindow.ScrollRow = 795
    ActiveWindow.ScrollRow = 777
    ActiveWindow.ScrollRow = 754
    ActiveWindow.ScrollRow = 729
    ActiveWindow.ScrollRow = 704
    ActiveWindow.ScrollRow = 679
    ActiveWindow.ScrollRow = 656
    ActiveWindow.ScrollRow = 631
    ActiveWindow.ScrollRow = 606
    ActiveWindow.ScrollRow = 581
    ActiveWindow.ScrollRow = 556
    ActiveWindow.ScrollRow = 533
    ActiveWindow.ScrollRow = 515
    ActiveWindow.ScrollRow = 494
    ActiveWindow.ScrollRow = 474
    ActiveWindow.ScrollRow = 453
    ActiveWindow.ScrollRow = 435
    ActiveWindow.ScrollRow = 414
    ActiveWindow.ScrollRow = 396
    ActiveWindow.ScrollRow = 385
    ActiveWindow.ScrollRow = 369
    ActiveWindow.ScrollRow = 353
    ActiveWindow.ScrollRow = 344
    ActiveWindow.ScrollRow = 332
    ActiveWindow.ScrollRow = 323
    ActiveWindow.ScrollRow = 312
    ActiveWindow.ScrollRow = 305
    ActiveWindow.ScrollRow = 296
    ActiveWindow.ScrollRow = 284
    ActiveWindow.ScrollRow = 275
    ActiveWindow.ScrollRow = 269
    ActiveWindow.ScrollRow = 262
    ActiveWindow.ScrollRow = 255
    ActiveWindow.ScrollRow = 250
    ActiveWindow.ScrollRow = 243
    ActiveWindow.ScrollRow = 237
    ActiveWindow.ScrollRow = 223
    ActiveWindow.ScrollRow = 214
    ActiveWindow.ScrollRow = 205
    ActiveWindow.ScrollRow = 196
    ActiveWindow.ScrollRow = 189
    ActiveWindow.ScrollRow = 180
    ActiveWindow.ScrollRow = 173
    ActiveWindow.ScrollRow = 166
    ActiveWindow.ScrollRow = 159
    ActiveWindow.ScrollRow = 155
    ActiveWindow.ScrollRow = 148
    ActiveWindow.ScrollRow = 143
    ActiveWindow.ScrollRow = 139
    ActiveWindow.ScrollRow = 134
    ActiveWindow.ScrollRow = 130
    ActiveWindow.ScrollRow = 123
    ActiveWindow.ScrollRow = 118
    ActiveWindow.ScrollRow = 116
    ActiveWindow.ScrollRow = 111
    ActiveWindow.ScrollRow = 107
    ActiveWindow.ScrollRow = 102
    ActiveWindow.ScrollRow = 100
    ActiveWindow.ScrollRow = 95
    ActiveWindow.ScrollRow = 93
    ActiveWindow.ScrollRow = 89
    ActiveWindow.ScrollRow = 86
    ActiveWindow.ScrollRow = 84
    ActiveWindow.ScrollRow = 79
    ActiveWindow.ScrollRow = 75
    ActiveWindow.ScrollRow = 70
    ActiveWindow.ScrollRow = 64
    ActiveWindow.ScrollRow = 61
    ActiveWindow.ScrollRow = 59
    ActiveWindow.ScrollRow = 57
    ActiveWindow.ScrollRow = 52
    ActiveWindow.ScrollRow = 48
    ActiveWindow.ScrollRow = 45
    ActiveWindow.ScrollRow = 43
    ActiveWindow.ScrollRow = 41
    ActiveWindow.ScrollRow = 38
    ActiveWindow.ScrollRow = 36
    ActiveWindow.ScrollRow = 34
    ActiveWindow.ScrollRow = 32
    ActiveWindow.ScrollRow = 29
    ActiveWindow.ScrollRow = 27
    ActiveWindow.ScrollRow = 25
    ActiveWindow.ScrollRow = 23
    ActiveWindow.ScrollRow = 20
    ActiveWindow.ScrollRow = 18
    ActiveWindow.ScrollRow = 16
    ActiveWindow.ScrollRow = 13
    ActiveWindow.ScrollRow = 11
    ActiveWindow.ScrollRow = 9
    ActiveWindow.ScrollRow = 7
    ActiveWindow.ScrollRow = 4
    ActiveWindow.ScrollRow = 2
    Range("Q2").Select
    ActiveCell.FormulaR1C1 = "=(RC[-15]-RC[-11]-RC[-6]-RC[-3])/RC[-15]*100"
    Range("Q2").Select
    Selection.AutoFill Destination:=Range("Q2:Q1441"), Type:=xlFillDefault
    Range("Q2:Q1441").Select
    Range("S1438").Select
    ActiveWindow.SmallScroll Down:=16
    ActiveSheet.ChartObjects("Chart 1").Activate
    ActiveSheet.Shapes("Chart 1").IncrementLeft 8.25
    ActiveSheet.Shapes("Chart 1").IncrementTop 50.25
    Range("P1442").Select
    ActiveCell.FormulaR1C1 = "Avg"
    Range("Q1442").Select
    ActiveCell.FormulaR1C1 = "=AVERAGE(R[-1440]C:R[-1]C)"
    Range("P1443").Select
    ActiveCell.FormulaR1C1 = "Max"
    Range("Q1443").Select
    ActiveCell.FormulaR1C1 = "=MAX(R[-1441]C:R[-2]C)"
    Range("Q1444").Select
    ActiveWorkbook.Save
    ActiveWorkbook.Close
End Sub
