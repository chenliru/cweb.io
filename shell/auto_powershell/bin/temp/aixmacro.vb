
Sub Macro1()
'
' Macro1 Macro
'

'
    Sheets("LPAR").Select
    ActiveWindow.SmallScroll Down:=-12
    Range("A722").Select
    ActiveCell.FormulaR1C1 = "Avg"
    Range("B722").Select
    ActiveCell.FormulaR1C1 = "=AVERAGE(R[-720]C:R[-1]C)"
    Range("A723").Select
    ActiveCell.FormulaR1C1 = "Max"
    Range("B723").Select
    ActiveCell.FormulaR1C1 = "=MAX(R[-721]C:R[-2]C)"
    Range("B724").Select
    ActiveWindow.TabRatio = 0.93
    Sheets("DISKBUSY").Select
    ActiveWindow.SmallScroll Down:=-12
    Range("A724").Select
    Selection.ClearContents
    Range("B725").Select
    ActiveCell.FormulaR1C1 = "=MAX(R[-723]C:R[-4]C)"
    Range("B726").Select
    ActiveWindow.ScrollColumn = 6
    ActiveWindow.ScrollColumn = 11
    ActiveWindow.ScrollColumn = 15
    ActiveWindow.ScrollColumn = 20
    ActiveWindow.ScrollColumn = 24
    ActiveWindow.ScrollColumn = 29
    ActiveWindow.ScrollColumn = 33
    ActiveWindow.ScrollColumn = 38
    ActiveWindow.ScrollColumn = 42
    ActiveWindow.ScrollColumn = 47
    ActiveWindow.ScrollColumn = 51
    ActiveWindow.ScrollColumn = 56
    ActiveWindow.ScrollColumn = 60
    ActiveWindow.ScrollColumn = 64
    ActiveWindow.ScrollColumn = 69
    ActiveWindow.ScrollColumn = 73
    ActiveWindow.ScrollColumn = 78
    ActiveWindow.ScrollColumn = 82
    ActiveWindow.ScrollColumn = 87
    ActiveWindow.ScrollColumn = 91
    ActiveWindow.ScrollColumn = 96
    ActiveWindow.ScrollColumn = 100
    ActiveWindow.ScrollColumn = 105
    ActiveWindow.ScrollColumn = 109
    ActiveWindow.ScrollColumn = 114
    ActiveWindow.ScrollColumn = 118
    ActiveWindow.ScrollColumn = 122
    ActiveWindow.ScrollColumn = 127
    ActiveWindow.ScrollColumn = 131
    ActiveWindow.ScrollColumn = 136
    ActiveWindow.ScrollColumn = 140
    ActiveWindow.ScrollColumn = 145
    ActiveWindow.ScrollColumn = 149
    ActiveWindow.ScrollColumn = 154
    ActiveWindow.ScrollColumn = 158
    ActiveWindow.ScrollColumn = 163
    ActiveWindow.ScrollColumn = 167
    ActiveWindow.ScrollColumn = 172
    Range("FZ723").Select
    ActiveCell.FormulaR1C1 = "=AVERAGE(RC[-180]:RC[-1])"
    Range("FZ725").Select
    ActiveCell.FormulaR1C1 = "=MAX(RC[-180]:RC[-1])"
    Range("FZ726").Select
    ActiveWindow.ScrollColumn = 167
    ActiveWindow.ScrollColumn = 163
    ActiveWindow.ScrollColumn = 158
    ActiveWindow.ScrollColumn = 154
    ActiveWindow.ScrollColumn = 149
    ActiveWindow.ScrollColumn = 140
    ActiveWindow.ScrollColumn = 136
    ActiveWindow.ScrollColumn = 131
    ActiveWindow.ScrollColumn = 127
    ActiveWindow.ScrollColumn = 122
    ActiveWindow.ScrollColumn = 118
    ActiveWindow.ScrollColumn = 114
    ActiveWindow.ScrollColumn = 109
    ActiveWindow.ScrollColumn = 105
    ActiveWindow.ScrollColumn = 100
    ActiveWindow.ScrollColumn = 96
    ActiveWindow.ScrollColumn = 91
    ActiveWindow.ScrollColumn = 87
    ActiveWindow.ScrollColumn = 82
    ActiveWindow.ScrollColumn = 78
    ActiveWindow.ScrollColumn = 73
    ActiveWindow.ScrollColumn = 69
    ActiveWindow.ScrollColumn = 64
    ActiveWindow.ScrollColumn = 60
    ActiveWindow.ScrollColumn = 56
    ActiveWindow.ScrollColumn = 51
    ActiveWindow.ScrollColumn = 47
    ActiveWindow.ScrollColumn = 42
    ActiveWindow.ScrollColumn = 38
    ActiveWindow.ScrollColumn = 33
    ActiveWindow.ScrollColumn = 29
    ActiveWindow.ScrollColumn = 24
    ActiveWindow.ScrollColumn = 20
    ActiveWindow.ScrollColumn = 15
    ActiveWindow.ScrollColumn = 11
    ActiveWindow.ScrollColumn = 6
    ActiveWindow.ScrollColumn = 2
    ActiveSheet.ChartObjects("Chart 1").Activate
    ActiveSheet.Shapes("Chart 1").IncrementLeft 6
    ActiveSheet.Shapes("Chart 1").IncrementTop 76.5
    Range("B725").Select
    Selection.AutoFill Destination:=Range("B725:P725"), Type:=xlFillDefault
    Range("B725:P725").Select
    ActiveWindow.ScrollColumn = 6
    ActiveWindow.ScrollColumn = 11
    ActiveWindow.ScrollColumn = 20
    ActiveWindow.ScrollColumn = 24
    ActiveWindow.ScrollColumn = 33
    ActiveWindow.ScrollColumn = 38
    ActiveWindow.ScrollColumn = 42
    ActiveWindow.ScrollColumn = 47
    ActiveWindow.ScrollColumn = 51
    ActiveWindow.ScrollColumn = 56
    ActiveWindow.ScrollColumn = 60
    ActiveWindow.ScrollColumn = 64
    ActiveWindow.ScrollColumn = 69
    ActiveWindow.ScrollColumn = 73
    ActiveWindow.ScrollColumn = 78
    ActiveWindow.ScrollColumn = 82
    ActiveWindow.ScrollColumn = 87
    ActiveWindow.ScrollColumn = 91
    ActiveWindow.ScrollColumn = 96
    ActiveWindow.ScrollColumn = 100
    ActiveWindow.ScrollColumn = 105
    ActiveWindow.ScrollColumn = 109
    ActiveWindow.ScrollColumn = 114
    ActiveWindow.ScrollColumn = 118
    ActiveWindow.ScrollColumn = 122
    ActiveWindow.ScrollColumn = 127
    ActiveWindow.ScrollColumn = 131
    ActiveWindow.ScrollColumn = 136
    ActiveWindow.ScrollColumn = 140
    ActiveWindow.ScrollColumn = 145
    ActiveWindow.ScrollColumn = 149
    ActiveWindow.ScrollColumn = 154
    ActiveWindow.ScrollColumn = 158
    ActiveWindow.ScrollColumn = 163
    ActiveWindow.ScrollColumn = 167
    ActiveWindow.ScrollColumn = 172
    ActiveWindow.ScrollColumn = 176
    ActiveWindow.ScrollColumn = 180
    ActiveWindow.ScrollColumn = 185
    ActiveWindow.ScrollColumn = 180
    ActiveWindow.ScrollColumn = 176
    ActiveWindow.ScrollColumn = 167
    ActiveWindow.ScrollColumn = 163
    ActiveWindow.ScrollColumn = 154
    ActiveWindow.ScrollColumn = 145
    ActiveWindow.ScrollColumn = 149
    ActiveWindow.ScrollColumn = 154
    ActiveWindow.ScrollColumn = 158
    ActiveWindow.ScrollColumn = 163
    ActiveWindow.ScrollColumn = 167
    ActiveWindow.ScrollColumn = 172
    Sheets("MEM").Select
    ActiveWindow.ScrollRow = 721
    ActiveWindow.ScrollRow = 720
    ActiveWindow.ScrollRow = 719
    ActiveWindow.ScrollRow = 718
    ActiveWindow.ScrollRow = 717
    ActiveWindow.ScrollRow = 716
    ActiveWindow.ScrollRow = 715
    ActiveSheet.ChartObjects("Chart 1").Activate
    ActiveSheet.Shapes("Chart 1").IncrementTop 30.75
    ActiveWindow.ScrollRow = 713
    ActiveWindow.ScrollRow = 683
    ActiveWindow.ScrollRow = 675
    ActiveWindow.ScrollRow = 669
    ActiveWindow.ScrollRow = 661
    ActiveWindow.ScrollRow = 653
    ActiveWindow.ScrollRow = 645
    ActiveWindow.ScrollRow = 636
    ActiveWindow.ScrollRow = 626
    ActiveWindow.ScrollRow = 617
    ActiveWindow.ScrollRow = 609
    ActiveWindow.ScrollRow = 599
    ActiveWindow.ScrollRow = 589
    ActiveWindow.ScrollRow = 580
    ActiveWindow.ScrollRow = 571
    ActiveWindow.ScrollRow = 563
    ActiveWindow.ScrollRow = 555
    ActiveWindow.ScrollRow = 549
    ActiveWindow.ScrollRow = 538
    ActiveWindow.ScrollRow = 530
    ActiveWindow.ScrollRow = 522
    ActiveWindow.ScrollRow = 513
    ActiveWindow.ScrollRow = 502
    ActiveWindow.ScrollRow = 492
    ActiveWindow.ScrollRow = 483
    ActiveWindow.ScrollRow = 472
    ActiveWindow.ScrollRow = 462
    ActiveWindow.ScrollRow = 453
    ActiveWindow.ScrollRow = 443
    ActiveWindow.ScrollRow = 431
    ActiveWindow.ScrollRow = 418
    ActiveWindow.ScrollRow = 404
    ActiveWindow.ScrollRow = 391
    ActiveWindow.ScrollRow = 379
    ActiveWindow.ScrollRow = 365
    ActiveWindow.ScrollRow = 352
    ActiveWindow.ScrollRow = 338
    ActiveWindow.ScrollRow = 325
    ActiveWindow.ScrollRow = 311
    ActiveWindow.ScrollRow = 297
    ActiveWindow.ScrollRow = 282
    ActiveWindow.ScrollRow = 270
    ActiveWindow.ScrollRow = 258
    ActiveWindow.ScrollRow = 245
    ActiveWindow.ScrollRow = 230
    ActiveWindow.ScrollRow = 220
    ActiveWindow.ScrollRow = 207
    ActiveWindow.ScrollRow = 195
    ActiveWindow.ScrollRow = 185
    ActiveWindow.ScrollRow = 175
    ActiveWindow.ScrollRow = 165
    ActiveWindow.ScrollRow = 156
    ActiveWindow.ScrollRow = 148
    ActiveWindow.ScrollRow = 140
    ActiveWindow.ScrollRow = 132
    ActiveWindow.ScrollRow = 124
    ActiveWindow.ScrollRow = 118
    ActiveWindow.ScrollRow = 111
    ActiveWindow.ScrollRow = 105
    ActiveWindow.ScrollRow = 100
    ActiveWindow.ScrollRow = 96
    ActiveWindow.ScrollRow = 91
    ActiveWindow.ScrollRow = 89
    ActiveWindow.ScrollRow = 85
    ActiveWindow.ScrollRow = 83
    ActiveWindow.ScrollRow = 81
    ActiveWindow.ScrollRow = 78
    ActiveWindow.ScrollRow = 77
    ActiveWindow.ScrollRow = 76
    ActiveWindow.ScrollRow = 75
    ActiveWindow.ScrollRow = 74
    ActiveWindow.ScrollRow = 73
    ActiveWindow.ScrollRow = 72
    ActiveWindow.ScrollRow = 70
    ActiveWindow.ScrollRow = 68
    ActiveWindow.ScrollRow = 66
    ActiveWindow.ScrollRow = 63
    ActiveWindow.ScrollRow = 61
    ActiveWindow.ScrollRow = 58
    ActiveWindow.ScrollRow = 55
    ActiveWindow.ScrollRow = 52
    ActiveWindow.ScrollRow = 48
    ActiveWindow.ScrollRow = 46
    ActiveWindow.ScrollRow = 41
    ActiveWindow.ScrollRow = 39
    ActiveWindow.ScrollRow = 34
    ActiveWindow.ScrollRow = 32
    ActiveWindow.ScrollRow = 29
    ActiveWindow.ScrollRow = 26
    ActiveWindow.ScrollRow = 23
    ActiveWindow.ScrollRow = 19
    ActiveWindow.ScrollRow = 17
    ActiveWindow.ScrollRow = 14
    ActiveWindow.ScrollRow = 11
    ActiveWindow.ScrollRow = 9
    ActiveWindow.ScrollRow = 7
    ActiveWindow.ScrollRow = 5
    ActiveWindow.ScrollRow = 3
    ActiveWindow.ScrollRow = 2
    Range("H2").Select
    ActiveCell.FormulaR1C1 = ""
    Range("L15").Select
    Sheets("MEMNEW").Select
    ActiveWindow.ScrollRow = 698
    ActiveWindow.ScrollRow = 697
    ActiveWindow.ScrollRow = 696
    ActiveWindow.ScrollRow = 693
    ActiveWindow.ScrollRow = 690
    ActiveWindow.ScrollRow = 688
    ActiveWindow.ScrollRow = 684
    ActiveWindow.ScrollRow = 681
    ActiveWindow.ScrollRow = 678
    ActiveWindow.ScrollRow = 673
    ActiveWindow.ScrollRow = 669
    ActiveWindow.ScrollRow = 662
    ActiveWindow.ScrollRow = 656
    ActiveWindow.ScrollRow = 650
    ActiveWindow.ScrollRow = 642
    ActiveWindow.ScrollRow = 637
    ActiveWindow.ScrollRow = 629
    ActiveWindow.ScrollRow = 623
    ActiveWindow.ScrollRow = 617
    ActiveWindow.ScrollRow = 609
    ActiveWindow.ScrollRow = 600
    ActiveWindow.ScrollRow = 592
    ActiveWindow.ScrollRow = 583
    ActiveWindow.ScrollRow = 573
    ActiveWindow.ScrollRow = 564
    ActiveWindow.ScrollRow = 555
    ActiveWindow.ScrollRow = 546
    ActiveWindow.ScrollRow = 536
    ActiveWindow.ScrollRow = 527
    ActiveWindow.ScrollRow = 518
    ActiveWindow.ScrollRow = 507
    ActiveWindow.ScrollRow = 498
    ActiveWindow.ScrollRow = 485
    ActiveWindow.ScrollRow = 473
    ActiveWindow.ScrollRow = 463
    ActiveWindow.ScrollRow = 451
    ActiveWindow.ScrollRow = 437
    ActiveWindow.ScrollRow = 425
    ActiveWindow.ScrollRow = 410
    ActiveWindow.ScrollRow = 399
    ActiveWindow.ScrollRow = 384
    ActiveWindow.ScrollRow = 372
    ActiveWindow.ScrollRow = 361
    ActiveWindow.ScrollRow = 348
    ActiveWindow.ScrollRow = 333
    ActiveWindow.ScrollRow = 318
    ActiveWindow.ScrollRow = 303
    ActiveWindow.ScrollRow = 291
    ActiveWindow.ScrollRow = 276
    ActiveWindow.ScrollRow = 264
    ActiveWindow.ScrollRow = 250
    ActiveWindow.ScrollRow = 238
    ActiveWindow.ScrollRow = 227
    ActiveWindow.ScrollRow = 217
    ActiveWindow.ScrollRow = 205
    ActiveWindow.ScrollRow = 194
    ActiveWindow.ScrollRow = 184
    ActiveWindow.ScrollRow = 173
    ActiveWindow.ScrollRow = 163
    ActiveWindow.ScrollRow = 153
    ActiveWindow.ScrollRow = 144
    ActiveWindow.ScrollRow = 135
    ActiveWindow.ScrollRow = 126
    ActiveWindow.ScrollRow = 117
    ActiveWindow.ScrollRow = 110
    ActiveWindow.ScrollRow = 104
    ActiveWindow.ScrollRow = 98
    ActiveWindow.ScrollRow = 91
    ActiveWindow.ScrollRow = 87
    ActiveWindow.ScrollRow = 83
    ActiveWindow.ScrollRow = 77
    ActiveWindow.ScrollRow = 73
    ActiveWindow.ScrollRow = 69
    ActiveWindow.ScrollRow = 64
    ActiveWindow.ScrollRow = 62
    ActiveWindow.ScrollRow = 58
    ActiveWindow.ScrollRow = 55
    ActiveWindow.ScrollRow = 53
    ActiveWindow.ScrollRow = 49
    ActiveWindow.ScrollRow = 46
    ActiveWindow.ScrollRow = 44
    ActiveWindow.ScrollRow = 41
    ActiveWindow.ScrollRow = 40
    ActiveWindow.ScrollRow = 38
    ActiveWindow.ScrollRow = 36
    ActiveWindow.ScrollRow = 35
    ActiveWindow.ScrollRow = 32
    ActiveWindow.ScrollRow = 30
    ActiveWindow.ScrollRow = 28
    ActiveWindow.ScrollRow = 27
    ActiveWindow.ScrollRow = 24
    ActiveWindow.ScrollRow = 23
    ActiveWindow.ScrollRow = 21
    ActiveWindow.ScrollRow = 20
    ActiveWindow.ScrollRow = 18
    ActiveWindow.ScrollRow = 17
    ActiveWindow.ScrollRow = 14
    ActiveWindow.ScrollRow = 12
    ActiveWindow.ScrollRow = 11
    ActiveWindow.ScrollRow = 10
    ActiveWindow.ScrollRow = 9
    ActiveWindow.ScrollRow = 8
    ActiveWindow.ScrollRow = 6
    ActiveWindow.ScrollRow = 4
    ActiveWindow.ScrollRow = 3
    ActiveWindow.ScrollRow = 2
    Range("H2").Select
    ActiveCell.FormulaR1C1 = "=RC[-6]+RC[-4]"
    Range("H2").Select
    Selection.AutoFill Destination:=Range("H2:H721"), Type:=xlFillDefault
    Range("H2:H721").Select
    ActiveWindow.SmallScroll Down:=8
    ActiveSheet.ChartObjects("Chart 1").Activate
    ActiveSheet.Shapes("Chart 1").IncrementTop 25.5
    Range("G722").Select
    ActiveCell.FormulaR1C1 = "Avg"
    Range("H722").Select
    ActiveCell.FormulaR1C1 = "=AVERAGE(R[-720]C:R[-1]C)"
    Range("G723").Select
    ActiveCell.FormulaR1C1 = "Max"
    Range("H723").Select
    ActiveCell.FormulaR1C1 = "=MAX(R[-721]C:R[-2]C)"
    Range("H724").Select
    ActiveWorkbook.Save
    ActiveWorkbook.Close
End Sub
