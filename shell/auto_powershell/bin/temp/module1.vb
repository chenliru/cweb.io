' Licensed Materials - Property of IBM
' (C) Copyright IBM Corp. 2000, 2015 All Rights Reserved.
                                       
Option Explicit
Public Analyser As String              'Analyser version (from main sheet)
Public Batch As Integer                'Batch mode setting (0/1)
Public BBBFont As String               'name of fixed pitch font to use on BBB sheets
Public ColNum As Long                  'Last column number
Public Copies As Integer               'Number of copies to print
Public CPUrows As Long                 'number of rows on the first CPU sheet
Public CPUmax As Integer               'maximum number of CPU/PCPU/SCPU sheets to create
Public DebugVar As Variant             'useful for debugging
Public Delim As String                 'Delimiter used in .csv file
Public DecSep As String                'Decimalseparator used in .csv file
Public dLPAR As Variant                'True if dynamic LPAR has been used for CPUs
Public ErrMsg As String                'Error message for file
Public ESSanal As Boolean              'True if ESS analysis to be done
Public Filename As String              'Qualified name of the input file
Public First As Long                   'First time interval to process
Public FirstTime As Date               'First time/date to processf
Public m_Esoteric As String            'Either "power" or "dac"
Public m_GotEMC As Boolean             'True if either EMC or FAStT present
Public m_GotESS As Boolean             'True if EMC/ESS/FAStT or DGs present
Public Graphs As String                'ALL/LIST
Public Host As String                  'Hostname from AAA sheet
Public Last As Long                    'Last time interval to process
Public LastTime As Date                'Last time/date to process
Public LastColumn As String            'Last column letter
Public Linux As Boolean                'True if Linux
Public List As String                  'List of sheets to graph
Public LScape As Boolean               'Value of LScape field
Public MaxRows As Long                 'Maximum rows in a sheet
Public MaxCols As Long                 'Maximum columns in a sheet
Public Merge As String                 'NO, YES or KEEP
Public NumCPUskipped As Integer        'Number of CPU sections skipped
Public progname As String              'Version of NMON/topas
Public NoList As Boolean               'true if NOLIST=DELETE
Public NoTop As Boolean                'True if TOP section is to be deleted
Public NumCPUs As Integer              'Number of CPU sections
Public NumDisk As Integer              'Number of disk subsections
Public OutDir As String                'Name of output directory
Public Output As String                'CHART/PICTURES/WEB/PRINT
Public pivot As Boolean                'True if a Pivot Chart is to be produced
Public PNG As Variant                  'AllowPNG (True/False)
Public Printer As String               'Name of Printer
Public Reorder As Boolean              'Reorder sheets after analysis (True/False)
Public rH As Single                    'Row Height
Public ReProc As Boolean               'Reprocess or bypass input files in batch mode
Public Scatter As Boolean               'Option to include scatter graphs (or not) due to Excel 2013 crash @RM - 1/23/2015
Public BigData As Boolean             ' Option that indicates if the slower method of importing the data that allows big lines and > 1 million rows should be used.
Public RunDate As String               'NMON run date from AAA sheet
Public SMTon As Boolean                'true if SMT is on (set in BBBP)
Public SMTmode As Integer              'number of threads per core
Public Snapshots As Long               'Set by PP_AAA and reset by PP_ZZZZ
'Public SortInp As Boolean              'Sort input file (True/False)
Public SortDefault As Boolean          'Sort data in 'default' sheets by Avg+WAvg (True/False)
Public Steal As Boolean                'True AAA,steal,1 exists
Public Start As Double                 'Start date/time value
Public SubDir As Boolean               'OrganizeInFolder (True/False)
Public SVCTimes As Boolean             'Produce disk service time estimates (True/False)
Public SVCXLIM As Integer              'Lower limit for service time analysis
Public ThouSep As String               'Thousands separator unsed in .csv file
Public topas As Variant                'True if topas (PTX:xmtrend)
Public TopDisks As Integer             'No. of entries to show on graphs (0 = all)
Public TopRows As Long                 'No. of rows on the TOP sheet for PP_UARG
Public t1 As String                    'First timestamp on the CPU_ALL sheet
Public WebDir As String                'Name of output directory for HTML
Public xToD As String                  'Number format for ToD graphs
                                       'position & dimension data for charts
Public cTop As Integer, cLeft As Integer, cWidth As Integer, cHeight As Integer
Public csTop1 As Integer, csTop2 As Integer, csTop3 As Integer, csTop4 As Integer
Public csHeight As Integer
                                       'definitions for Pivot chart
Public PivotParms As Variant
                                       'definitions for SORT process
                                       
Public m_StartRow As Long              'pointer to start of range
Public m_CurrentRow As Long            'pointer to start of range
Dim m_Elapsed As Single                'elapsed time in seconds


#If VBA7 Then
Public Declare PtrSafe Function OpenProcess Lib "kernel32" ( _
       ByVal dwDesiredAccess As Long, ByVal bInheritHandle As Long, _
       ByVal dwProcessId As Long) As Long
Public Declare PtrSafe Function WaitForSingleObject Lib "kernel32" ( _
       ByVal hHandle As Long, ByVal dwMilliseconds As Long) As Long
Public Declare PtrSafe Function CloseHandle Lib "kernel32" ( _
       ByVal hObject As Long) As Long
#Else
Public Declare Function OpenProcess Lib "kernel32" ( _
       ByVal dwDesiredAccess As Long, ByVal bInheritHandle As Long, _
       ByVal dwProcessId As Long) As Long
Public Declare Function WaitForSingleObject Lib "kernel32" ( _
       ByVal hHandle As Long, ByVal dwMilliseconds As Long) As Long
Public Declare Function CloseHandle Lib "kernel32" ( _
       ByVal hObject As Long) As Long
#End If

Public Const SYNCHRONIZE = &H100000
Public Const INFINITE = &HFFFF
                                       'last mod v3.3.e3
Sub ApplyStyle(Chart1 As ChartObject, gtype As Integer, nseries As Long)
    'gtype = 0 for bars, 1 for lines, 2 for area
    'nseries = number of series
Dim CurCol As Long
Dim ic As Long
Dim MaxVal As Double
Dim Pct As String
'Public xToD as string                  'Number format for ToD graphs
    
With Chart1.Chart
   .ChartArea.AutoScaleFont = False
   Chart1.Placement = xlFreeFloating
   If .HasLegend = True Then .Legend.Position = xlLegendPositionTop
   If .Axes(xlCategory).TickLabels.Orientation <> xlHorizontal Then _
      .Axes(xlCategory).TickLabels.Orientation = xlUpward
   If gtype = 1 Then
      .Axes(xlValue).HasMajorGridlines = True
      If nseries < 8 Then
         For ic = 1 To nseries
            .SeriesCollection(ic).Border.Weight = xlMedium
         Next
      End If
   Else
      If gtype = 0 Then
         .ChartType = xlColumnStacked
         .Axes(xlCategory).TickLabelSpacing = 1
      Else
      '  .Type = $Area
      End If
   End If
   If gtype > 0 Then
      .Axes(xlCategory).HasMajorGridlines = False
      .Axes(xlCategory).MajorTickMark = xlNone
      .Axes(xlCategory, xlPrimary).CategoryType = xlCategoryScale
      .Axes(xlCategory).TickLabels.NumberFormat = xToD
   End If
      .Axes(xlValue).MinimumScale = 0
End With
                                        'scale the y-axis
With Chart1.Chart
   MaxVal = .Axes(xlValue).MaximumScale
   If .Axes(xlValue).DisplayUnit = xlThousands Then MaxVal = MaxVal / 1000
   If MaxVal > 5181 Then
      .Axes(xlValue).HasDisplayUnitLabel = True
      If MaxVal > 3333431 Then
         .Axes(xlValue).DisplayUnit = xlMillions
      Else
         .Axes(xlValue).DisplayUnit = xlThousands
      End If
   End If
   Pct = ""
   If Right(.Axes(xlValue).TickLabels.NumberFormat, 1) = "%" Then
      Pct = "%"
      MaxVal = MaxVal * 10
   End If
   If MaxVal >= 10 Then
      .Axes(xlValue).TickLabels.NumberFormat = "0" & Pct
   Else
      .Axes(xlValue).TickLabels.NumberFormat = "0.0" & Pct
   End If
End With

End Sub
                                       'last mod v3.0
Function avgmax(numrows As Long, Sheet1 As Worksheet, DoSort As Integer) As Range
Dim Chart1 As ChartObject
Dim Column As String
Dim DiskData As Range
'Public LastColumn As String, ColNum as Integer
Dim MyCells As Range
Dim n As Integer
                                        ' Put in the formulas for avg/max
Set avgmax = Sheet1.Range("A" & CStr(numrows + 2) & ":" & LastColumn & CStr(numrows + 4 + DoSort))
Column = "B2:B" & CStr(numrows)
avgmax.Item(1, 1) = "Avg."
avgmax.Item(1, 2) = "=AVERAGE(" & Column & ")"
avgmax.Item(2, 1) = "WAvg."
avgmax.Item(2, 2) = "=IF(B" & CStr(numrows + 2) & "=0,0,MAX(SUMPRODUCT(" & Column & "," & Column & ")/SUM(" & Column & ")-B" & CStr(numrows + 2) & ",0))"
avgmax.Item(3, 1) = "Max."
avgmax.Item(3, 2) = "=ABS(MAX(B2:B" & CStr(numrows) & ")-B" & CStr(numrows + 2) & "-B" & CStr(numrows + 3) & ")"
'avgmax.Item(3, 2) = "=MAX(B2:B" & CStr(numrows) & ")"
If DoSort = 1 Then
   avgmax.Item(4, 1) = "SortKey"
   avgmax.Item(4, 2) = "=B" & CStr(numrows + 2) & "+ B" & CStr(numrows + 3)
End If

If LastColumn <> "B" Then
   Set MyCells = Sheet1.Range("B" & CStr(numrows + 2) & ":" & LastColumn & CStr(numrows + 4 + DoSort))
   MyCells.FillRight
   MyCells.NumberFormat = "0.0"
End If
      
End Function
Public Function Checklist(inVal As String) As Boolean
Dim MyArray As Variant
Dim i As Long

Checklist = True
MyArray = Split(List, ",")
For i = 0 To UBound(MyArray)
    If inVal Like MyArray(i) Then Exit Function
Next i
Checklist = False

End Function
Public Function ConvertRef(inVal As Variant) As Variant
If IsNumeric(inVal) Then
   If inVal < 26 Then
      ConvertRef = Chr(inVal + 65)
   Else
      ConvertRef = Chr((inVal \ 26) + 64) & Chr((inVal Mod 26) + 65)
   End If
Else
   If Len(inVal) > 1 Then
      ConvertRef = ((Asc(UCase$(inVal)) - 64) * 26) + (Asc(UCase$(Right$(inVal, 1))) - 64)
   Else
      ConvertRef = Asc(UCase$(inVal)) - 64
   End If
End If
End Function
                                       'v3.3.g1
Sub CreatePivot()
Dim i As Long, nr As Long, nc As Long
Dim MyCells As Range
Dim pSheet As String
Dim pPage As String
Dim pRow As String
Dim pColumn As String
Dim pData As String
Dim pFunc As Integer
Dim Sheet1 As Worksheet

pSheet = PivotParms(0)
If Not SheetExists(pSheet) Then Exit Sub
UserForm1.Label1.Caption = "Creating Pivot Chart for " & pSheet
UserForm1.Repaint

Set Sheet1 = Worksheets(pSheet)
pPage = PivotParms(1)
pRow = PivotParms(2)
pColumn = PivotParms(3)
pData = PivotParms(4)

Select Case PivotParms(5)
   Case ("SUM")
      pFunc = -4157
   Case ("COUNT")
      pFunc = -4112
   Case ("MIN")
      pFunc = -4139
   Case ("AVG")
      pFunc = -4106
   Case ("MAX")
      pFunc = -4136
   Case Else
      pFunc = 1000
End Select
                                       'number of used columns
For nc = 1 To MaxCols
   If Sheet1.Cells(1, nc) = "" Then Exit For
Next
                                       'number of used rows
For nr = 1 To MaxRows
   If Sheet1.Cells(nr, 1) = "" Then Exit For
Next
                                       'produce the pivot chart
i = Worksheets("AAA").Range("snapshots")
ActiveWorkbook.PivotCaches.Add(SourceType:=xlDatabase, SourceData:= _
   pSheet & "!A1:" & ConvertRef(nc - 2) & CStr(nr - 1)).CreatePivotTable TableDestination:="", _
   TableName:="MyPivot"
ActiveSheet.PivotTableWizard TableDestination:=ActiveSheet.Cells(3, 1)
ActiveSheet.Cells(3, 1).Select
ActiveSheet.PivotTables("MyPivot").AddFields RowFields:=pRow, _
   ColumnFields:=pColumn, PageFields:=pPage
With ActiveSheet.PivotTables("MyPivot").PivotFields(pData)
   .Orientation = xlDataField
   .Function = pFunc
End With
Charts.Add
ActiveChart.Location Where:=xlLocationAsNewSheet
ActiveChart.PlotArea.Select
ActiveChart.ChartType = xlAreaStacked
With ActiveChart.Axes(xlCategory)
   .CrossesAt = 1
   If pRow = "Time" And i > 10 Then .TickLabelSpacing = (i / 10)
   .TickMarkSpacing = 1
   .AxisBetweenCategories = False
   .ReversePlotOrder = False
End With
ActiveSheet.Move After:=Sheets("AAA")
End Sub
                                       'v3.3.0
Sub DefineStyles()
Dim aa0 As String
'Public cTop As Integer, cLeft As Integer, cWidth As Integer, cHeight As Integer
'Public csTop1 As Integer, csTop2 As Integer, csHeight As Integer
Dim temp As Single

If cWidth = 0 Then
   If Output = "PRINT" Then
      If LScape Then Worksheets(1).PageSetup.Orientation = xlLandscape
      Worksheets(1).Cells(1, MaxCols) = "break"
      ActiveWindow.View = xlPageBreakPreview
      aa0 = Worksheets(1).VPageBreaks(1).Location.Address(True, True, xlR1C1)
      cWidth = (Right(aa0, Len(aa0) - InStr(1, aa0, "C")) - 1) * Worksheets(1).Range("A1").Width
      ActiveWindow.View = xlNormalView
      Worksheets(1).Cells(1, MaxCols) = ""
   Else
      cWidth = Application.UsableWidth - (1.7 * Worksheets(1).Range("A1").Width)
   End If
   cHeight = Int(cWidth / 2.4)
   temp = Worksheets(1).Range("A1").Height
   cHeight = Int(Int(cHeight / temp) * temp)
End If
                                        'position & dimensions for single charts
rH = Worksheets(1).Range("A1").Height
cTop = Worksheets(1).Range("A1").Height + 1
cLeft = Worksheets(1).Range("A1").Width
                                        'position & dimensions for multi-charts
csHeight = cHeight
csTop1 = cTop
csTop2 = csHeight + csTop1 + 1
csTop3 = csHeight + csTop2 + 1
csTop4 = csHeight + csTop3 + 1
End Sub
Sub DelInt(Sheet1 As Worksheet, numrows As Long, HdLines As Integer)
If Last < numrows - HdLines Then
   Sheet1.Range("A" & CStr(Last + HdLines + 1) & ":A" & CStr(numrows)).EntireRow.Delete
   numrows = Last + HdLines
End If
If First > 1 Then
   Sheet1.Range("A" & CStr(HdLines + 1) & ":A" & CStr(First - 1 + HdLines)).EntireRow.Delete
   numrows = numrows - First + 1
End If
End Sub
                                       'last mod v3.3.F
Sub DiskGraphs(numrows As Long, SectionName As String, DoSort As Variant)
Static Chart1 As ChartObject            'new chart object
Static ChartTitle As String             'title for new chart
'Public ColNum As Integer               'last column number
Static Column As String                 'column of last disk to be graphed
Static DiskData As Range                'data to be charted
'Public Host As String                  'Hostname from AAA sheet
'Public  LastColumn As String           'last column letter
Static MyCells As Range                 'temp var
Static MyWidth As Integer               'variable graph width
Static nd As Long                       'number of disks to graph
'Public RunDate As String               'NMON run date from AAA sheet
Static Sheet1 As Worksheet              'current sheet
'Public TopDisks As Integer             'No. of hdisks to show on graphs (0 = all)
    
Set Sheet1 = Worksheets(SectionName)
Sheet1.Activate
'nd = InStr(1, List, Sheet1.Name)
                                        'Change column widths
Set MyCells = Sheet1.Range("B1:" & LastColumn & CStr(numrows))
MyCells.ColumnWidth = 7
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
                                        'preset chart title
ChartTitle = Sheet1.Range("A1")
If Left(SectionName, 4) = "DISK" And InStr(1, SectionName, "SIZE") > 0 Then
   ChartTitle = ChartTitle + " (Kbytes)"
End If
                                         'Put in the formulas for avg/max
Set DiskData = avgmax(numrows, Sheet1, 1)
If DoSort Then
   Sheet1.Range("B1:" & LastColumn & CStr(numrows + 5)).Sort _
    Key1:=Sheet1.Range("B" & CStr(numrows + 5)), Order1:=xlDescending, _
    Header:=xlYes, OrderCustom:=1, MatchCase:=False, Orientation:=xlLeftToRight
End If

nd = DiskData.Columns.Count - 1
If (nd > TopDisks And TopDisks > 0) Then
   Column = ConvertRef(TopDisks)
   ChartTitle = ChartTitle & " (1st " & CStr(TopDisks) & ")"
   nd = TopDisks
Else
   Column = LastColumn
End If

MyWidth = cWidth / 50 * nd
If MyWidth < cWidth Then MyWidth = cWidth
Set DiskData = Sheet1.Range("B" & CStr(numrows + 2) & ":" & Column & CStr(numrows + 4))
ChartTitle = ChartTitle & "  " & RunDate
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + rH * numrows, MyWidth, cHeight)
Chart1.Chart.ChartWizard Source:=DiskData, PlotBy:=xlRows, Title:=ChartTitle
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection(1).Name = Sheet1.Cells(numrows + 2, 1).Value
   .SeriesCollection(2).Name = Sheet1.Cells(numrows + 3, 1).Value
   .SeriesCollection(3).Name = Sheet1.Cells(numrows + 4, 1).Value
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(1, 2), Cells(1, nd + 1))
                                        'apply customisation
   If InStr(SectionName, "DISKBUSY") > 0 Then .Axes(xlValue).MaximumScale = 100
   Call ApplyStyle(Chart1, 0, 3)
End With
                                        'produce line graph
Set DiskData = Sheet1.Range("A1:" & Column & CStr(numrows))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop2 + rH * numrows, MyWidth, csHeight)
Chart1.Chart.ChartWizard Source:=DiskData, Gallery:=xlLine, Format:=2, _
    Title:=ChartTitle, CategoryLabels:=1, SeriesLabels:=1, HasLegend:=True
                                        'apply customisation
With Chart1.Chart
    Call ApplyStyle(Chart1, 1, nd)
End With

End Sub
                                        'v3.3.h
Sub GetIntervals(Filename As String)
Dim fnin As Variant, fs As Variant
Dim InputString As String, aa0 As Variant, temp As Long
Dim TS As Double

First = 0
Set fs = CreateObject("Scripting.FileSystemObject")
Set fnin = fs.OpenTextFile(Filename, 1, 0)
                                          'look for ZZZZ values
Do While fnin.AtEndOfStream <> True
   InputString = fnin.readline
   If Left(InputString, 4) = "ZZZZ" Then
      aa0 = Split(InputString, Delim)
      temp = CLng(Right(aa0(1), Len(aa0(1)) - 1))
      TS = TimeValue(aa0(2))
      If First = 0 Then        'looking for first interval
         If FirstTime > 1 Then TS = DateValue(aa0(3)) + TS  'looking for a date as well as a time
         If TS >= FirstTime Then
            First = temp
            Last = First + 1
                                'if LastTime is less than FirstTime then assume next day
            If (LastTime < 1) And (FirstTime > LastTime) Then LastTime = LastTime + DateValue(aa0(3)) + 1
         End If
      Else                                'looking for last interval
         If LastTime > 1 Then TS = DateValue(aa0(3)) + TS  'looking for a date as well as a time
         If TS >= LastTime Then Exit Do
         Last = temp
      End If
   End If
Loop
fnin.Close

End Sub
                                        'last mod v4.0
Sub GetLastColumn(Sheet1 As Worksheet, row As Long)
    Dim n As Long
                                        'Locate the last column
   LastColumn = "B"
   For n = 3 To MaxCols
     If Sheet1.Range("A" + CStr(row))(1, n) = "" Then Exit For
   Next n
   ColNum = n - 1
   LastColumn = Sheet1.Range("A" + CStr(row)).Item(1, ColNum).Address(True, False, xlA1)
   LastColumn = Left(LastColumn, InStr(1, LastColumn, "$") - 1)
End Sub
                                       'last mod v4.0
Sub GetNextSection(RawData As Worksheet, SectionName As String)

    SectionName = RawData.Cells(m_CurrentRow, 1).Value
    If SectionName = "" Then Exit Sub

    m_StartRow = m_CurrentRow
    
    'determine the start and end rows for each section being loaded
    Do
        m_CurrentRow = m_CurrentRow + 1
        If m_CurrentRow = MaxRows Then Exit Do
    Loop While RawData.Cells(m_CurrentRow, 1).Value = SectionName
    
    If SectionName = "NPIV" Then
         ' @RM 2/13/2015
         ' NPIV header is at the bottom because of the sort on 2nd column (T0001 is before Virtual)
         ' move the last row to the top of this section within the RawData
         RawData.Rows(m_StartRow).Insert
         RawData.Rows(m_CurrentRow).EntireRow.Cut Destination:=RawData.Range("A" & m_StartRow)
         RawData.Rows(m_CurrentRow).EntireRow.Delete
    End If
End Sub
                                       'last mod v3.3.h
Sub GetSettings(FileList As Variant, Numfiles As Integer)
Dim Filename As String
Dim Fname As String
Dim fPath As String
Dim i As Integer
Dim MyCells As Range
Dim sTemp As String
Dim Sheet1 As Worksheet
 
Set Sheet1 = ThisWorkbook.Worksheets(1)
Analyser = Sheet1.Range("A1").Value
                                       'Settings for this run
Graphs = Sheet1.Range("Graphs").Value
First = Sheet1.Range("First").Value
Last = Sheet1.Range("Last").Value
FirstTime = Sheet1.Range("FirstTime").Value
LastTime = Sheet1.Range("LastTime").Value
Merge = Sheet1.Range("Merge").Value
NoTop = Sheet1.Range("NoTop").Value = "NOTOP"
Output = Sheet1.Range("Output").Value
pivot = Sheet1.Range("Pivot").Value = "YES"
Scatter = Sheet1.Range("Scatter").Value = "YES"       ' @RM - 1/23/2015
BigData = Sheet1.Range("BigData").Value = "YES"
ESSanal = Sheet1.Range("ESSanal").Value = "YES"
Filename = Sheet1.Range("Filelist").Value
'================= Settings Sheet ======================================
Set Sheet1 = ThisWorkbook.Worksheets("Settings")
                                       'Batch settings
ReProc = Sheet1.Range("Reproc").Value = "YES"
OutDir = Sheet1.Range("OutDir").Value
If OutDir <> "" Then
   If Right(OutDir, 1) <> "\" Then OutDir = OutDir & "\"
   If Dir(OutDir, vbDirectory) = "" Then
      MsgBox ("Output Directory does not exist")
      Exit Sub
   End If
End If
                                       'Formatting settings
BBBFont = Sheet1.Range("BBBFont").Value
cWidth = Sheet1.Range("GWidth").Value
cHeight = Sheet1.Range("GHeight").Value
List = Sheet1.Range("List").Value + ",SYS_SUMM,CPU_SUMM,DISK_SUMM"
CPUmax = Sheet1.Range("CPUmax").Value
NoList = Sheet1.Range("NoList").Value = "DELETE"
Reorder = Sheet1.Range("Reorder").Value = "YES"
TopDisks = Sheet1.Range("TopDisks").Value
xToD = Sheet1.Range("xToD").Value
SortDefault = Sheet1.Range("SortDefault").Value = "YES"

                                       'Pivot chart parameters
If pivot Then
   PivotParms = Array(Sheet1.Range("PivotParms").Cells(1, 1), _
                      Sheet1.Range("PivotParms").Cells(1, 2), _
                      Sheet1.Range("PivotParms").Cells(1, 3), _
                      Sheet1.Range("PivotParms").Cells(1, 4), _
                      Sheet1.Range("PivotParms").Cells(1, 5), _
                      Sheet1.Range("PivotParms").Cells(1, 6))
End If
                                       'Printer settings
LScape = Sheet1.Range("LScape").Value Like "YES"
Copies = Sheet1.Range("Copies").Value
Printer = Sheet1.Range("Printer").Value
                                       'Web settings
PNG = Sheet1.Range("PNG").Value Like "YES"
SubDir = Sheet1.Range("SUBDIR").Value Like "YES"
WebDir = Sheet1.Range("WebDir").Value
If WebDir <> "" Then
   If Right(WebDir, 1) <> "\" Then WebDir = WebDir & "\"
   If Dir(WebDir, vbDirectory) = "" Then
      MsgBox ("Web output Directory does not exist")
      Exit Sub
   End If
End If
                                       'National language settings
Delim = Sheet1.Range("Delim").Value
DecSep = ".": ThouSep = ","
If Delim = ";" Then DecSep = ",": ThouSep = "."
'SortInp = Sheet1.Range("SortInp").Value Like "YES"
'================= Build filelist ====================================
Numfiles = 0
Set MyCells = Worksheets(1).Range("FileList").Offset(0, -1)
If Filename = "" Or Dir(Filename) = "" Then
                                        'get the names of the files to process
   FileList = Application.GetOpenFilename("NMON Files(*.csv;*.nmon),*.csv;*.nmon", 1, "Select NMON file(s) to be processed", , True)
   If VarType(FileList) <> vbBoolean Then Numfiles = UBound(FileList)
                                       'write them to the sheet for sorting
   If Numfiles = 0 Then Exit Sub
   For i = 1 To Numfiles
      MyCells.Offset(i, 0) = FileList(i)
   Next
Else
                                        'we have filelist - build a list of names
   Open Filename For Input As #1
   Do Until EOF(1)
      Line Input #1, Fname
      If Fname = "" Then Exit Do
      sTemp = Dir(Fname)
      fPath = Left(Fname, InStrRev(Fname, "\"))
      Do
        If sTemp = "" Then Exit Do
        Numfiles = Numfiles + 1
        MyCells.Offset(Numfiles, 0) = fPath & sTemp
        sTemp = Dir
      Loop
   Loop
   Close (1)
   If Numfiles = 0 Then
      MsgBox ("No valid files in FileList")
      Exit Sub
   End If
End If
                                        'sort the names into ascending sequence
MyCells.Resize(Numfiles + 1, 1).Sort Key1:=MyCells, Header:=xlYes
                                        'and store them in the Filelist array
ReDim FileList(Numfiles)
For i = 1 To Numfiles
   FileList(i) = MyCells(i + 1, 1).Value
   MyCells(i + 1, 1).Clear
Next

End Sub
                                       'last mod v3.3.h
Sub Main(code As Integer)
Dim aa0 As String
Dim FileList As Variant
Dim i As Integer                        'counter for main loop
Dim MyCells As Range                    'temp var
Dim MyComments As Comments

Dim n As Integer                        'temp var
Dim Numfiles As Integer                 'Number of files to process
Dim NmonFile As Workbook                'Pointer to the output file
Dim Output_Filename As String           'Qualified name of the output file
Dim PID As Double                       'Process Id of spawned SORT process
Dim PHn As Double                       'Process Header of spawned SORT process
Dim RawData As Workbook                 'Pointer to the input file
Dim Sortfile As String                  'name of temp file created by SORT process
Dim splitpos As Integer                 'Pointer to last "." in input filename
Dim SummaryFile As Workbook
Dim Sheet1 As Worksheet
Dim fs As Variant
Dim X As Long
Dim iLen As Long
Dim strLine As String
Dim SaveFormat As Long
Dim q As Integer
          
Dim worksheetnum As Integer
        
m_Elapsed = Timer()
        
' @RM - 2/13/2015
' Remember the users current default save format (which might be the old 97-2003 format)
SaveFormat = Application.DefaultSaveFormat
' Set it to the 2007-2010 file format xlsx, this will probably break users on Excel 2003 without the
' update to support .xlsx files.
Application.DefaultSaveFormat = 51
Application.DisplayAlerts = False

Batch = code
Set fs = CreateObject("Scripting.FileSystemObject")
Call GetSettings(FileList, Numfiles)
If Numfiles = 0 Then
    Batch = 0
    Exit Sub
End If
    
Application.ScreenUpdating = False      'set to True for debugging/False to improve performance

Dim fileExtension As String
If CInt(Val(Application.Version)) >= 12 Then
    MaxRows = 1048576
    MaxCols = 16384
    fileExtension = ".xlsx"
Else
   MaxRows = 65536
   MaxCols = 255
   fileExtension = ".xls"
End If

If Batch = 0 Then UserForm1.Show False

If Merge <> "NO" Then Call MergeFiles(FileList, Numfiles)
If Merge = "ONLY" Or Numfiles = 0 Then
   UserForm1.Hide
   Application.ScreenUpdating = True
   Batch = 0
   Exit Sub
End If

If Numfiles > 1 And Batch = 0 Then
                                       'create a summary file
   Set SummaryFile = Workbooks.Add(xlWBATWorksheet)
   Set Sheet1 = SummaryFile.Worksheets(1)
   Sheet1.Range("A1") = "Hostname"
   Sheet1.Range("B1") = "Snapshots"
   Sheet1.Range("C1") = "Start"
   Sheet1.Range("D1") = "Filename"
   Sheet1.Range("E1") = "Errors"
   Sheet1.Rows(1).Font.Bold = True
End If

For i = 1 To Numfiles
   
   'initialisation
   ErrMsg = ""
   Filename = FileList(i)
   Snapshots = 0
   Sortfile = ""
   If FirstTime > 0 Then Call GetIntervals(Filename)
   With UserForm1
      .Caption = Right(Filename, 40) & " (" & CStr(i) & " of " & CStr(Numfiles) & ")"
      .Label1.Caption = "Opening file"
      .Repaint
   End With
                                        'construct the output filename
   Output_Filename = Left(Filename, InStrRev(Filename, ".")) & "nmon" & fileExtension
   If OutDir <> "" Then
      splitpos = Len(Output_Filename) - InStrRev(Output_Filename, "\")
      Output_Filename = OutDir & Right(Output_Filename, splitpos)
   End If
                                        'bypass/delete file if it exists
    If Dir(Output_Filename) <> "" Then
        If Numfiles > 1 And ReProc = False Then
            ErrMsg = "File has already been processed and REPROC=NO"
            GoTo EndLoop
        End If
        
        fs.deletefile filespec:=Output_Filename
    End If
    
    Call ProcessFile(RawData)
    
    If BigData = False Then
        ' always sort the input file if BigData = false, all data is on a single sheet
        UserForm1.Label1.Caption = "Sorting file"
        UserForm1.Repaint
        RawData.Worksheets(1).Columns("A:A").Sort _
                              Key1:=RawData.Worksheets(1).Range("A1"), Order1:=xlAscending
    End If
      
    'avoid bizarre Excel bug if 1st line blank
    ' Set MyCells = RawData.Worksheets(1).Columns("A:A")
    ' If MyCells.Cells(1, 1) = "" Then Set MyCells = RawData.Worksheets(1).Range("A2:A" & CStr(MaxRows))
    'and parse it
    UserForm1.Label1.Caption = "Converting CSV format into columns on " + CStr(RawData.Sheets.Count) + " sheets"
    UserForm1.Repaint
    
    ' now for all sheets created (each with 1 million rows), expand CSV format
    For X = 1 To RawData.Sheets.Count
        Set MyCells = RawData.Worksheets(X).Columns("A:A")
        
        MyCells.TextToColumns Destination:=MyCells.Cells(1, 1), _
                                DataType:=xlDelimited, Other:=True, OtherChar:=Delim, _
                                DecimalSeparator:=DecSep, ThousandsSeparator:=ThouSep
    Next X
                      
    RawData.Sheets.Add After:=RawData.Sheets(RawData.Sheets.Count)
    Set NmonFile = RawData

    Application.Calculation = xlCalculationAutomatic
    
    CPUrows = 0
    dLPAR = False
    NumCPUs = 0
    NumDisk = 1
    Call NMON(RawData, NmonFile)
    
    If NumCPUs > 0 Then
        Application.DisplayAlerts = True
        NmonFile.Sheets(1).Activate
        
        UserForm1.Label1.Caption = "Saving file"
        If Numfiles > 1 Or Batch = 1 Then
            Application.DefaultSaveFormat = 51
            NmonFile.SaveAs Filename:=Output_Filename
            If Numfiles > 1 Or Batch = 1 Then NmonFile.Close
        Else
            Application.DefaultSaveFormat = 51
            Call Application.Dialogs(xlDialogSaveAs).Show(Arg1:=Output_Filename, Arg2:=xlWorkbookDefault)
        End If
   Else
      NmonFile.Close savechanges:=False
      If BigData Then
          ErrMsg = "No valid input data! NMON run may have failed."
      Else
          ErrMsg = "Set BIGDATA to YES on the Analyser sheet in order to process this data."
      End If
   End If
   
EndLoop:
    'delete the sortfile if needed
    If (Sortfile <> "" And Dir(Sortfile) <> "") Then fs.deletefile filespec:=Sortfile
    'delete the merged file if needed
    If Merge = "YES" Then fs.deletefile filespec:=FileList(1)

    If Numfiles > 1 And Batch = 0 Then
        'update summary file
        If Snapshots > 0 Then
            Sheet1.Cells(i + 1, 1) = Host
            Sheet1.Columns(1).AutoFit
            Sheet1.Cells(i + 1, 2) = Snapshots
            Sheet1.Columns(2).AutoFit
            Sheet1.Cells(i + 1, 3) = Start
            Sheet1.Cells(i + 1, 3).NumberFormat = "dd-mmm-yy hh:mm:ss"
            Sheet1.Columns(3).AutoFit
        End If
        
        If Dir(Output_Filename) <> "" Then
            Sheet1.Hyperlinks.Add Anchor:=Sheet1.Range("D1").Offset(i, 0), _
            Address:=Output_Filename, TextToDisplay:=Output_Filename
        End If
        
        Sheet1.Columns(4).ColumnWidth = 29
        Sheet1.Cells(i + 1, 4).HorizontalAlignment = xlRight
        Sheet1.Cells(i + 1, 5) = ErrMsg
   End If
   If Batch = 0 And Numfiles = 1 And ErrMsg <> "" Then MsgBox (ErrMsg)

Next i

UserForm1.Hide
Application.ScreenUpdating = True

'Set DefaultSaveFormat back to the users original setting
Application.DefaultSaveFormat = SaveFormat
Application.DisplayAlerts = True

If (Batch = 0 And Not (Numfiles = 1 And ErrMsg <> "")) Then ThisWorkbook.Close False
Exit Sub

End Sub
                                       'last mod v3.4a
Sub MergeFiles(FileList As Variant, Numfiles As Integer)
Dim aa0 As String, aa1 As String
Dim fnin As Variant, fnout As Integer
Dim Filename As String                 'output filename (ddmmyyhhmm.nmon)
Dim fs As Variant                      'Filesystem object
Dim i As Integer, j As Integer         'loop counters
Dim Tlen As Integer                    'length of timestamp
Dim Tn As Integer                      'current timestamp
Dim hostname As String                 'hostname of first file"
Dim t1 As String                       'time of first file
Dim d1 As String                       'date of first file
Dim t2 As String                       'time of first file
Dim d2 As String                       'date of first file

With UserForm1
   .Caption = "Merging files"
   .Repaint
End With
                                       'open a temp file
Filename = CurDir & "\" & "merged_" & Format(Now(), "yyyymmdd_hhmm") & ".nmon"
fnout = FreeFile()
Open Filename For Output As fnout
                                       'copy the first file
With UserForm1
   .Label1.Caption = Right(FileList(1), 25)
   .Show False
   .Repaint
End With

Set fs = CreateObject("Scripting.FileSystemObject")
Set fnin = fs.OpenTextFile(FileList(1), 1, 0)
                                          'extract only the sections we need
Do While fnin.AtEndOfStream <> True
   aa0 = fnin.readline
   aa1 = Left(aa0, 4)
   If aa1 = "ZZZZ" Then
      Tlen = InStr(7, aa0, Delim) - 7
      Tn = Mid(aa0, 7, Tlen)
   End If
   If Left(aa0, 9) = "AAA,host," Then hostname = Mid(aa0, 10)
   If Left(aa0, 9) = "AAA,time," Then t1 = Mid(aa0, 10)
   If Left(aa0, 9) = "AAA,date," Then d1 = Mid(aa0, 10)
   If Not ((aa1 = "TOP," Or aa1 = "UARG") And NoTop) Then
      If Left(aa0, 14) <> "AAA,snapshots," Then
         j = InStr(1, aa0, ",T")
         If j > 0 Then
            aa0 = Left(aa0, j + 1) & Format(Tn, "000000") & Right(aa0, Len(aa0) - j - Tlen - 1)
         End If
         Print #fnout, aa0
      End If
   End If
Loop
fnin.Close

For i = 2 To Numfiles
   With UserForm1
      .Label1.Caption = Right(FileList(i), 25)
      .Show False
      .Repaint
   End With
   Set fnin = fs.OpenTextFile(FileList(i), 1, 0)
                                       'skip headers (assumes file is unsorted)
   Do
      aa0 = fnin.readline
      If Left(aa0, 4) = "ZZZZ" Then Exit Do
   Loop
   Do While fnin.AtEndOfStream <> True
      aa1 = Left(aa0, 4)
      If aa1 = "ZZZZ" Then
         Tlen = InStr(7, aa0, Delim) - 7
         Tn = Tn + 1
         t2 = Mid(aa0, Tlen + 8, 8)
         d2 = Right(aa0, 11)
      End If
      If Not ((aa1 = "TOP," Or aa1 = "UARG") And NoTop) Then
         j = InStr(1, aa0, ",T")
         If j > 0 Then
            aa0 = Left(aa0, j + 1) & Format(Tn, "000000") & Right(aa0, Len(aa0) - j - Tlen - 1)
            Print #fnout, aa0
         End If
      End If
      aa0 = fnin.readline
   Loop
   fnin.Close
Next i
finish:
Print #fnout, "AAA,snapshots," & CStr(Tn)
Close fnout
                                        'rename the file
d1 = Format(d1, "yymmdd")
t1 = Format(t1, "hhmm")
d2 = Format(d2, "yymmdd")
t2 = Format(t2, "hhmm")
aa0 = CurDir & "\" & hostname & "_" & d1 & "_" & t1 & "_to_" & d2 & "_" & t2 & ".nmon"
Name Filename As aa0
FileList(1) = aa0
Numfiles = 1
End Sub
                                      'last mod v4.1
Sub NMON(Book1 As Workbook, NmonFile As Workbook)
Dim CPUList(1 To 1024) As String        'names of CPUnn sheets
Dim n As Long                           'temp var
Dim c As Long

Dim numrows As Long                     'number or rows in current section
Dim Section As Range                    'Range for cut/paste
Dim RawData As Worksheet
Dim SectionName As String               'name of current section
Dim Sheet1 As Worksheet                 'new sheet
Dim StrayLines As Integer               'counter for stray lines
Dim StraySheet As Worksheet             'pointer to StrayLines sheet
Dim worksheetnum As Integer
Dim lastSection As Long                 ' number of rows written to the last section when > MaxRows is encountered

Set RawData = Book1.Worksheets(1)

With UserForm1
   .Label1.Caption = "Starting Analysis"
   .Repaint
End With
Call DefineStyles
   
m_StartRow = 1
m_CurrentRow = 1
SMTmode = 1
worksheetnum = 1
lastSection = 0

m_GotEMC = False
m_GotESS = False
    
If RawData.Range("A1") = "" Then m_CurrentRow = 2   'horrible fix for Excel bug
Do 'Until SectionName = ""
    Set RawData = Book1.Worksheets(worksheetnum)
    Call GetNextSection(RawData, SectionName)

    If SectionName = "" Then
        Exit Do
    ElseIf SectionName = "TOP" Then
        m_StartRow = m_StartRow + 1
        RawData.Cells(m_StartRow, 2).Value = "PID"
    ElseIf SectionName = "UARG" Then
        RawData.Cells(m_StartRow, 2).Value = "Time"
    ElseIf CPUmax > 0 And InStr(Left$(SectionName, 4), "CPU") > 0 Then   'skip CPU sheets
         If Left(SectionName, 3) = "CPU" Then
            If Val(Mid(SectionName, 4)) > CPUmax Then
               NumCPUskipped = NumCPUskipped + 1
               GoTo EndSect
            End If
         Else
            If Val(Mid(SectionName, 5)) > CPUmax Then GoTo EndSect
         End If
    End If
    
    numrows = m_CurrentRow - m_StartRow
    If numrows > MaxRows - 256 Then numrows = MaxRows - 256  'leave space for totals etc.
    n = m_StartRow + numrows - 1
    
    ' GetLastColumn is not accurate for the AAA sheet and possibly others so use a min of 10
    Set RawData = Book1.Worksheets(worksheetnum)
    Call GetLastColumn(RawData, m_StartRow)
    If ColNum < 10 Then
        ColNum = 10
    End If
    
    Set Section = RawData.Range(RawData.Cells(m_StartRow, 2), RawData.Cells(n, ColNum))     ' supports whatever columns we have
                                            
    'if a valid section, build a sheet
    If numrows > 1 And SectionName <> "" And SectionName <> "ERROR" Then
      UserForm1.Label1.Caption = "Analysing: " & SectionName
      UserForm1.Repaint
      Dim copyStart As Long
      If SheetExists(SectionName) = False Then
        Sheets.Add.Name = SectionName
        copyStart = 1
      Else
        ' this occurs because we have moved to another sheet for the next MaxRows
        copyStart = lastSection + 1
      End If
      
      Set Sheet1 = Worksheets(SectionName)
      Sheet1.Move After:=Sheets(Sheets.Count)
      Section.Copy Sheet1.Range("A" & CStr(copyStart))
      Application.CutCopyMode = False
      Call GetLastColumn(Sheet1, 1)
                                          'Do any Post Processing
      If Left$(SectionName, 3) = "AAA" Then
         Call PP_AAA(numrows, Sheet1)
      ElseIf Left$(SectionName, 3) = "BBB" Then
         Call PP_BBB(numrows, Sheet1)
      ElseIf Left$(SectionName, 4) = "CPU_" Then
         Call PP_CPU(numrows, Sheet1)
         If CPUrows < 3 Then
            ErrMsg = "Only one interval - processing terminated"
            Snapshots = 1
            NumCPUs = NumCPUs + 1         'avoid "no valid data" message
            Book1.Close savechanges:=False
            GoTo FinishUp
         End If
      ElseIf InStr(Left$(SectionName, 4), "CPU") > 0 Then
         If Left(SectionName, 3) = "CPU" Then
            If CPUmax > 0 And Val(Mid(SectionName, 4)) > CPUmax Then GoTo EndSect
            NumCPUs = NumCPUs + 1
            CPUList(NumCPUs) = SectionName
         Else
            If CPUmax > 0 And Val(Mid(SectionName, 5)) > CPUmax Then GoTo EndSect
         End If
         Call PP_CPU(numrows, Sheet1)
      ElseIf Left$(SectionName, 2) = "DG" Then
         m_GotESS = True
         Call PP_DG(numrows, Sheet1)
      ElseIf Left$(SectionName, 4) = "DISK" Then
         Call PP_DISK(numrows, Sheet1)
      ElseIf SectionName = "DONATE" Then
         Call PP_DONATE(numrows, Sheet1)
      ElseIf Left$(SectionName, 3) = "ESS" Then
         m_GotESS = True
         Call PP_ESS(numrows, Sheet1)
      ElseIf SectionName = "FILE" Then
         Call PP_FILE(numrows, Sheet1)
      ElseIf SectionName = "FRCA" Then
         Call PP_FRCA(numrows, Sheet1)
      ElseIf SectionName = "IOADAPT" Then
         Call PP_IOADAPT(numrows, Sheet1)
      ElseIf SectionName = "IP" Then
         Call PP_IP(numrows, Sheet1)
      ElseIf Left$(SectionName, 3) = "JFS" Then
         Call PP_JFS(numrows, Sheet1)
      ElseIf SectionName = "LAN" Then
         Call PP_LAN(numrows, Sheet1)
      ElseIf SectionName = "LARGEPAGE" Then
         Call PP_LPAGE(numrows, Sheet1)
      ElseIf SectionName = "LPAR" Then
         Call PP_LPAR(numrows, Sheet1)
      ElseIf SectionName = "MEM" Then
         Call PP_MEM(numrows, Sheet1)
      ElseIf SectionName = "MEMAMS" Then
         Call PP_MEMAMS(numrows, Sheet1)
      ElseIf SectionName = "MEMNEW" Then
         Call PP_MEMNEW(numrows, Sheet1)
      ElseIf Left(SectionName, 8) = "MEMPAGES" Then
         Call PP_MEMPAGES(numrows, Sheet1)
      ElseIf SectionName = "MEMREAL" Then
         Call PP_MEMREAL(numrows, Sheet1)
      ElseIf SectionName = "MEMUSE" Then
         Call PP_MEMUSE(numrows, Sheet1)
      ElseIf SectionName = "MEMVIRT" Then
         Call PP_MEMVIRT(numrows, Sheet1)
      ElseIf SectionName = "NET" Then
         Call PP_NET(numrows, Sheet1)
      ElseIf SectionName = "PAGE" Then
         Call PP_PAGE(numrows, Sheet1)
      ElseIf SectionName = "PAGING" Then
         Call PP_PAGING(numrows, Sheet1)
      ElseIf SectionName = "POOLS" Then
         Call PP_POOLS(numrows, Sheet1)
      ElseIf SectionName = "PROC" Then
         Call PP_PROC(numrows, Sheet1)
      ElseIf SectionName = "PROCAIO" Then
         Call PP_PROCAIO(numrows, Sheet1)
      ElseIf Left$(SectionName, 3) = "RAW" Then
         Call PP_RAW(numrows, Sheet1)
      ElseIf SectionName = "SUMMARY" Then
         Call PP_SUMMARY(numrows, Sheet1)
      ElseIf SectionName = "TOP" Then
         Call PP_TOP(numrows, Sheet1)
      ElseIf SectionName = "VM" Then
         Call PP_VM(numrows, Sheet1)
      ElseIf SectionName = "UARG" Then
         Call PP_UARG(numrows, Sheet1)
      ElseIf Left$(SectionName, 3) = "WLM" Then
         Call PP_WLM(numrows, Sheet1)
      ElseIf SectionName = "ZZZZ" Then
         Call PP_ZZZZ(numrows, Sheet1)
         Exit Do   'ignore anything after the ZZZZ section
      Else
         Call PP_DEFAULT(numrows, Sheet1)
      End If
             
   Else
      If SectionName = "ERROR" Then   'ERROR section doesn't have a header
         Sheets.Add.Name = SectionName
         Set Sheet1 = Worksheets(SectionName)
         Section.Copy Sheet1.Range("A" & CStr(copyStart))
         Application.CutCopyMode = False
      Else
         If StrayLines = 0 Then
            ErrMsg = "Some lines discarded"
            Sheets.Add.Name = "StrayLines"
            Set StraySheet = Worksheets("StrayLines")
            StraySheet.Range("B1") = "Following lines discarded after parsing"
         End If
         If SectionName <> "" And StrayLines < 50 Then
            StrayLines = StrayLines + 1
            StraySheet.Cells(StrayLines + 1, 1) = SectionName
            StraySheet.Cells(StrayLines + 1, 2).Resize(numrows, ColNum).Value = Section.Value
            Application.CutCopyMode = False
         End If
      End If
   End If
EndSect:
      ' go to the next worksheet if we have reached the max number of allowed rows per sheet
      If m_CurrentRow >= MaxRows And BigData Then
         m_StartRow = 1
         m_CurrentRow = 1
         lastSection = Section.Rows.Count
         Application.DisplayAlerts = False
         Book1.Worksheets(1).Delete
         Application.DisplayAlerts = True
         worksheetnum = 1
         Set RawData = Book1.Worksheets(1)
      ElseIf m_CurrentRow >= MaxRows Then
         ' data is now truncated if BIGDATA is not set to YES
         Exit Do
      Else
         lastSection = 0
      End If
Loop Until SectionName = ""

If NumCPUs = 0 Then Exit Sub
                                       'produce the CPU_SUMM and SYS_SUMM sheets
Call SYS_SUMM
Call CPU_SUMM(numrows, CPUList())
Call DISKBUSYRK
                                       'finish up
FinishUp:
Call TidyUp(CPUList())
                                       'Convert, print/publish the charts if necessary
If Output <> "CHARTS" Then Call OutputPICS
If pivot Then Call CreatePivot
If Worksheets(1).Name <> "SYS_SUMM" And SheetExists("ZZZZ") Then
   Worksheets(1).Move After:=Sheets("ZZZZ")
End If
                                       'finish up
If SheetExists("AAA") Then
    If SheetExists("a") Then
        Application.DisplayAlerts = False
        Book1.Worksheets("a").Delete
    End If
         
    m_Elapsed = Timer() - m_Elapsed
    Set Section = Sheets("AAA").Range("A1").End(xlDown)
    Section.Offset(1, 0) = "elapsed"
    Section.Offset(1, 1) = Format(m_Elapsed, "#.00") & " seconds"
    UserForm1.Label1.Caption = "Analysis Complete (" & m_Elapsed & " seconds)"
    UserForm1.Repaint
         
    Application.DisplayAlerts = True
    
    If (StrayLines > 0) And (NumCPUs > 0) Then
        Sheets("StrayLines").Move After:=Sheets("AAA")
    End If
End If
End Sub
                                       'last mod v3.2.0
Sub OutputPICS()
Dim temp As String
Dim Chart1 As ChartObject
Dim i As Long, j As Long, k As Long
Dim MyCharts As Worksheet
Dim myRange As Range
Dim nc As Integer                      'number of charts on Charts page
Dim Output_Filename As String          'name for HTML output
Dim pageDepth As Integer               'number of rows that can fit on a printed page
Dim PicRows(400) As Long               'location of bitmaps for setting page breaks
Dim myVar As Variant                   'temp var
Dim splitpos As String
'Public Summary As String
Dim Sheet1 As Worksheet
Dim Lr As Long

UserForm1.Label1.Caption = "Converting charts to pictures"
UserForm1.Repaint
                                       'Create a chart sheet
Sheets.Add.Name = "Charts"
Set MyCharts = Worksheets("Charts")
MyCharts.Move Before:=Worksheets(1)
If LScape Then MyCharts.PageSetup.Orientation = xlLandscape
                                       'now move each chart to the charts sheet
i = 1: nc = 0: myVar = True
For Each Sheet1 In ActiveWorkbook.Sheets
   For Each Chart1 In Sheet1.ChartObjects
      nc = nc + 1
      Chart1.Chart.CopyPicture Appearance:=xlScreen, Format:=xlPicture, Size:=xlScreen
      
      ' sometimes the MyCharts.Cells call will fail, so catch the error and try the next row until it succeeds (@RM - 2/11/2015)
ErrorHandler:
      On Error Resume Next
      Set myRange = MyCharts.Cells(i, 1)
      If Err.Number <> 0 Then
        i = i + 1
        GoTo ErrorHandler
      End If
      Err.Number = 0
      
      MyCharts.Paste Destination:=myRange
      i = i + Chart1.BottomRightCell.row - Chart1.TopLeftCell.row + 1
      PicRows(nc) = i
      Chart1.Delete
    Next
Next
If Output = "PICTURES" Then
   Exit Sub
ElseIf Output = "PRINT" Then
                                       'PRINT option - adjust horizontal page breaks
   With ActiveSheet.PageSetup
      .CenterHeader = "&""Arial,Bold""&14" & Host & " " & RunDate
      .CenterHorizontally = True
      .CenterVertically = True
      .LeftFooter = "NMON " & progname
      .RightFooter = "Analyser " & Analyser
   End With
   If nc > 1 Then
                                          'make sure that a chart doesn't span pages
      ActiveWindow.View = xlPageBreakPreview
      temp = MyCharts.HPageBreaks(1).Location.Address(True, True, xlR1C1)
      pageDepth = Mid(temp, 2, InStr(1, temp, "C") - 2) - 1
      MyCharts.Cells(nc * pageDepth, 1) = "break"
      UserForm1.Label1.Caption = "Adjusting horizontal page breaks"
      UserForm1.Repaint
                                          'by dynamically adjusting the pagebreaks
      i = pageDepth: k = 1
      For j = 2 To nc
         If PicRows(j) >= i Then
            Set MyCharts.HPageBreaks(k).Location = Cells(PicRows(j - 1), 1)
            k = k + 1
            i = PicRows(j - 1) + pageDepth
         End If
      Next
      MyCharts.Cells(nc * pageDepth, 1).Clear
   End If
   If Printer = "PREVIEW" Then
      UserForm1.Hide
      ActiveSheet.PrintPreview
      UserForm1.Show
   Else
      ActiveSheet.PrintOut Copies:=Copies, ActivePrinter:=Printer
   End If
   ActiveWindow.View = xlNormalView
                                          'publish pictures to the web
ElseIf Output = "WEB" Then
   UserForm1.Label1.Caption = "Generating HTML"
   UserForm1.Repaint
                                       'construct the output filename
   Output_Filename = Left(Filename, InStrRev(Filename, ".")) & "nmon.htm"
   If WebDir <> "" Then
      splitpos = Len(Output_Filename) - InStrRev(Output_Filename, "\")
      Output_Filename = WebDir & Right(Output_Filename, splitpos)
   End If
                                       'and generate html/bitmaps
   ActiveWorkbook.WebOptions.AllowPNG = PNG
   ActiveWorkbook.WebOptions.OrganizeInFolder = SubDir
   With ActiveWorkbook.PublishObjects.Add(SourceType:=xlSourceSheet, _
      Filename:=Output_Filename, Sheet:="Charts", Source:="", _
      HtmlType:=xlHtmlStatic, Title:=Host & " " & RunDate)
      .Publish (True)
'     .AutoRepublish = False   (not supported on Excel 2000)
   End With
End If

End Sub
                                       'last mod v3.3.g2
Sub PP_AAA(numrows As Long, Sheet1 As Worksheet)
'Public Host As String                  Hostname from AAA sheet
'Public Linux as Variant                True if Linux
'Public progname As String              Version of NMON/topas
'Public RunDate As String               NMON run date from AAA sheet
Dim i As Long
Dim Labels As Range
Dim temp As String
Dim TimeAAA As Variant
                                      'Delete any notes
Set Labels = Sheet1.Range("A1:B" & CStr(numrows))
For i = numrows To 1 Step -1
   If Left(Labels.Cells(i, 1), 4) = "note" Then
   Labels.Rows(i).EntireRow.Delete
   numrows = numrows - 1
   End If
Next i

Sheet1.Columns(1).Font.Bold = True
Sheet1.Columns(1).AutoFit
Sheet1.Columns(2).ColumnWidth = 10
Sheet1.Columns(3).AutoFit
Sheet1.Columns(4).AutoFit
Labels.CreateNames Top:=False, Left:=True, bottom:=False, Right:=False
Sheet1.Range("Date").NumberFormat = "dd-mmm-yy"
Sheet1.Range("time").NumberFormat = "hh:mm:ss"
                                        'start time for batch summary
Start = DateValue(Sheet1.Range("date"))
TimeAAA = Sheet1.Range("time")
If Not IsNumeric(TimeAAA) Then TimeAAA = TimeValue(TimeAAA)
Start = Start + TimeAAA

ActiveWorkbook.Names("time").Delete     'strange Excel bug fix
Host = Sheet1.Range("Host").Value

progname = Sheet1.Range("progname").Value
RunDate = Sheet1.Range("Date").Value
Snapshots = Sheet1.Range("snapshots").Value
                                       'adjust first/last values if required for this file
'If Last > Snapshots Then Last = Snapshots
If First >= Snapshots Or Last < First + 1 Or First = 0 Then
   If Batch = 0 Then MsgBox ("Invalid values for FIRST/LAST - values reset to 1/999999")
   First = 1
   Last = 999999
End If
                                       'record settings in output file
Labels(numrows + 1, 1) = "analyser"
Labels(numrows + 1, 2) = Analyser
Labels(numrows + 2, 1) = "environment"
Labels(numrows + 2, 2) = "Excel " & Application.Version & " on " & Application.OperatingSystem
temp = "BATCH=" & CStr(Batch)
temp = temp + ",FIRST=" & CStr(First) & ",LAST=" & CStr(Last)
temp = temp + ",GRAPHS=" & Graphs
temp = temp + ",OUTPUT=" & Output
temp = temp + ",CPUmax=" & CStr(CPUmax)
temp = temp + ",MERGE=" & Merge
temp = temp + ",NOTOP=" & NoTop
temp = temp + ",PIVOT=" & pivot
temp = temp + ",REORDER=" & Reorder
temp = temp + ",TOPDISKS=" & CStr(TopDisks)
Labels(numrows + 3, 1) = "parms"
Labels(numrows + 3, 2) = temp
temp = "GWIDTH = " & CStr(cWidth)
temp = temp + ",GHEIGHT=" & CStr(cHeight)
temp = temp + ",LSCAPE=" & LScape
temp = temp + ",REPROC=" & ReProc
temp = temp + ",SROTDEFAULT=" & SortDefault
'temp = temp + ",SORTINP=" & SortInp
Labels(numrows + 4, 1) = "settings"
Labels(numrows + 4, 2) = temp
Sheet1.Range("B1:B" & CStr(numrows)).HorizontalAlignment = xlLeft
                                        'see if we have a Linux system
Set Labels = Sheet1.UsedRange.Find("Linux", LookAt:=xlWhole)
Linux = Not (Labels Is Nothing)
                                        'check if this is topas
Set Labels = Sheet1.UsedRange.Find("PTX:", LookAt:=xlPart)
topas = Not (Labels Is Nothing)

On Error Resume Next
Steal = (Sheet1.Range("steal").Value = 1)
      
End Sub
                                       'v3.3.g2
Sub PP_BBB(numrows As Long, Sheet1 As Worksheet)
Dim aa0 As String
Dim i As Long
Dim MyCells As Range
Dim temp As Boolean
                                        'sort the data
Sheet1.UsedRange.Sort Key1:=Sheet1.Range("A1"), Order1:=xlAscending, _
   Header:=xlNo, OrderCustom:=1, MatchCase:=False, Orientation:=xlTopToBottom
Sheet1.Columns("A").EntireColumn.Delete

Select Case Sheet1.Name
 Case "BBBB", "BBBL", "BBBN", "BBBVG"
   Sheet1.Columns(1).AutoFit
 Case "BBBC"
                                        'change to fixed pitch font
   Set MyCells = Sheet1.Range("A1:A" & CStr(numrows))
   MyCells.Font.Name = BBBFont
                                        'change fonts for hdisk/paging lines
   For i = numrows To 1 Step -1
      aa0 = MyCells.Item(i, 1).Value
      If Left(aa0, 5) = "hdisk" Then
         MyCells.Item(i, 1).Font.Bold = True
      End If
   Next i
     
 Case "BBBD"
   Sheet1.Columns("A").ColumnWidth = 14.5
   Sheet1.Columns("D").ColumnWidth = 17
   Sheet1.Rows(2).Font.Bold = True
   Set MyCells = Sheet1.Range("B3:B" & CStr(numrows))
   For i = 1 To numrows
       MyCells(i, 1) = MyCells(i, 1).Value
   Next i
 Case "BBBE"
   Sheet1.Rows(2).Font.Bold = True
   m_GotESS = True
                                        'define the lookup table for ESS analysis
   If Sheet1.Range("B2") = "Name" Then
         ActiveWorkbook.Names.Add Name:="VPATHS", RefersTo:="=BBBE!B3:IV" & CStr(numrows)
      Else
         ActiveWorkbook.Names.Add Name:="VPATHS", RefersTo:="=BBBE!C3:IV" & CStr(numrows)
      End If
 Case "BBBF"
   Sheet1.Columns(3).AutoFit
 Case "BBBP"
   Sheet1.Columns(1).AutoFit
                                        'change to fixed pitch font
   Set MyCells = Sheet1.Columns("B:C")
   MyCells.Font.Name = BBBFont
                                        'check for SMT mode
   Set MyCells = Sheet1.UsedRange.Find("PowerPC_Power", LookAt:=xlPart)
   SMTon = Not (MyCells Is Nothing)
   If SMTon Then
      Set MyCells = Sheet1.UsedRange.Find("-SMT-8", LookAt:=xlPart)
      SMTon = Not (MyCells Is Nothing)
      If SMTon Then
         SMTmode = 8
      Else
        Set MyCells = Sheet1.UsedRange.Find("-SMT-4", LookAt:=xlPart)
        SMTon = Not (MyCells Is Nothing)
        If SMTon Then
           SMTmode = 4
        Else
           Set MyCells = Sheet1.UsedRange.Find("-SMT", LookAt:=xlPart)
           SMTon = Not (MyCells Is Nothing)
           If SMTon Then SMTmode = 2
        End If
      End If
   Else
      Set MyCells = Sheet1.UsedRange.Find("-SMT", LookAt:=xlPart)
      SMTon = Not (MyCells Is Nothing)
      If SMTon Then SMTmode = 2
   End If
   
   Set MyCells = Sheet1.UsedRange.Find("Shared-", LookAt:=xlPart)
    If Not (MyCells Is Nothing) Then
       If CPUmax = 0 Then CPUmax = SMTmode 'set CPUmax for Shared LPARs
    End If
 Case "BBBR"
   Sheet1.Columns(1).NumberFormat = "h:mm:ss"
 Case "BBBV"
                                        'change to fixed pitch font
   Set MyCells = Sheet1.Range("A1:A" & CStr(numrows))
   MyCells.Font.Name = BBBFont
End Select
            
End Sub
                                       'last mod v3.3.g1
Sub PP_CPU(numrows As Long, Sheet1 As Worksheet)
Dim Chart1 As ChartObject               'New Chart object
Dim MyCells As Range                    'temp var
                                        'quick fix to missing header problem
If Sheet1.Name = "CPU_ALL" And Sheet1.Range("B1") <> "User%" Then
   Sheet1.Rows(1).Insert
   Sheet1.Range("A1").Value = "CPU Total " & Worksheets("AAA").Range("Host").Value
   Sheet1.Range("B1").Value = "User%"
   Sheet1.Range("C1").Value = "Sys%"
   Sheet1.Range("D1").Value = "Wait%"
   Sheet1.Range("E1").Value = "Idle%"
   If Steal Then
        Sheet1.Range("F1").Value = "Steal%"
   End If
    
   Sheet1.Range("K1").Value = "CPUs"    ' @RM moved column G to K to give space for future columns
   numrows = numrows + 1
End If
                                        'save number of intervals for later
If CPUrows = 0 Then
   t1 = Sheet1.Range("A2")
                                        'bodge for Linux
   If (Linux And t1 = "T0002") Then
      t1 = "T0001"
      Sheet1.Rows(2).Insert
      Sheet1.Range("A2").Value = t1
      numrows = numrows + 1
   End If
   CPUrows = numrows
End If
                                        'handle missing intervals for dLPAR
If numrows < CPUrows Then
   Sheet1.Range("A2", "G" & CStr(CPUrows - numrows + 1)).EntireRow.Insert
   Sheet1.Range("A2").Value = t1
   numrows = CPUrows
   dLPAR = True
End If
Call DelInt(Sheet1, numrows, 1)
                                        'Calculate CPU totals for graphs
Sheet1.Range("J1").Value = "CPU%"       ' @RM moved column F to J
Sheet1.Range("J2").Value = "=IF(B2="""","""",B2+C2)"
Set MyCells = Sheet1.Range("J2:J" & CStr(numrows))
MyCells.FillDown
MyCells.Value = MyCells.Value
       
Sheet1.Cells(numrows + 2, 1) = "Avg"
Sheet1.Cells(numrows + 2, 2) = "=AVERAGE(B2:B" & CStr(numrows) & ")"
Set MyCells = Sheet1.Range("B" & CStr(numrows + 2) & ":J" & CStr(numrows + 2))
MyCells.FillRight
MyCells.Value = MyCells.Value
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
                                        'Produce a graph of CPU components
                                        
' @RM this previously did not include Idle%, but now includes Idle% and Steal% if it exists
If Steal Then
    Set MyCells = Sheet1.Range("A1..F" & CStr(numrows))
Else
    Set MyCells = Sheet1.Range("A1..D" & CStr(numrows))
End If

Set Chart1 = Sheet1.ChartObjects.Add(cLeft, cTop + numrows * rH, cWidth, cHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlArea, _
CategoryLabels:=1, SeriesLabels:=1, Title:=Sheet1.Range("A1").Value & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
   If Left(Sheet1.Name, 3) = "CPU" Then .Axes(xlValue).MaximumScale = 100
   Call ApplyStyle(Chart1, 2, 3)
   ' force the colors to the desired ones rather than taking the defaults
   .SeriesCollection(1).Interior.Color = RGB(0, 0, 255)     ' User% = blue
   .SeriesCollection(2).Interior.Color = RGB(128, 0, 0)     ' Sys = dark red
   .SeriesCollection(3).Interior.Color = RGB(0, 128, 64)    ' Wait% = blue
   If Steal Then
        .SeriesCollection(4).Interior.Color = RGB(192, 192, 192) ' Idle% = grey
        .SeriesCollection(5).Interior.Color = RGB(255, 255, 0) ' Steal%= Yellow
   End If
    
End With



If Sheet1.Range("K2") = "" Then Exit Sub    ' @RM moved column G to K to give space for future columns
                                        
                                        'produce a graph of CPU count
If Sheet1.Name = "CPU_ALL" And SMTon Then Sheet1.Range("K1") = "Logical CPUs (SMTmode=" & CStr(SMTmode) & ")"
Set MyCells = Sheet1.Range("K1:K" & CStr(numrows))   ' @RM moved column G to K to give space for future columns
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop2 + numrows * rH, cWidth, cHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlArea, _
   SeriesLabels:=1, HasLegend:=True
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(CPUrows, 1))
   Call ApplyStyle(Chart1, 2, 1)
   .HasTitle = False
      ' force the colors to the desired ones rather than taking the defaults
   .SeriesCollection(1).Interior.Color = RGB(0, 0, 255)     ' User% = blue
   .SeriesCollection(2).Interior.Color = RGB(128, 0, 0)     ' Sys = dark red
   .SeriesCollection(3).Interior.Color = RGB(0, 128, 64)    ' Wait% = blue
   If Steal Then
        .SeriesCollection(4).Interior.Color = RGB(192, 192, 192) ' Idle% = grey
        .SeriesCollection(5).Interior.Color = RGB(255, 255, 0) ' Steal%= Yellow
   End If
End With
End Sub
                                       'last mod v3.3.g2
Sub CPU_SUMM(numrows As Long, CPUList() As String)
Dim aa0 As String
Dim Chart1 As ChartObject               'new chart object
Dim CPUData As Range                    'data to be charted
Dim n As Integer                        'loop counter
Dim SectionName As String               'constant = "CPU_SUMM"
Dim Sheet1 As Worksheet                 'pointer to CPU_SUMM sheet
                                        'Produce a sheet containing summary data
numrows = Worksheets("AAA").Range("snapshots")
If Last < numrows Then numrows = Last
numrows = numrows - First + 1

SectionName = "CPU_SUMM"
UserForm1.Label1.Caption = "Creating: " & SectionName
UserForm1.Repaint
CPUrows = numrows

Sheets.Add.Name = SectionName
If SheetExists("CPU_ALL") Then Sheets(SectionName).Move After:=Worksheets("CPU_ALL")
Set Sheet1 = Worksheets(SectionName)
Sheet1.Range("A1").Value = SectionName
Sheet1.Range("B1").Value = "User%"
Sheet1.Range("C1").Value = "Sys%"
Sheet1.Range("D1").Value = "Wait%"
Sheet1.Range("E1").Value = "Idle%"
If Steal Then
    Sheet1.Range("F1").Value = "Steal%"
End If

Application.Calculation = xlCalculationManual
For n = 1 To NumCPUs
   Sheet1.Cells(n + 1, 1) = "CPU" & Format(Mid(CPUList(n), 4), "0##")
   Sheet1.Cells(n + 1, 2) = "=" & CPUList(n) & "!B" & CStr(CPUrows + 3)
Next n

If Steal Then
    Set CPUData = Sheet1.Range("B2:F" & CStr(NumCPUs + 1))
Else
    Set CPUData = Sheet1.Range("B2:D" & CStr(NumCPUs + 1))
End If
    
CPUData.FillRight
Application.Calculation = xlCalculationAutomatic
Application.Calculate
CPUData.Value = CPUData.Value
CPUData.NumberFormat = "#0.0"
Sheet1.Columns("A:IV").Sort Key1:=Sheet1.Range("A1"), Order1:=xlAscending, Header:=xlYes

If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
                                        'and now produce a graph by CPU/Thread
aa0 = " Processor "
If SMTon Then aa0 = " Thread "
If Steal Then
    Set CPUData = Sheet1.Range("A1:F" & CStr(NumCPUs + 1))
Else
    Set CPUData = Sheet1.Range("A1:D" & CStr(NumCPUs + 1))
End If
    
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, cTop + NumCPUs * rH, cWidth, cHeight)
Chart1.Chart.ChartWizard Source:=CPUData, PlotBy:=xlColumns, _
   CategoryLabels:=1, SeriesLabels:=1, _
   Title:="CPU by" & aa0 & Host & "  " & RunDate & "    (" & CStr(NumCPUskipped) & " threads not shown)"
                                        'apply customisation
With Chart1.Chart
     .Axes(xlValue).MaximumScale = 100
     Call ApplyStyle(Chart1, 0, 3)
      ' force the colors to the desired ones rather than taking the defaults
     .SeriesCollection(1).Interior.Color = RGB(0, 0, 255)     ' User% = blue
     .SeriesCollection(2).Interior.Color = RGB(128, 0, 0)     ' Sys = dark red
     .SeriesCollection(3).Interior.Color = RGB(0, 128, 64)    ' Wait% = blue
     If Steal Then
        .SeriesCollection(4).Interior.Color = RGB(192, 192, 192) ' Idle% = grey
        .SeriesCollection(5).Interior.Color = RGB(255, 255, 0) ' Steal%= Yellow
     End If
End With

Sheet1.Range("B2").Select
ActiveWindow.FreezePanes = True
Sheet1.Range("A1").Select
ActiveWindow.ScrollRow = NumCPUs + 2
End Sub
                                      
Sub PP_DEFAULT(numrows As Long, Sheet1 As Worksheet)
Dim Chart1 As ChartObject               'new chart object
Dim Graphdata As Range                  'range for charting
'Public Host As String                  'Hostname from AAA sheet
'Public LastColumn As String
'Public RunDate As String               'NMON run date from AAA sheet
Dim SectionName As String
    
SectionName = Sheet1.Name
If Application.WorksheetFunction.Max(Sheet1.Range("B2:IV" & CStr(numrows))) = 0 Then
   Application.DisplayAlerts = False
   Sheet1.Delete
   Application.DisplayAlerts = True
   Exit Sub
End If
Call DelInt(Sheet1, numrows, 1)
If numrows < 1 Then Exit Sub
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
If SectionName = "NPIV" Or SectionName = "SEACLITRAFFIC" Then
    Exit Sub
End If

'produce avg/max graph
' @RM - The SortDefault setting is passed to avgmax last parm to indicate if we should sort the data or not
If SortDefault Then
    Set Graphdata = avgmax(numrows, Sheet1, 1)
Else
    Set Graphdata = avgmax(numrows, Sheet1, 0)
End If

   Sheet1.Range("B1:" & LastColumn & CStr(numrows + 5)).Sort _
    Key1:=Sheet1.Range("B" & CStr(numrows + 5)), Order1:=xlDescending, _
    Header:=xlYes, OrderCustom:=1, MatchCase:=False, Orientation:=xlLeftToRight

Set Graphdata = Sheet1.Range("A" & CStr(numrows + 2) & ":" & LastColumn & CStr(numrows + 4))

Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + numrows * rH, cWidth, cHeight)
Chart1.Chart.ChartWizard Source:=Graphdata, PlotBy:=xlRows, SeriesLabels:=1, _
    Title:=Sheet1.Range("A1").Value & "  " & RunDate
With Chart1.Chart                      'apply customisation
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(1, 2), Cells(1, ColNum))
   Call ApplyStyle(Chart1, 0, 3)
End With
                                        'produce line graph
Set Graphdata = Sheet1.Range("A1:" & LastColumn & CStr(numrows))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop2 + rH * numrows, cWidth, cHeight)
Chart1.Chart.ChartWizard Source:=Graphdata, Gallery:=xlLine, Format:=2, _
    Title:=Sheet1.Range("A1").Value & "  " & RunDate, _
    CategoryLabels:=1, SeriesLabels:=1, HasLegend:=True
                                        'apply customisation
With Chart1.Chart
   Call ApplyStyle(Chart1, 1, ColNum - 1)
End With
      
End Sub
                                       'last mod v3.3.0
Sub PP_DG(numrows As Long, Sheet1 As Worksheet)
    Dim SectionName As String
    
    SectionName = Sheet1.Name
    
    'see if we have an EMC system, this could be named, 'power', 'emcpower' or 'hdiskpower
    ' emc check is broke
    Call CheckEsoteric(Sheet1)

    Call DelInt(Sheet1, numrows, 1)
    Call DiskGraphs(numrows, SectionName, True)
End Sub
                                       'v3.3.g1
Sub PP_DISK(numrows As Long, Sheet1 As Worksheet)
Dim aa0 As String                   'temp var
Dim DelRange As Range               'Columns to be deleted
Dim fed As Integer                  'column number of first esoteric
Dim found As Variant                'return value from find method
Dim led As Integer                  'column number of last esoteric
Dim MyCells As Range                'temp var
Dim n As Integer                    'temp var
Dim NewName As String               'new name for the EMC sheet
Dim NewSheet As Worksheet
Dim SectionName As String
    
SectionName = Sheet1.Name
                               
'see if we have an EMC system, this could be named, 'power', 'emcpower' or 'hdiskpower
' emc check is broke
 Call CheckEsoteric(Sheet1)
                                                                            'fix for topas design error
If SectionName = "DISKRXFER" Then
   Sheet1.Range("A1").EntireRow.Insert
   Sheet1.Range(Cells(numrows + 1, 1), Cells(numrows + 1, MaxCols)).Copy Destination:=Sheet1.Range("A1")
   Sheet1.Range(Cells(numrows + 1, 1), Cells(numrows + 1, MaxCols)).ClearContents
End If

Call DelInt(Sheet1, numrows, 1)
                                        'see if we have any esoterics on this sheet
Set found = Nothing
If m_GotEMC Then Set found = Sheet1.Range("A1:IV1").Find(m_Esoteric, LookAt:=xlPart)
   
If Not found Is Nothing Then
    fed = found.Column
    If m_Esoteric = "dac" Then NewName = "FASt" Else NewName = "EMC"
    NewName = NewName & Right(SectionName, Len(SectionName) - 4)
                        
    'sort the sheet to get the esoterics into one block
    aa0 = ConvertRef(fed - 1)
    Sheet1.Range(aa0 & "1:" & LastColumn & CStr(numrows)).Sort _
       Key1:=Sheet1.Range(aa0 & "1"), Order1:=xlAscending, _
       Header:=xlYes, OrderCustom:=1, MatchCase:=False, Orientation:=xlLeftToRight
    Set found = Sheet1.Rows(1).Find(m_Esoteric, LookAt:=xlPart)
    fed = found.Column
                                         'create the new sheet
    Sheet1.Copy After:=Sheets(Sheets.Count)
    Sheets.Item(Sheets.Count).Name = NewName
    Set NewSheet = Worksheets(NewName)
                                         'delete leading hdisks from new sheet
    If fed > 2 Then
        Set DelRange = NewSheet.Range("B1:" & ConvertRef(fed - 2) & "1")
        DelRange.EntireColumn.Delete
    End If
                                    
                                        'delete the esoterics from the DISK sheet
    UserForm1.Label1.Caption = "Analysing: " & NewName
    UserForm1.Repaint
    Set DelRange = Sheet1.Range("B1:IU1")
    For n = fed To 254
        If Left(DelRange(1, n).Value, Len(m_Esoteric)) = m_Esoteric Then
            led = led + 1
        Else
            Exit For
        End If
    Next n
    led = led + fed
    Set DelRange = Sheet1.Range(DelRange.Cells(1, fed - 1), DelRange.Cells(1, led - 1))
    DelRange.EntireColumn.Delete
                                         'delete any trailing hdisks from the new sheet
    If led < 253 Then
        Set DelRange = NewSheet.Range(ConvertRef(led - fed + 2) & "1:IU1")
        DelRange.EntireColumn.Delete
    End If
End If
                                        'do we still have data on the DISK sheet?
If Sheet1.Range("B1") <> "" Then
   Call GetLastColumn(Sheet1, 1)
   If Left(SectionName, 8) = "DISKWAIT" Then Call PP_DISKWAIT(numrows, Sheet1)
   Call DiskGraphs(numrows, SectionName, Not m_GotESS)
                                 
                                 'put in a totals column for DISK_SUMM
   Sheet1.Range("IV1") = "Totals"
   Set MyCells = Sheet1.Range("IV2:IV" & CStr(numrows))
   MyCells(1, 1) = "=SUM(B2:" & LastColumn & "2)"
   MyCells.FillDown
   MyCells.Value = MyCells.Value
   If Left(SectionName, 8) = "DISKXFER" Then Call PP_DISKXFER(numrows, SectionName)
End If
                                        'did we create an new sheet?
If Not found Is Nothing Then
   NewSheet.Range("B1:IV1").HorizontalAlignment = xlRight
   Call GetLastColumn(NewSheet, 1)
   If Left(SectionName, 8) = "DISKWAIT" Then Call PP_DISKWAIT(numrows, NewSheet)
   Call DiskGraphs(numrows, NewName, True)
End If
             
End Sub
                                       'unreleased
Sub PP_DISKWAIT(numrows As Long, Sheet1 As Worksheet)
Dim aa0 As String                      'temp var
Dim aa1 As String                      'temp var
Dim found As Variant                   'results of find method
Dim hdisk As String                    'name of current hdisk
Dim MyCells As Range                   'temp var
Dim n As Long                          'temp var
Dim RespName As String                 'name of RESP sheet
Dim RespSheet As Worksheet             'RESP sheet
Dim ServName As String                 'name of SERV sheet
Dim sRange As Range                    'header row on SERV sheet
Dim WaitName As String                 'name of WAIT sheet
Dim SectionName As String              'name of DISK/EMC/FAS sheet
    
Exit Sub
'not implemented due to performance impact.   Possibly need to add parameter.
'Better solution is to defer sorting disk sheets until end of analysis

WaitName = Sheet1.Name
RespName = Replace(WaitName, "WAIT", "RESP")
ServName = Replace(WaitName, "WAIT", "SERV")
                                       'create the new sheet
Sheet1.Copy After:=Sheets(Sheets.Count)
Sheets.Item(Sheets.Count).Name = RespName
Set RespSheet = Worksheets(RespName)
RespSheet.Cells(1, 1) = Replace(RespSheet.Cells(1, 1).Value, "Wait Queue", "Response")
                                       'build the formulas
Set MyCells = Worksheets(RespName).Range("A1:IV65300")
Set sRange = Worksheets(ServName).Range("A1:IV1")
For n = 2 To MaxCols                       'for each hdisk/vpath
   If MyCells(1, n) = "" Then Exit For
   hdisk = MyCells(1, n)
                                        'find out where the busy data is
   Set found = sRange.Find(hdisk, LookAt:=xlWhole)
   aa0 = found.AddressLocal(False, True)
   aa0 = ServName & "!" & Left(aa0, Len(aa0) - 1) & "2"
   aa1 = WaitName & "!$" & ConvertRef(n - 1) & "2"
   MyCells(2, n) = "=" & aa0 & "+" & aa1
Next
Set MyCells = RespSheet.Range("B2:" & LastColumn & CStr(numrows))
MyCells.FillDown
MyCells.Value = MyCells.Value

Call DiskGraphs(numrows, RespName, Not m_GotESS)
             
End Sub
                                    'last mod v3.3.F
Sub PP_DISKXFER(numrows As Long, SectionName As String)
Dim aa0 As String                       'temp var
Dim Chart1 As ChartObject               'new chart object
'Public Host As String                  'Hostname from AAA sheet
'Public LastColumn As String            'last column letter
Dim MyCells As Range                    'temp var
Dim n As Integer                        'temp var
'Public NumDisk as Integer              'number of disk subsections
'Public RunDate As String               'NMON run date from AAA sheet
Dim shDisk As Worksheet                 'pointer to DISK_SUMM sheet
Dim shREAD As Worksheet                 'pointer to DISKREAD sheet
Dim shWRITE As Worksheet                'pointer to DISKWRITE sheet
                                            
If Len(SectionName) = 8 Then            'If this is the first DISKXFER Sheet
                                        'Produce a sheet summarising data + I/O rates
   UserForm1.Label1.Caption = "Creating: " & "DISK_SUMM"
   UserForm1.Repaint
   Sheets.Add.Name = "DISK_SUMM"
   Set shDisk = Worksheets("DISK_SUMM")
   Set shREAD = Worksheets("DISKREAD")
   Set shWRITE = Worksheets("DISKWRITE")
                                        'Copy timestamps + create colum heads etc.
   shDisk.Range("A1:A" & CStr(numrows)).Value = shWRITE.Range("A1:A" & CStr(numrows)).Value
   aa0 = shWRITE.Range("A1").Value
   Mid(aa0, 6) = "total"
   shDisk.Range("A1") = aa0
   shDisk.Range("B1") = "Disk Read KB/s"
   shDisk.Range("C1") = "Disk Write KB/s"
   shDisk.Range("D1") = "IO/sec"
   shDisk.Range("B2") = "=DISKREAD!IV2"
   shDisk.Range("C2") = "=DISKWRITE!IV2"
   shDisk.Range("D2") = "=DISKXFER!IV2"
   shDisk.Range("B2:D" & CStr(numrows)).FillDown
   shDisk.Range("B2:D" & CStr(numrows)).Value = shDisk.Range("B2:D" & CStr(numrows)).Value
   shDisk.Columns("B:C").ColumnWidth = 12
                                              'Produce graph of data/IO rate on DISK_SUMM
   If Graphs = "ALL" Or InStr(1, List, "DISK_SUMM") > 0 Then
      Set MyCells = shDisk.Range("A1:C" & CStr(numrows))
      Set Chart1 = shDisk.ChartObjects.Add(cLeft, cTop + rH * numrows, cWidth, cHeight)
      Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlArea, PlotBy:=xlColumns, _
         CategoryLabels:=1, SeriesLabels:=1, Title:=shDisk.Range("A1") & " - " & RunDate
                                           'apply style defaults
      With Chart1.Chart
         Call ApplyStyle(Chart1, 2, 3)
         .SeriesCollection.NewSeries
         With .SeriesCollection(3)
            .AxisGroup = 2
            .ChartType = xlLine
            .Border.Weight = xlMedium
            .Values = shDisk.Range(Cells(2, 4), Cells(numrows, 4))
            .Name = shDisk.Cells(1, 4).Value
         End With
         .Axes(xlValue, xlPrimary).HasTitle = True
         .Axes(xlValue, xlPrimary).AxisTitle.Characters.Text = "KB/sec"
         .Axes(xlValue, xlSecondary).HasTitle = True
         .Axes(xlValue, xlSecondary).AxisTitle.Characters.Text = "IO/sec"
      End With
                                              'produce avg/max graph
      LastColumn = "D"
      Set MyCells = avgmax(numrows, shDisk, 0)
      Set Chart1 = shDisk.ChartObjects.Add(cLeft, csTop2 + numrows * rH, cWidth, cHeight)
      Chart1.Chart.ChartWizard Source:=MyCells, PlotBy:=xlRows, SeriesLabels:=1, _
         Title:=shDisk.Range("A1").Value & "  " & RunDate
      With Chart1.Chart                      'apply customisation
         .SeriesCollection(1).XValues = shDisk.Range(Cells(1, 2), Cells(1, 4))
         Call ApplyStyle(Chart1, 0, 3)
      End With
   End If
                                      
Else                                'I already have a DISK_SUMM sheet so just update the data
    NumDisk = NumDisk + 1
    Set shDisk = Worksheets("DISK_SUMM")
    n = Mid(SectionName, 9)
    Set MyCells = shDisk.Range("B2:D" & CStr(numrows))
    shDisk.Range("E2:G" & CStr(numrows)).Value = MyCells.Value
    aa0 = "READ" & n
    MyCells(1, 1) = "=E2+DISK" & aa0 & "!IV2"
    aa0 = "WRITE" & n
    MyCells(1, 2) = "=F2+DISK" & aa0 & "!IV2"
    aa0 = "XFER" & n
    MyCells(1, 3) = "=G2+DISK" & aa0 & "!IV2"
    MyCells.FillDown
    MyCells.Value = MyCells.Value
    shDisk.Range("E:G").Clear
End If
    
shDisk.Move After:=Sheets(Sheets.Count)      'and move DISK_SUMM after me
         
End Sub
                                       'v3.3.0
Sub PP_DONATE(numrows As Long, Sheet1 As Worksheet)
Dim Chart1 As ChartObject               'new chart object
Dim Graphdata As Range                  'range for charting
'Public Host As String                  'Hostname from AAA sheet
'Public LastColumn As String
'Public RunDate As String               'NMON run date from AAA sheet
Dim SectionName As String
    
SectionName = Sheet1.Name
Call DelInt(Sheet1, numrows, 1)
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
                                        'produce area graph
Set Graphdata = Sheet1.Range("A1:" & LastColumn & CStr(numrows))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + rH * numrows, cWidth, cHeight)
Chart1.Chart.ChartWizard Source:=Graphdata, Gallery:=xlArea, _
    Title:=Sheet1.Range("A1").Value & "  " & RunDate, _
    CategoryLabels:=1, SeriesLabels:=1, HasLegend:=True
                                        'apply customisation
With Chart1.Chart
   Call ApplyStyle(Chart1, 2, ColNum)
End With
      
End Sub
                                       'v3.3.5
Sub PP_ESS(numrows As Long, Sheet1 As Worksheet)
'Public ESSanal As Variant              'True if ESS analysis required
'Public LastColumn As String, ColNum as integer
'Public NumDisk As Integer              'Number of disk subsections
Dim aa0 As String                       'temp var
Dim found As Range                      'result of find method
Dim Host As String                      'name of host system from AAA sheet
Dim MyCells As Range                    'temp var
Dim nDisks As Integer                   'number of hdisks in a vpath
Dim n As Integer, n1 As Integer         'loop counters
Dim rRange As Range, bRange As Range
Dim rString As String, bString As String
Dim SectionName As String               'name of current sheet
Dim vname As String, hdisk As String, vTable As Range

ReDim sRange(NumDisk) As Range          'list of search ranges
SectionName = Sheet1.Name
Call DelInt(Sheet1, numrows, 1)
                                        'if this is the last sheet, do the analysis
If SectionName = "ESSXFER" And ESSanal Then
   UserForm1.Label1.Caption = "Analysing ESS data"
   UserForm1.Repaint
                                               'copy and set up sheets
   Host = Worksheets("AAA").Range("Host").Value
   Sheet1.Copy After:=Sheets(Sheets.Count)
   Worksheets("ESSXFER (2)").Name = "ESSBUSY"
   Worksheets("ESSBUSY").Range("A1") = "ESS %Busy " & Host
   Sheet1.Copy After:=Sheets(Sheets.Count)
   Worksheets("ESSXFER (2)").Name = "ESSBSIZE"
   Worksheets("ESSBSIZE").Range("A1") = "ESS xfer size (Kbytes) " & Host
                                          'define the search range
   Set sRange(0) = Worksheets("DISKBUSY").Range("A1:IV1")
   If NumDisk > 1 Then
      For n = 1 To NumDisk - 1
         Set sRange(n) = Worksheets("DISKBUSY" & CStr(n)).Range("A1:IV1")
      Next n
   End If
        
   Set vTable = Worksheets("BBBE").Range("vPaths")
   Set MyCells = Worksheets("ESSBUSY").Range("B1:IV1")
   Set rRange = Worksheets("ESSBSIZE").Range("B2:IV" & CStr(numrows))
   Set bRange = Worksheets("ESSBUSY").Range("B2:IV" & CStr(numrows))
                                       'and now build the formulas
   For ColNum = 1 To MaxCols               'for each vpath
      rString = "=("
      bString = "=("
      If MyCells(1, ColNum) = "" Then Exit For
      vname = MyCells(1, ColNum)
      nDisks = Application.WorksheetFunction.VLookup(vname, vTable, 2, False)
                                       'for each hdisk in the vpath
      If nDisks > 0 Then
         For n = 1 To nDisks
            hdisk = Application.WorksheetFunction.VLookup(vname, vTable, 2 + n, False)
                                       'find out where the data is
            For n1 = 0 To NumDisk - 1
               Set found = sRange(n1).Find(hdisk, LookAt:=xlWhole)
               If Not found Is Nothing Then Exit For
            Next n1
      
            If found Is Nothing Then
               MsgBox ("Error - unable to locate data for " & hdisk)
            Else
                                         'add to the formula strings
               aa0 = found.AddressLocal(False, True)
               aa0 = "!" & Left(aa0, Len(aa0) - 1) & "2"
               If n1 > 0 Then aa0 = CStr(n1) & aa0
               rString = rString & "+DISKBSIZE" + aa0
               bString = bString & "+DISKBUSY" + aa0
            End If
         Next n
                                                'last hdisk - update cell contents
         rString = rString & ")/" & CStr(nDisks)
         rRange(1, ColNum) = rString
         bString = bString & ")/" & CStr(nDisks)
         bRange(1, ColNum) = bString
      End If
   Next ColNum
                                         'last vpath - complete sheets
   UserForm1.Label1.Caption = "Creating: " & "ESSBSIZE"
   UserForm1.Repaint
   rRange.FillDown
   rRange.Value = rRange.Value
   rRange.NumberFormat = "0.0"
   Call DiskGraphs(numrows, "ESSBSIZE", True)
   UserForm1.Label1.Caption = "Creating: " & "ESSBUSY"
   UserForm1.Repaint
   bRange.FillDown
   bRange.Value = bRange.Value
   bRange.NumberFormat = "0.0"
   Call DiskGraphs(numrows, "ESSBUSY", True)
       
   Call DiskGraphs(numrows, "ESSXFER", True)
Else
   Call DiskGraphs(numrows, SectionName, True)
End If
    
End Sub
                                       'last mod v3.1.0
Sub PP_FILE(numrows As Long, Sheet1 As Worksheet)
Dim MyCells As Range                    'temp var
Dim Chart1 As ChartObject               'new chart object
'Public RunDate As String               'NMON run date from AAA sheet
Dim SectionName As String               'name of current sheet
    
SectionName = Sheet1.Name
Call DelInt(Sheet1, numrows, 1)
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub

                                        'Add Avg/Wavg/Max lines
Set MyCells = avgmax(numrows, Sheet1, 0)
                                        'Produce a graph of readch/writech rates
Set MyCells = Sheet1.Range("E2:F" & CStr(numrows))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlLine, Format:=2, _
   Title:="Kernel Read/Write System Calls " & Host & "  " & RunDate
With Chart1.Chart                    'apply customisation
    .SeriesCollection(1).Name = "readch/sec"
    .SeriesCollection(2).Name = "writech/sec"
    .SeriesCollection(1).XValues = Sheet1.Range(Cells(3, 1), Cells(numrows, 1))
    Call ApplyStyle(Chart1, 1, 2)
End With
                                        'Produce a graph of i-node data
Set MyCells = Sheet1.Range("A1:D" & CStr(numrows))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop2 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlLine, Format:=2, _
   CategoryLabels:=1, SeriesLabels:=1, HasLegend:=True, _
   Title:="Kernel Filesystem Functions " & Host & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
   Call ApplyStyle(Chart1, 1, 3)
End With
    
End Sub
                                       'last mod v3.3.A
Sub PP_FRCA(numrows As Long, Sheet1 As Worksheet)
Dim Chart1 As ChartObject               'new chart object
Dim MyCells As Range                    'range for charting
'Public RunDate As String               'NMON run date from AAA sheet

Call DelInt(Sheet1, numrows, 1)
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
                                        'Produce a graph of cache hits stats
Set MyCells = Sheet1.Range("F1:F" & CStr(numrows))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, cTop + numrows * rH, cWidth, cHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlLine, Format:=2, _
   SeriesLabels:=1, HasLegend:=False, CategoryTitle:="Time of Day", _
   ValueTitle:=Sheet1.Range("F1").Value, _
   Title:=Sheet1.Range("A1").Value & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
   .Axes(xlValue).MaximumScale = 1
   Call ApplyStyle(Chart1, 1, 1)
   .Axes(xlValue).TickLabels.NumberFormat = "0%"
End With
  
End Sub
                                       'last mod v3.3.E
Sub PP_IOADAPT(numrows As Long, Sheet1 As Worksheet)
Dim aa0 As String                       'temp var
Dim Chart1 As ChartObject               'new chart object
Dim CurCol As Long                     'loop counter
Dim Graphdata As Range                  'range for tps graph
'Public LastColumn as String, ColNum as Integer
Dim MyCells As Range                    'temp var
Dim NumAdapt As Long                     'number of I/O adapters on sheet
'Public RunDate As String               'NMON run date from AAA sheet
Dim SectionName As String               'name of current sheet
Dim tpsCol As Range                     'pointer for move
    
SectionName = Sheet1.Name
Call DelInt(Sheet1, numrows, 1)
                                        'Put in the formulas for avg/max
Set Graphdata = avgmax(numrows, Sheet1, 0)

NumAdapt = ColNum / 3
Set MyCells = Sheet1.Range("A1")
                                        'move columns around for graphing
MyCells(1, 1).Value = MyCells(1, 1).Value & " (KB/s)" 'title
For CurCol = 2 To (NumAdapt * 2) + 1 Step 2
                                       'strip off KB/s from read
    aa0 = MyCells(1, CurCol).Value
    MyCells(1, CurCol) = Left(aa0, Len(aa0) - 5)
                                       'strip off KB/s from write
    aa0 = MyCells(1, CurCol + 1).Value
    MyCells(1, CurCol + 1) = Left(aa0, Len(aa0) - 5)
    aa0 = Sheet1.Range("A1").Item(1, CurCol + 2).Address(True, False, xlA1)
    aa0 = Left(aa0, InStr(1, aa0, "$") - 1)
                                       'move tps column to the end
    Set tpsCol = Sheet1.Range(aa0 & "1.." & aa0 & CStr(numrows))
    MyCells(1, ColNum + 1).Resize(numrows, 1).Value = tpsCol.Value
    tpsCol.EntireColumn.Delete
Next CurCol
Sheet1.Range("B:" & LastColumn).ColumnWidth = 12
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
                                        'produce avg/max graph
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=Graphdata, PlotBy:=xlRows, _
SeriesLabels:=1, Title:=Sheet1.Range("A1").Value & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
    .SeriesCollection(1).XValues = Sheet1.Range(Cells(1, 2), Cells(1, ColNum))
    Call ApplyStyle(Chart1, 0, 3)
End With
                                        'produce data rate graph
aa0 = ConvertRef(NumAdapt * 2)
Set Graphdata = Sheet1.Range("A1:" & aa0 & CStr(numrows))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop2 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=Graphdata, Gallery:=xlArea, _
    CategoryLabels:=1, SeriesLabels:=1, _
    Title:=Sheet1.Range("A1").Value & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
    Call ApplyStyle(Chart1, 2, NumAdapt * 2)
End With
                                        'produce tps graph
aa0 = Sheet1.Range("A1").Item(1, ColNum - (NumAdapt - 1)).Address(True, False, xlA1)
aa0 = Left(aa0, InStr(1, aa0, "$") - 1)
Set Graphdata = Sheet1.Range(LastColumn & "1:" & aa0 & CStr(numrows))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop3 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=Graphdata, Gallery:=xlArea, _
    Title:="Disk Adapter " & Host & " (tps) - " & RunDate, _
    SeriesLabels:=1, HasLegend:=True

With Chart1.Chart                    'apply customisation
    .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
    Call ApplyStyle(Chart1, 2, NumAdapt)
End With
    
End Sub
                                       'v3.3.A
Sub PP_LAN(numrows As Long, Sheet1 As Worksheet)
Dim aa0 As String                       'temp var
Dim Chart1 As ChartObject               'new chart object
Dim Graphdata As Range                  'range for avg/max data
'Public LastColumn as String, ColNum as Integer
Dim MyCells As Range                    'temp var
Dim NumAdapt As Long                    'number of I/O adapters on sheet
'Public RunDate As String               'NMON run date from AAA sheet
    
Call DelInt(Sheet1, numrows, 1)
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
                                        'Put in the formulas for avg/max
Set Graphdata = avgmax(numrows, Sheet1, 0)
NumAdapt = (ColNum - 1) / 5
                                        'produce avg/max graph
Set MyCells = Graphdata.Offset(0, NumAdapt * 2 + 1)
Set MyCells = MyCells.Resize(3, NumAdapt * 2)
Set MyCells = Union(Graphdata.Resize(3, 1), MyCells)
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, PlotBy:=xlRows, _
SeriesLabels:=1, Title:="LAN Frames/sec  " & Host & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(1, (NumAdapt * 2 + 2)), Cells(1, ColNum))
   Call ApplyStyle(Chart1, 0, 3)
End With
                                        'produce data rate graph
aa0 = ConvertRef(NumAdapt * 2)
Set MyCells = Sheet1.Range("A1:" & aa0 & CStr(numrows))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop2 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlArea, _
    CategoryLabels:=1, SeriesLabels:=1, _
    Title:="LAN KBytes/sec  " & Host & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
    Call ApplyStyle(Chart1, 2, NumAdapt)
End With
    
End Sub

                                       'last mode v3.1.5
Sub PP_JFS(numrows As Long, Sheet1 As Worksheet)
Dim aa0 As String, aa1 As String
Dim Chart1 As ChartObject              'new chart object
Dim ColNum As Integer
Dim MyCells As Range                   'range for charting
'Public RunDate As String               'NMON run date from AAA sheet
Dim Source As Range
Dim Target As Range

Call DelInt(Sheet1, numrows, 1)
                                        'do we have a /proc heading
Set Target = Sheet1.Rows(1).Find("/proc", LookAt:=xlWhole)
                                        'if so, delete the heading (but not the data)
If Not Target Is Nothing Then
   aa0 = Target.AddressLocal(False, False)
   aa1 = Left(aa0, Len(aa0) - 1)
   ColNum = ConvertRef(aa1)
   aa1 = ConvertRef(ColNum)
   Set Source = Sheet1.Range(aa1 & "1:IV1")
   Sheet1.Range(aa0 & ":IU1") = Source
   Call GetLastColumn(Sheet1, 1)
End If
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
                                        'produce avg/max graph
Set MyCells = avgmax(numrows, Sheet1, 0)
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + numrows * rH, cWidth, cHeight)
Chart1.Chart.ChartWizard Source:=MyCells, PlotBy:=xlRows, SeriesLabels:=1, _
    Title:=Sheet1.Range("A1").Value & "  " & RunDate
With Chart1.Chart                      'apply customisation
    .SeriesCollection(1).XValues = Sheet1.Range("B1:" & LastColumn & "1")
    .Axes(xlValue).MaximumScale = 100
    Call ApplyStyle(Chart1, 0, 3)
End With
End Sub
                                       'v3.3.C
Sub PP_IP(numrows As Long, Sheet1 As Worksheet)
Dim aa0 As String                       'temp var
Dim Chart1 As ChartObject               'new chart object
Dim Graphdata As Range                  'range for avg/max data
'Public LastColumn as String, ColNum as Integer
Dim MyCells As Range                    'temp var
Dim NumAdapt As Long                     'number of I/O adapters on sheet
'Public RunDate As String               'NMON run date from AAA sheet
    
Call DelInt(Sheet1, numrows, 1)
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
                                        'Put in the formulas for avg/max
Set Graphdata = avgmax(numrows, Sheet1, 0)
NumAdapt = ColNum / 2
                                        'produce avg/max graph
Set MyCells = Graphdata.Resize(3, NumAdapt + 1)
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, PlotBy:=xlRows, _
SeriesLabels:=1, Title:="IP Packets/sec  " & Host & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(1, 2), Cells(1, ColNum))
   Call ApplyStyle(Chart1, 0, 3)
End With
                                        'produce data rate graph
aa0 = ConvertRef(NumAdapt + 1)
aa0 = aa0 & "1:" & LastColumn & CStr(numrows)
Set MyCells = Union(Sheet1.Range("A1:A" & CStr(numrows)), Sheet1.Range(aa0))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop2 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlArea, _
    CategoryLabels:=1, SeriesLabels:=1, _
    Title:="IP Octet_kb/sec  " & Host & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
    Call ApplyStyle(Chart1, 2, NumAdapt)
End With
    
End Sub
                                       'v3.3.A
Sub PP_LPAGE(numrows As Long, Sheet1 As Worksheet)
Dim Chart1 As ChartObject               'new chart object
Dim MyCells As Range                    'range used for charting
'Public RunDate As String               'NMON run date from AAA sheet

Call DelInt(Sheet1, numrows, 1)
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
                                       'graph showing %breakdown
Set MyCells = Sheet1.Range("B1..C" & CStr(numrows))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlArea, _
SeriesLabels:=1, Title:=Sheet1.Range("A1").Value & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
'   .Axes(xlValue).MaximumScale = 100
   Call ApplyStyle(Chart1, 2, 2)
End With
End Sub
                                       'v3.3.C
Sub PP_LPAR(numrows As Long, Sheet1 As Worksheet)
Dim Chart1 As ChartObject               'new chart object
Dim Cn As Integer                       'free column for CPU% vs Entitled
Dim MyCells As Range                    'range used for charting
'Public RunDate As String               'NMON run date from AAA sheet

Call DelInt(Sheet1, numrows, 1)
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
                                       'find a free column
Cn = ColNum + 1
                                       'pepare data for graphs
If Linux Then
   Sheet1.Cells(1, Cn) = "VP_CPU%"
   Set MyCells = Union(Sheet1.Range("B1:B" & CStr(numrows)), Sheet1.Range("I1:I" & CStr(numrows)))
   Sheet1.Cells(2, Cn) = "=B2/L2*100"
ElseIf Sheet1.Range("U1") = "Folded" Then
   Sheet1.Cells(1, Cn) = "Unfolded VPs"
   Set MyCells = Union(Sheet1.Range("B1:B" & CStr(numrows)), Sheet1.Range("F1:F" & CStr(numrows)))
   Sheet1.Cells(2, Cn) = "=C2-U2"
Else
   Sheet1.Cells(1, Cn) = "VP_CPU%"
   Set MyCells = Union(Sheet1.Range("B1:B" & CStr(numrows)), Sheet1.Range("F1:F" & CStr(numrows)))
   Sheet1.Cells(2, Cn) = "=B2/C2*100"
'Else
'    ' first graph only includes columns B and C
'    Set MyCells = Union(Sheet1.Range("B1:B" & CStr(numrows)), Sheet1.Range("F1:F" & CStr(numrows)))
End If

Sheet1.Range(Cells(2, Cn), Cells(numrows, Cn)).FillDown
   Sheet1.Range(Cells(2, Cn), Cells(numrows, Cn)).Value = Sheet1.Range(Cells(2, Cn), Cells(numrows, Cn)).Value
   Sheet1.Range(Cells(2, Cn), Cells(numrows, Cn)).NumberFormat = "0.0"
   
                                       'produce a graph of physcpu vs entitled
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + numrows * rH, cWidth, cHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlLine, Format:=2, _
   SeriesLabels:=1, Title:="Physical CPU vs Entitlement - " & Host & "  " & RunDate

                                         'apply customisation
If Linux Or Sheet1.Range("U1") <> "Folded" Then
   With Chart1.Chart
      .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
      Call ApplyStyle(Chart1, 1, 2)
   End With
Else
   With Chart1.Chart
      .SeriesCollection.NewSeries
      With .SeriesCollection(3)
         .MarkerStyle = xlNone
         .Values = Sheet1.Range(Cells(2, Cn), Cells((numrows + 1), Cn))
         .Name = "Unfolded VPs"
      End With
      .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
      Call ApplyStyle(Chart1, 1, 3)
   End With
End If
                                         'produce a graph of VP%
Set MyCells = Sheet1.Range("Q1:S" & CStr(numrows))
If Linux Or Sheet1.Range("U1") <> "Folded" Then Set MyCells = Sheet1.Range(Cells(1, Cn), Cells(numrows, Cn))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop2 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlArea, _
   SeriesLabels:=1, Title:="CPU% vs VPs - " & Host & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
   .Axes(xlValue).MaximumScale = 100
   Call ApplyStyle(Chart1, 2, 3)
End With
If Linux Then Exit Sub
                                       'graph showing use in pool
Cn = Cn + 1
Sheet1.Cells(1, Cn) = "OtherLPARs"
Sheet1.Cells(2, Cn) = "=E2-B2-H2"
Sheet1.Range(Cells(2, Cn), Cells(numrows, Cn)).FillDown
Sheet1.Range(Cells(2, Cn), Cells(numrows, Cn)).Value = Sheet1.Range(Cells(2, Cn), Cells(numrows, Cn)).Value
Sheet1.Range(Cells(2, Cn), Cells(numrows, Cn)).NumberFormat = "0.0"

Set MyCells = Union(Sheet1.Range("B1:B" & CStr(numrows)), Sheet1.Range("H1:H" & CStr(numrows)))

Set MyCells = Union(MyCells, Sheet1.Range(Cells(1, Cn), Cells(numrows, Cn)))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop3 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlArea, PlotBy:=xlColumns, _
   SeriesLabels:=1, Title:="Shared Pool Utilisation - " & Host & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
   .SeriesCollection(3).PlotOrder = 2
   Call ApplyStyle(Chart1, 2, 3)
End With

End Sub
                                       'last mod v3.3.E
Sub PP_MEM(numrows As Long, Sheet1 As Worksheet)
Dim Chart1 As ChartObject               'new chart object
Dim MyCells As Range                    'range used for charting
'Public RunDate As String               'NMON run date from AAA sheet
    
Sheet1.Range("B1:O1").Columns.AutoFit
Call DelInt(Sheet1, numrows, 1)
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
                                        'Produce a graph of free memory
If Linux Then
    Set MyCells = Sheet1.Range("F1:F" & CStr(numrows))
Else
    Set MyCells = Sheet1.Range("D1:D" & CStr(numrows))
End If
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, cTop + numrows * rH, cWidth, cHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlLine, Format:=2, _
   SeriesLabels:=1, Title:=Sheet1.Range("A1").Value & "  " & RunDate
   
With Chart1.Chart                       'apply customisation
     .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
     Call ApplyStyle(Chart1, 1, 1)
End With
                                        'produce a graph of real memory                                                                       'Produce a graph of free memory
If Linux Then
    Set MyCells = Sheet1.Range("B1:B" & CStr(numrows))
Else
    Set MyCells = Sheet1.Range("F1:F" & CStr(numrows))
End If
If Not Linux And Sheet1.Range("H1") <> "" Then
   Set MyCells = Union(MyCells, Sheet1.Range("H1:H" & CStr(numrows)))
End If
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop2 + numrows * rH, cWidth, cHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlArea, Format:=1, _
   SeriesLabels:=1, HasLegend:=True
Chart1.Chart.ChartType = xlArea   'yet another Excel bug fix
                                        'apply customisation
With Chart1.Chart
     .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
     Call ApplyStyle(Chart1, 2, 1)
     .HasTitle = False
End With
End Sub
                                       'V3.3.C
Sub PP_MEMAMS(numrows As Long, Sheet1 As Worksheet)
Dim Chart1 As ChartObject               'new chart object
Dim MyCells As Range                    'range used for charting
'Public RunDate As String               'NMON run date from AAA sheet
Dim MyTitle As String

Call DelInt(Sheet1, numrows, 1)
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub

MyTitle = Sheet1.Range("A1").Value
                                        'graph showing Hypervisor stats
Set MyCells = Sheet1.Range("D1..D" & CStr(numrows))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlLine, Format:=2, _
SeriesLabels:=1, Title:=Sheet1.Range("A1").Value & "  " & Host & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
   Call ApplyStyle(Chart1, 1, 1)
   .SeriesCollection.NewSeries
   With .SeriesCollection(2)
      .AxisGroup = 2
      .ChartType = xlLine
      .Values = Sheet1.Range(Cells(2, 5), Cells(numrows, 5))
      .Name = Sheet1.Cells(1, 5).Value
   End With
End With
                                        'graph showing IO Memory usage
Set MyCells = Union(Sheet1.Range("A1..A" & CStr(numrows)), Sheet1.Range("F1..H" & CStr(numrows)))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop2 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlLine, Format:=2, _
      SeriesLabels:=1, Title:=Sheet1.Range("A1").Value & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
   Call ApplyStyle(Chart1, 1, 3)
End With
End Sub
                                       'v3.3.C
Sub PP_MEMNEW(numrows As Long, Sheet1 As Worksheet)
Dim Chart1 As ChartObject               'new chart object
Dim MyCells As Range                    'range used for charting
'Public RunDate As String               'NMON run date from AAA sheet
Dim MyTitle As String

Call DelInt(Sheet1, numrows, 1)
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub

MyTitle = Sheet1.Range("A1").Value
Mid(MyTitle, 8, 3) = "Use"
                                        'graph showing %breakdown
If SheetExists("MEM_AMS") Then
   Sheet1.Range("H1") = "Loan%"
   Sheet1.Range("H2") = "=(MEM!F2-MEM!H2)/MEM!F2*100"
   Set MyCells = Sheet1.Range("H2:H" & CStr(numrows))
   MyCells.FillDown
   MyCells.Value = MyCells.Value
   MyCells.NumberFormat = "0.0"
   Set MyCells = Union(Sheet1.Range("B1..D" & CStr(numrows)), Sheet1.Range("H1..H" & CStr(numrows)))
Else
   Set MyCells = Sheet1.Range("B1..D" & CStr(numrows))
End If
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlArea, _
SeriesLabels:=1, Title:=MyTitle & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection(3).PlotOrder = 1
   .SeriesCollection(1).Interior.ColorIndex = 17
   .SeriesCollection(2).Interior.ColorIndex = 18
   .SeriesCollection(3).Interior.ColorIndex = 19
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
   .Axes(xlValue).MaximumScale = 100
   Call ApplyStyle(Chart1, 2, 2)
End With
End Sub
                                       'v3.3.A
Sub PP_MEMPAGES(numrows As Long, Sheet1 As Worksheet)
Dim Chart1 As ChartObject
Dim Cn As Integer
'Public ColNum As Integer               'Last column number
Dim MyCells As Range
Dim SectionName As String
    
SectionName = Sheet1.Name
If Application.WorksheetFunction.Max(Sheet1.Range("B2:IV" & CStr(numrows))) = 0 Then
   Application.DisplayAlerts = False
   Sheet1.Delete
   Application.DisplayAlerts = True
   Exit Sub
End If
Call DelInt(Sheet1, numrows, 1)
If SectionName <> "MEMPAGES64KB" Then Exit Sub
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
                                       'add columns for the graph
Cn = ColNum + 1
Sheet1.Cells(1, Cn) = "4KB_used MB"
Sheet1.Cells(1, Cn + 1) = "64KB_used MB"
Sheet1.Cells(1, Cn + 2) = "4KB_free MB"
Sheet1.Cells(1, Cn + 3) = "64KB_free MB"
Sheet1.Cells(2, Cn) = "=MEMPAGES4KB!B2/256-" & ConvertRef(Cn + 1) & "2"
Sheet1.Cells(2, Cn + 1) = "=B2/16-" & ConvertRef(Cn + 2) & "2"
Sheet1.Cells(2, Cn + 2) = "=MEMPAGES4KB!C2/256"
Sheet1.Cells(2, Cn + 3) = "=C2/16"
Sheet1.Range(Cells(2, Cn), Cells(numrows, Cn + 3)).FillDown
Sheet1.Range(Cells(2, Cn), Cells(numrows, Cn + 3)).Value = Sheet1.Range(Cells(2, Cn), Cells(numrows, Cn + 3)).Value
Sheet1.Range(Cells(2, Cn), Cells(numrows, Cn + 3)).NumberFormat = "#,000"
                                       'create the graph
Set MyCells = Sheet1.Range(Cells(1, Cn), Cells(numrows, Cn + 3))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlArea, _
SeriesLabels:=1, Title:="4K - 64K Page Dynamics - " & Host & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
   .SeriesCollection(3).PlotOrder = 2
   Call ApplyStyle(Chart1, 2, 4)
End With
End Sub
                                       'v3.3.g
Sub PP_MEMREAL(numrows As Long, Sheet1 As Worksheet)
Dim Chart1 As ChartObject               'new chart object
Dim MyCells As Range                    'range used for charting
Dim Cn As Integer
'Public RunDate As String               'xmwlm run date from AAA sheet

Call DelInt(Sheet1, numrows, 1)
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
Cn = ColNum + 1
                                        'pepare data for graphs
Sheet1.Cells(1, Cn) = "Real Free(MB)"
Sheet1.Cells(2, Cn) = "=C2/256"
Set MyCells = Sheet1.Range(Cells(2, Cn), Cells(numrows, Cn))
MyCells.FillDown
MyCells.Value = MyCells.Value
                                        'graph showing %breakdown
Set MyCells = Sheet1.Range("E1..F" & CStr(numrows))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlArea, _
SeriesLabels:=1, Title:=Sheet1.Range("A1").Value & "  " & Host & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
   .Axes(xlValue).MaximumScale = 100
   Call ApplyStyle(Chart1, 2, 2)
   .SeriesCollection.NewSeries
   With .SeriesCollection(3)
      .AxisGroup = 2
      .ChartType = xlLine
      .Values = Sheet1.Range(Cells(2, 4), Cells(numrows, 4))
      .Name = Sheet1.Cells(1, 4).Value
   End With
   .Axes(xlValue, xlSecondary).MaximumScale = 100
End With
                                       'graph real free memory
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop2 + numrows * rH, cWidth, cHeight)
Chart1.Chart.ChartWizard Source:=Sheet1.Range("H1:H" & CStr(numrows)), Gallery:=xlLine, Format:=2, _
      SeriesLabels:=1, Title:=Sheet1.Range("A1").Value & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
     .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
     Call ApplyStyle(Chart1, 1, 1)
End With
End Sub
                                       'last mod v3.3.A
Sub PP_MEMUSE(numrows As Long, Sheet1 As Worksheet)
Dim Chart1 As ChartObject              'new chart object
Dim Cn As Integer                      'free column number
Dim MyCells As Range                   'range used for charting
'Public RunDate As String              'NMON run date from AAA sheet

Call DelInt(Sheet1, numrows, 1)
                                       'set up column headings + formulas for graphing
Cn = ColNum + 1
Sheet1.Cells(1, Cn).Value = "%comp"
Sheet1.Cells(2, Cn).Value = "=100-MEM!B2-B2"
Set MyCells = Sheet1.Range(Cells(2, Cn), Cells(numrows, Cn))
MyCells.FillDown
MyCells.Value = MyCells.Value
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
                                       'Produce a graph of %numperm
Set MyCells = Sheet1.Range("B1:D" & CStr(numrows))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlLine, Format:=2, _
        SeriesLabels:=1, Title:="VMTUNE Parameters " & Host & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
   .Axes(xlValue).MaximumScale = 100
   Call ApplyStyle(Chart1, 1, 3)
   .Axes(xlValue).HasMajorGridlines = False
   .SeriesCollection(2).Border.LineStyle = xlDot
   .SeriesCollection(3).Border.LineStyle = xlDot
   .SeriesCollection(3).Border.ColorIndex = 26   'Magenta
   .SeriesCollection.NewSeries
   With .SeriesCollection(4)
     .Values = Sheet1.Range(Cells(2, Cn), Cells(numrows, Cn))
     .Name = "%comp"
   End With
End With
If SheetExists("MEMNEW") Then Exit Sub
                                        'graph showing %comp and %file
Set MyCells = Sheet1.Range("G1..G" & CStr(numrows))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop2 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlArea, _
SeriesLabels:=1, Title:=Sheet1.Range("A1").Value & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
   .SeriesCollection.NewSeries
   With .SeriesCollection(2)
     .Values = Sheet1.Range(Cells(2, 2), Cells(numrows, 2))
     .Name = "%file"
   End With
   .Axes(xlValue).MaximumScale = 100
   Call ApplyStyle(Chart1, 2, 2)
End With
End Sub
                                       'v3.3.A
Sub PP_MEMVIRT(numrows As Long, Sheet1 As Worksheet)
Dim Chart1 As ChartObject               'new chart object
Dim MyCells As Range                    'range used for charting
'Public RunDate As String               'xmwlm run date from AAA sheet

Call DelInt(Sheet1, numrows, 1)
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
                                        'graph pagespace paging
Set MyCells = Sheet1.Range("G1..H" & CStr(numrows))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlArea, _
SeriesLabels:=1, Title:=Sheet1.Range("A1").Value & "  " & Host & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
   Call ApplyStyle(Chart1, 2, 2)
End With
                                       'graph free pagespace
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop2 + numrows * rH, cWidth, cHeight)
Chart1.Chart.ChartWizard Source:=Sheet1.Range("C1:C" & CStr(numrows)), Gallery:=xlLine, Format:=2, _
      SeriesLabels:=1, Title:=Sheet1.Range("A1").Value & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
     .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
     Call ApplyStyle(Chart1, 1, 1)
End With
End Sub
                                       'last mod v3.3.A
Sub PP_NET(numrows As Long, Sheet1 As Worksheet)
Dim aa0 As String                       'temp var
Dim Chart1 As ChartObject               'new chart object
'Public ColNum As Integer               'last column number
Dim CurCol As Long                     'loop counter
Dim Graphdata As Range                  'saved range from avgmax function
Dim incr As Long                         'number of network adapters
'Public LastColumn As String            'last column letter
Dim MyCells As Range                    'temp var
Dim n As Long                            'number of columns to traverse
'Public RunDate As String               'NMON run date from AAA sheet

Call DelInt(Sheet1, numrows, 1)
                                        'Put in the formulas for avg/max
Set Graphdata = avgmax(numrows, Sheet1, 0)
n = ColNum + 1
incr = (n - 2) / 2
Set MyCells = Sheet1.Range("A1")
                                        'set up column headings + formulas for graphing
MyCells(1, 1).Value = MyCells(1, 1).Value & " (KB/s)"
For CurCol = n To (n + incr - 1)
   aa0 = MyCells(1, CurCol - incr * 2).Value
   MyCells(1, CurCol - incr * 2) = Left(aa0, Len(aa0) - 5)
   aa0 = MyCells(1, CurCol - incr).Value
   aa0 = Left(aa0, Len(aa0) - 5)       'strip off KB/s from write
   MyCells(1, CurCol - incr) = aa0
   aa0 = Left(aa0, Len(aa0) - 5) & "total"
   MyCells.Item(1, CurCol) = aa0       'add total
   MyCells.Item(2, CurCol) = "=" & ConvertRef(CurCol - incr - 1) & "2+" & ConvertRef(CurCol - incr * 2 - 1) & "2"
Next CurCol
MyCells(1, n + incr) = "Total-Read"
MyCells(2, n + incr) = "=SUM(B2:" & ConvertRef(incr) & "2)"
MyCells(1, n + incr + 1) = "Total-Write (-ve)"
MyCells(2, n + incr + 1) = "=-SUM(" & ConvertRef(incr + 1) & "2.." & ConvertRef(n - 2) & "2)"
Set MyCells = Sheet1.Range(Sheet1.Cells(2, n), Sheet1.Cells(numrows, n + incr + 1))
MyCells.FillDown
MyCells.Value = MyCells.Value
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
                                        'Produce total reads/writes graph
Set MyCells = Sheet1.Range(Sheet1.Cells(1, n + incr), Cells(numrows, n + incr + 1))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlArea, _
   PlotBy:=xlColumns, SeriesLabels:=1, Title:=Sheet1.Range("A1").Value & " - " & RunDate
     
With Chart1.Chart                       'apply customisation
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
   Call ApplyStyle(Chart1, 2, 2)
   .ChartType = xlArea
   .Axes(xlValue).MinimumScaleIsAuto = True
   .Axes(xlCategory).TickLabelPosition = xlLow
End With
                                        'produce avg/max graph
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop2 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=Graphdata, PlotBy:=xlRows, _
   SeriesLabels:=1, Title:=Sheet1.Range("A1").Value & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(1, 2), Cells(1, ColNum))
   Call ApplyStyle(Chart1, 0, 3)
End With
                                        'produce adapter by ToD graph
Set MyCells = Sheet1.Range("A1:" & LastColumn & CStr(numrows))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop3 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlArea, _
   PlotBy:=xlColumns, CategoryLabels:=1, SeriesLabels:=1, _
   Title:=Sheet1.Range("A1").Value & "  " & RunDate
   
With Chart1.Chart                       'apply customisation
  .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
  Call ApplyStyle(Chart1, 2, ColNum)
End With

End Sub
                                       'v3.3.A
Sub PP_NETSIZE(numrows As Long, Sheet1 As Worksheet)
Dim aa0 As String                       'temp var
Dim Chart1 As ChartObject               'new chart object
Dim CurCol As Long                     'loop counter
Dim Graphdata As Range                  'range for graphing
'Public Host As String                  'Hostname from AAA sheet
'Public LastColumn As String            'last column letter
Dim MyCells As Range                    'temp var
Dim n As Long                           'number of columns at the start
'Public RunDate As String               'NMON run date from AAA sheet

Call DelInt(Sheet1, numrows, 1)
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
n = ColNum
                                        'produce avg/max graph
Set MyCells = avgmax(numrows, Sheet1, 0)
aa0 = ConvertRef(n)
Set Graphdata = Sheet1.Range(aa0 & CStr(numrows + 2) & ":" & LastColumn & CStr(numrows + 4))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=Graphdata, PlotBy:=xlRows, _
   Title:="Network Packet Size (bytes) " & Host & "  " & RunDate
With Chart1.Chart                       'apply customisation
  .SeriesCollection(1).Name = "Avg."
  .SeriesCollection(2).Name = "WAvg."
  .SeriesCollection(3).Name = "Max."
  .SeriesCollection(1).XValues = Sheet1.Range(Cells(1, n + 1), Cells(1, n * 2))
  Call ApplyStyle(Chart1, 0, 3)
End With
End Sub
                                       'v3.3.G
Sub PP_PAGE(numrows As Long, Sheet1 As Worksheet)
Dim Chart1 As ChartObject               'new chart object
Dim MyCells As Range                    'range used for charting
Dim Cn As Integer
'Public RunDate As String               'NMON run date from AAA sheet

Call DelInt(Sheet1, numrows, 1)
                                        'find a free column
Cn = ColNum + 1
                                        'pepare data for graphs
Sheet1.Cells(1, Cn) = "fsin"
Sheet1.Cells(2, Cn) = "=C2-E2"
Sheet1.Cells(1, Cn + 1) = "fsout"
Sheet1.Cells(2, Cn + 1) = "=D2-F2"
Sheet1.Cells(1, Cn + 2) = "sr/fr"
Sheet1.Cells(2, Cn + 2) = "=IF(G2>0,H2/G2,0)"
Set MyCells = Sheet1.Range(Cells(2, Cn), Cells(numrows, Cn + 2))
MyCells.FillDown
MyCells.Value = MyCells.Value
MyCells.NumberFormat = "0.0"
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
                                        'graph the paging rates
Set MyCells = Sheet1.Range("E1:F" & CStr(numrows))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlArea, _
   SeriesLabels:=1, Title:=Sheet1.Range("A1").Value & " (pgspace)  " & RunDate
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
   Call ApplyStyle(Chart1, 2, 2)
End With
                                        'graph the filespace rates
Set MyCells = Sheet1.Range(Cells(1, Cn), Cells(numrows, Cn + 1))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop2 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlArea, _
   SeriesLabels:=1, Title:=Sheet1.Range("A1").Value & " (filesystem)  " & RunDate
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
   Call ApplyStyle(Chart1, 2, 2)
End With
                                        'graph the sr/fr rate
Set MyCells = Sheet1.Range(Cells(1, Cn + 2), Cells(numrows, Cn + 2))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop3 + numrows * rH, cWidth, cHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlLine, Format:=2, _
   SeriesLabels:=1, Title:="Page scan:free ratio " & Host & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
   Call ApplyStyle(Chart1, 1, 1)
   .HasLegend = False
End With
      
End Sub
                                       'new for v3.3.E
Sub PP_PAGING(numrows As Long, Sheet1 As Worksheet)
Dim Chart1 As ChartObject
Dim MyCells As Range

Call DelInt(Sheet1, numrows, 1)
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
                                        'produce line graph
Set MyCells = Sheet1.Range("A1:" & LastColumn & CStr(numrows))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, cTop + numrows * rH, cWidth, cHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlLine, Format:=2, _
    Title:=Sheet1.Range("A1").Value & "  " & RunDate, CategoryLabels:=1, SeriesLabels:=1, HasLegend:=True
                                        'apply customisation
With Chart1.Chart
    Call ApplyStyle(Chart1, 1, ColNum - 1)
End With
End Sub
                                       'v3.3.C
Sub PP_POOLS(numrows As Long, Sheet1 As Worksheet)
Dim Chart1 As ChartObject
Dim MyCells As Range

Call DelInt(Sheet1, numrows, 1)
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
                                        'produce graph
Set MyCells = Union(Sheet1.Range("F1:F" & CStr(numrows)), Sheet1.Range("C1:D" & CStr(numrows)))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlLine, Format:=2, _
    SeriesLabels:=1, Title:=Sheet1.Range("A1").Value & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
   Call ApplyStyle(Chart1, 1, 3)
End With
End Sub
                                       'last mod v3.3.A
Sub PP_PROC(numrows As Long, Sheet1 As Worksheet)
Dim Chart1 As ChartObject
Dim MyCells As Range

Call DelInt(Sheet1, numrows, 1)
Sheet1.Range("B1") = "RunQueue"
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub

                                        'produce RunQueue/swap-ins graph
Set MyCells = Sheet1.Range("B1:C" & CStr(numrows))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlLine, Format:=2, _
    SeriesLabels:=1, Title:=Sheet1.Range("A1").Value & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
   Call ApplyStyle(Chart1, 1, 2)
End With
                                        'Produce a graph of pswitch/syscalls rates
Set MyCells = Sheet1.Range("D1:E" & CStr(numrows))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop2 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlLine, Format:=2, _
      SeriesLabels:=1, Title:=Sheet1.Range("A1").Value & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection(1).Name = "pswitch/sec"
   .SeriesCollection(2).Name = "syscalls/sec"
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
   Call ApplyStyle(Chart1, 1, 2)
End With
                                        'Produce a graph of forks/execs
Set MyCells = Sheet1.Range("H1:I" & CStr(numrows))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop3 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlLine, Format:=2, _
      SeriesLabels:=1, Title:=Sheet1.Range("A1").Value & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection(1).Name = "forks/sec"
   .SeriesCollection(2).Name = "execs/sec"
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
   Call ApplyStyle(Chart1, 1, 2)
End With
End Sub
                                       '
Sub PP_RAW(numrows As Long, Sheet1 As Worksheet)
Dim SectionName As String
    
SectionName = Sheet1.Name
Call DelInt(Sheet1, numrows, 1)
      
End Sub
                                       'last mod v3.3.A
Sub PP_PROCAIO(numrows As Long, Sheet1 As Worksheet)
Dim Chart1 As ChartObject               'new chart object
Dim Cn As Integer
'Public ColNum as Integer
'Public Host As String                  'Hostname from AAA sheet
'Public LastColumn As String
Dim MyCells As Range                    'range for charting
'Public RunDate As String               'NMON run date from AAA sheet
Dim SectionName As String
    
SectionName = Sheet1.Name
Call DelInt(Sheet1, numrows, 1)
If Not SheetExists("CPU_ALL") Then Exit Sub
                                        'add syscpu column
Cn = ColNum + 1
Sheet1.Cells(1, Cn) = "syscpu"
Sheet1.Cells(2, Cn) = "=D2/CPU_ALL!G2"
Set MyCells = Sheet1.Range(Cells(2, Cn), Cells(numrows, Cn))
MyCells.FillDown
MyCells.Value = MyCells.Value
MyCells.NumberFormat = "#,##0.0"
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
                                        'produce avg/max graph
Set MyCells = avgmax(numrows, Sheet1, 0)
Set MyCells = Sheet1.Range("A" & CStr(numrows + 2) & ":C" & CStr(numrows + 4))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + numrows * rH, cWidth, cHeight)
Chart1.Chart.ChartWizard Source:=MyCells, PlotBy:=xlRows, SeriesLabels:=1, _
    Title:=Sheet1.Range("A1").Value & "  " & RunDate
With Chart1.Chart                       'apply customisation
    .SeriesCollection(1).XValues = Sheet1.Range(Cells(1, 2), Cells(1, ColNum))
    Call ApplyStyle(Chart1, 0, 3)
End With
                                        'produce line graph
Set MyCells = Union(Sheet1.Range("A1:A" & CStr(numrows)), _
    Sheet1.Range("C1:C" & CStr(numrows)), Sheet1.Range(Cells(1, Cn), Cells(numrows, Cn)))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop2 + numrows * rH, cWidth, cHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlLine, Format:=2, _
    CategoryLabels:=1, SeriesLabels:=1, PlotBy:=xlColumns, _
    Title:=Sheet1.Range("A1").Value & "  " & RunDate
With Chart1.Chart
   With .SeriesCollection(2)
        .AxisGroup = 2
        .MarkerStyle = xlNone
   End With
   Call ApplyStyle(Chart1, 1, 2)
   .Axes(xlValue).HasMajorGridlines = False
   .Axes(xlValue, xlPrimary).HasTitle = True
   .Axes(xlValue, xlPrimary).AxisTitle.Characters.Text = "#active processes"
   .Axes(xlValue, xlSecondary).HasTitle = True
   .Axes(xlValue, xlSecondary).AxisTitle.Characters.Text = "%cpu used by aio"
End With
End Sub
                                      'last mod v3.3.A
Sub PP_SUMMARY(numrows As Long, Sheet1 As Worksheet)
Dim aa0 As String                     'temp var
Dim Chart1 As ChartObject             'new chart object
Dim Cl As String                      'Column letter for IntervalCPU%
Dim Cw As String                      'Column letter for WSet
Dim Cmd As String                     'current command
Dim Cn As Integer                     'column number for IntervalCPU%
Dim CurRow As Long                    'loop counter
Dim MyCells As Range                  'temp var
Dim MyRow As Long                     'temp var
Dim NumCmds As Integer                'number of unique commands
Dim oldCmd As String                  'previous command
Dim sRow As Long                      'start row of command block
Dim sTRow As Long                     'start row of interval block
Dim TVal As String                    'current time value
Dim oldTVal As String                 'previous time value

Sheet1.Range("A1") = "Time"
                                       'delete unwanted intervals
If First > 1 Or Last < 9999 Then
   TVal = Sheet1.Range("A" & CStr(numrows)).Value
   MyRow = CInt(Right(TVal, 4))
   If Last < MyRow Then
      TVal = "T" & Format(Last + 1, "0000")
      Set MyCells = Sheet1.UsedRange.Find(TVal, LookAt:=xlWhole)
      If Not (MyCells Is Nothing) Then
         MyRow = MyCells.row
         Sheet1.Range("A" & CStr(MyRow) & ":A" & CStr(numrows)).EntireRow.Delete
         numrows = MyRow - 1
      End If
   End If
   If First > 1 Then
      TVal = "T" & Format(First + 1, "0000")
      Set MyCells = Sheet1.UsedRange.Find(TVal, LookAt:=xlWhole)
      If Not (MyCells Is Nothing) Then
      If MyCells.row > 2 Then
         MyRow = MyCells.row - 1
         Sheet1.Range("A2:A" & CStr(MyRow)).EntireRow.Delete
         numrows = numrows - MyRow + 1
      End If
      End If
   End If
End If
                                        'find a free column
Cn = ColNum + 1
Cl = Sheet1.Range("A1").Item(1, Cn).Address(True, False, xlA1)
Cl = Left(Cl, InStr(1, Cl, "$") - 1)
Cw = Sheet1.Range("A1").Item(1, Cn + 1).Address(True, False, xlA1)
Cw = Left(Cw, InStr(1, Cw, "$") - 1)
                                
Set MyCells = Sheet1.Range("A1")
MyCells(1, Cn) = "Sys_CPU%"
MyCells(2, Cn) = "=(C2+D2)/VLOOKUP(A2,CPU_ALL!A$2:G$" & CStr(CPUrows) & ",7)"
MyCells(1, Cn + 1) = "WSetKB"
MyCells(2, Cn + 1) = "=B2*E2+F2"
MyCells.Range(Cells(2, Cn), Cells(numrows, Cn + 1)).FillDown
MyCells.Range(Cells(2, Cn), Cells(numrows, Cn)).NumberFormat = "0.0"
MyCells.Range(Cells(2, Cn), Cells(numrows, Cn + 1)).Value = MyCells.Range(Cells(2, Cn), Cells(numrows, Cn + 1)).Value
                                        'sort the data into Command name order
Sheet1.Columns("A:Z").Sort Key1:=Sheet1.Range("I2"), Order1:=xlAscending, _
   Key2:=Sheet1.Range("A2"), Order2:=xlAscending, Header:=xlYes, _
   OrderCustom:=1, MatchCase:=False, Orientation:=xlTopToBottom
                                       'create table for Sys_CPU%, WSetKB, CharIO graphs
sRow = 2
sTRow = 2
NumCmds = 1
oldCmd = MyCells(sRow, 9).Value        'Commands are in column "I" = 9
oldTVal = MyCells(sRow, 1).Value
For CurRow = sRow To MaxRows - 1
   Cmd = MyCells.Item(CurRow, 9).Value
   If Cmd <> oldCmd Then
                                        'create table entry for this command
                                        'Sys_cpu%
      MyRow = numrows + NumCmds + 2
      NumCmds = NumCmds + 1
      MyCells(MyRow, 2) = oldCmd
      MyCells(MyRow, 3) = _
         "=AVERAGE(J" & CStr(sRow) & ":J" & CStr(CurRow - 1) & ")"
      aa0 = Cl & CStr(sRow) & ":" & Cl & CStr(CurRow - 1)
      MyCells(MyRow, 4) = _
        "=SUMPRODUCT(" & aa0 & "," & aa0 & ")/SUM(" & aa0 & ")-C" & CStr(MyRow)
      MyCells(MyRow, 5) = _
        "=MAX(" & Cl & CStr(sRow) & ":" & Cl & CStr(CurRow - 1) & ")-(C" & CStr(MyRow) & "+D" & CStr(MyRow) & ")"
                                       'WSetKB
      aa0 = Cw & CStr(sRow) & ":" & Cw & CStr(CurRow - 1)
      MyCells(MyRow, 7) = "=MIN(" & aa0 & ")"
      MyCells(MyRow, 8) = "=AVERAGE(" & aa0 & ")-G" & CStr(MyRow)
      MyCells(MyRow, 9) = _
         "=MAX(" & aa0 & ")-SUM(G" & CStr(MyRow) & ":H" & CStr(MyRow) & ")"
                                       'CharIO
      aa0 = "G" & CStr(sRow) & ":G" & CStr(CurRow - 1)
      MyCells(MyRow, 10) = "=AVERAGE(" & aa0 & ")"
      MyCells(MyRow, 11) = _
        "=IF(SUM(" & aa0 & ")>0,SUMPRODUCT(" & aa0 & "," & aa0 & ")/SUM(" & aa0 & ")-J" & CStr(MyRow) & ",0)"
      MyCells(MyRow, 12) = _
         "=MAX(" & aa0 & ")-SUM(J" & CStr(MyRow) & ":K" & CStr(MyRow) & ")"
      If Cmd = "" Then Exit For
      sRow = CurRow
      oldCmd = Cmd
      UserForm1.Label1.Caption = "SUMMARY: " & Cmd
      UserForm1.Repaint
   End If
Next
                                       'and write the table header
Set MyCells = Sheet1.Range(Cells(numrows + 2, 3), Cells(numrows + 2, 12))
MyCells = Array("Avg.", "WAvg.", "Max.", "WSet=>", "Min.", "Avg.", "Max.", "Avg.", "WAvg.", "Max.")
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
                                        'produce a graph of CPU by Command
Set MyCells = Sheet1.Range(Cells(numrows + 2, 3), Cells(MyRow, 5))
MyCells.NumberFormat = "0.0"
                                        
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + numrows * rH, cWidth, cHeight)
Chart1.Chart.ChartWizard Source:=MyCells, PlotBy:=xlColumns, CategoryLabels:=0, _
    SeriesLabels:=1, HasLegend:=True, _
    Title:="CPU% by command " & Host & "  " & RunDate
    
With Chart1.Chart                       'apply customisation
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(numrows + 3, 2), Cells(MyRow, 2))
   Call ApplyStyle(Chart1, 0, 1)
End With
                                        'produce a graph of Memory by Command
Set MyCells = Sheet1.Range(Cells(numrows + 2, 7), Cells(MyRow, 9))
MyCells.NumberFormat = "0"
                                        
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop2 + numrows * rH, cWidth, cHeight)
Chart1.Chart.ChartWizard Source:=MyCells, PlotBy:=xlColumns, CategoryLabels:=0, _
    SeriesLabels:=1, HasLegend:=True, _
    Title:="Memory by command (MBytes) " & Host & "  " & RunDate
    
With Chart1.Chart                       'apply customisation
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(numrows + 3, 2), Cells(MyRow, 2))
   .Axes(xlValue).DisplayUnit = xlThousands
   .Axes(xlValue).HasDisplayUnitLabel = False
   Call ApplyStyle(Chart1, 0, 1)
End With
                                       'produce a graph of CharIO by Command
Set MyCells = Sheet1.Range(Cells(numrows + 2, 10), Cells(MyRow, 12))
MyCells.NumberFormat = "0"
                                        
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop3 + numrows * rH, cWidth, cHeight)
Chart1.Chart.ChartWizard Source:=MyCells, PlotBy:=xlColumns, CategoryLabels:=0, _
   SeriesLabels:=1, HasLegend:=True, _
   Title:="CharIO by command (bytes/sec) " & Host & "  " & RunDate
    
With Chart1.Chart                   'apply customisation
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(numrows + 3, 2), Cells(MyRow, 2))
   Call ApplyStyle(Chart1, 0, 1)
End With
                                       'scroll the window to the graph
Sheet1.Range("B2").Select
ActiveWindow.FreezePanes = True
Sheet1.Range("A1").Select
ActiveWindow.ScrollRow = numrows + 2
End Sub
                                       'last mod v3.3.E
Sub PP_TOP(numrows As Long, Sheet1 As Worksheet)
'Public NumCPUs As Integer              'Number of CPU sections
Dim aa0 As String                       'temp var
Dim aa1 As String                       'temp var
Dim aa2 As String                       'string representing NumCPUs
Dim Chart1 As ChartObject               'new chart object
Dim Cl As String                        'Column letter for IntervalCPU%
Dim Cw As String                        'Column letter for WSet
Dim Cmd As String                       'current command
Dim Cn As Integer                       'column number for IntervalCPU%
Dim CurRow As Long                      'loop counter
Dim MyCells As Range                    'temp var
Dim MyRow As Long                       'temp var
Dim NumCmds As Integer                  'number of unique commands
Dim oldCmd As String                    'previous command
Dim sRow As Long                        'start row of command block
Dim sTRow As Long                       'start row of interval block
Dim TVal As String                      'current time value
Dim lTVal As Integer                    'length of timestamp

If numrows < 3 Then
   Application.DisplayAlerts = False
   Sheet1.Delete
   Application.DisplayAlerts = True
   Exit Sub
End If
UserForm1.Label1.Caption = "TOP: reorganising data"
UserForm1.Repaint
                                        'Start out by putting the data in a more reasonable order
Sheet1.Columns("C").Insert shift:=xlToRight
Set MyCells = Sheet1.Range("A1:A" & CStr(numrows))
Sheet1.Range("C1:C" & CStr(numrows)).Value = MyCells.Value
Sheet1.Columns("A").EntireColumn.Delete

If topas Then
   Sheet1.Columns("G:H").Insert shift:=xlToRight
   Set MyCells = Sheet1.Range("C1:C" & CStr(numrows))
   Sheet1.Range("G1:G" & CStr(numrows)).Value = MyCells.Value
   Sheet1.Columns("C").EntireColumn.Delete
End If
                                        'delete unwanted intervals
If First > 1 Or Last < Snapshots Then
   Sheet1.Columns("A:Z").Sort Key1:=Sheet1.Range("A2"), Order1:=xlAscending, _
      Header:=xlYes, OrderCustom:=1, MatchCase:=False, Orientation:=xlTopToBottom
      TVal = Sheet1.Range("A" & CStr(numrows)).Value
      lTVal = Len(TVal)
      MyRow = CInt(Right(TVal, lTVal - 1))
   If Last < MyRow Then
      TVal = "T" & Format(Last + 1, Left("00000000", lTVal - 1))
      Set MyCells = Sheet1.UsedRange.Find(TVal, LookAt:=xlWhole)
      If Not (MyCells Is Nothing) Then
         MyRow = MyCells.row
         Sheet1.Range("A" & CStr(MyRow) & ":A" & CStr(numrows)).EntireRow.Delete
         numrows = MyRow - 1
      End If
   End If
   If First > 1 Then
      TVal = "T" & Format(First + 1, Left("00000000", lTVal - 1))
      Set MyCells = Sheet1.UsedRange.Find(TVal, LookAt:=xlWhole)
      If Not (MyCells Is Nothing) Then
      If MyCells.row > 2 Then
         MyRow = MyCells.row - 1
         Sheet1.Range("A2:A" & CStr(MyRow)).EntireRow.Delete
         numrows = numrows - MyRow + 1
      End If
      End If
   End If
End If
TopRows = numrows
                                        'sort the data into Command name order
Sheet1.Columns("A:Z").Sort Key1:=Sheet1.Range("M2"), Order1:=xlAscending, _
   Key2:=Sheet1.Range("A2"), Order2:=xlAscending, Header:=xlYes, _
   OrderCustom:=1, MatchCase:=True, Orientation:=xlTopToBottom
Sheet1.Columns(13).AutoFit
                                        'find free columns
For Cn = 14 To 254
    If Sheet1.Range("A1")(1, Cn) = "" Then Exit For
Next Cn
Cl = Sheet1.Range("A1").Item(1, Cn).Address(True, False, xlA1)
Cl = Left(Cl, InStr(1, Cl, "$") - 1)
Cw = Sheet1.Range("A1").Item(1, Cn + 1).Address(True, False, xlA1)
Cw = Left(Cw, InStr(1, Cw, "$") - 1)
                                
Set MyCells = Sheet1.Range("A1")
MyCells(1, Cn) = "IntervalCPU%"
MyCells(1, Cn + 1) = "WSet"
                                        'and now produce CPU totals for each command
If dLPAR Then
    aa1 = ",CPU_ALL!A$2:G$" & CStr(CPUrows) & ",7)"
    aa2 = "VLOOKUP(A2" & aa1 & "*" & CStr(SMTmode)
Else
    aa2 = CStr(NumCPUs * SMTmode)
End If
                                        'calc totals for all single-process cmds
MyCells(2, Cn) = "=IF(A2=A3,IF(M2=M3,"" "",C2/" & aa2 & "),C2/" & aa2 & ")"
MyCells(2, Cn + 1) = "=IF(A2=A3,IF(M2=M3,"" "",H2+I2),H2+I2)"
If numrows > 2 Then
   MyCells.Range(Cells(2, Cn), Cells(numrows, Cn + 1)).FillDown
   MyCells.Range(Cells(2, Cn), Cells(numrows, Cn + 1)).Value = MyCells.Range(Cells(2, Cn), Cells(numrows, Cn + 1)).Value
End If
MyCells.Range(Cells(2, Cn), Cells(numrows, Cn)).NumberFormat = "0.00"
MyCells.Range(Cells(2, Cn + 1), Cells(numrows, Cn + 1)).NumberFormat = "#,##0"
                                
sRow = 2
sTRow = 2
NumCmds = 1
oldCmd = MyCells(sRow, 13).Value
                                        'generate sub-totals by time interval
If SMTon Then
   aa1 = ",CPU_ALL!A$2:G$" & CStr(CPUrows) & ",7)*2"
   aa2 = CStr(NumCPUs / 2)
Else
   aa1 = ",CPU_ALL!A$2:G$" & CStr(CPUrows) & ",7)"
   aa2 = CStr(NumCPUs)
End If
Application.Calculation = xlCalculationManual   'improve performance
For CurRow = sRow To MaxRows - 1
   Cmd = MyCells.Item(CurRow, 13).Value
   TVal = MyCells(CurRow, 1).Value
                                        'generate sub-totals for multiple processes
   If MyCells(CurRow, Cn).Value <> " " Then
      If sTRow <> CurRow And Cmd <> "" Then
         If dLPAR Then aa2 = "VLOOKUP(A" & CStr(CurRow) & aa1
         MyCells(CurRow, Cn) = "=SUM(C" & CStr(sTRow + 1) & ":C" & CStr(CurRow) & ")/" & aa2
         MyCells(CurRow, Cn + 1) = "=SUM(I" & CStr(sTRow + 1) & ":I" & CStr(CurRow) & ")+AVERAGE(H" & CStr(sTRow + 1) & ":H" & CStr(CurRow) & ")"
      End If
      sTRow = CurRow
   End If
   
   If Cmd <> oldCmd Then
      UserForm1.Label1.Caption = "TOP: " & Cmd
      UserForm1.Repaint
                                        'create table entry for this command
      MyRow = numrows + NumCmds + 2
      NumCmds = NumCmds + 1
      MyCells(MyRow, 2) = oldCmd
      MyCells(MyRow, 3) = _
         "=SUM(C" & CStr(sRow) & ":C" & CStr(CurRow - 1) & ")/snapshots/" & CStr(NumCPUs)
      aa0 = Cl & CStr(sRow) & ":" & Cl & CStr(CurRow - 1)
      MyCells(MyRow, 4) = _
        "=SUMPRODUCT(" & aa0 & "," & aa0 & ")/SUM(" & aa0 & ")-C" & CStr(MyRow)
      MyCells(MyRow, 5) = _
        "=MAX(" & Cl & CStr(sRow) & ":" & Cl & CStr(CurRow - 1) & ")-(C" & CStr(MyRow) & "+D" & CStr(MyRow) & ")"
      aa0 = Cw & CStr(sRow) & ":" & Cw & CStr(CurRow - 1)
      MyCells(MyRow, 7) = "=MIN(" & aa0 & ")"
      MyCells(MyRow, 8) = "=AVERAGE(" & aa0 & ")-G" & CStr(MyRow)
      MyCells(MyRow, 9) = _
         "=MAX(" & aa0 & ")-SUM(G" & CStr(MyRow) & ":H" & CStr(MyRow) & ")"
      aa0 = "J" & CStr(sRow) & ":J" & CStr(CurRow - 1)
      MyCells(MyRow, 10) = "=AVERAGE(" & aa0 & ")"
      MyCells(MyRow, 11) = _
        "=IF(SUM(" & aa0 & ")>0,SUMPRODUCT(" & aa0 & "," & aa0 & ")/SUM(" & aa0 & ")-J" & CStr(MyRow) & ",0)"
      MyCells(MyRow, 12) = _
         "=MAX(" & aa0 & ")-SUM(J" & CStr(MyRow) & ":K" & CStr(MyRow) & ")"
      
      If Cmd = "" Then Exit For
      sRow = CurRow
      oldCmd = Cmd
   End If
Next
UserForm1.Label1.Caption = "TOP: creating command table"
UserForm1.Repaint
Application.Calculation = xlCalculationAutomatic
Application.Calculate
                                       'convert formulas to values so that time stamps can be altered
MyCells.Range(Cells(2, Cn), Cells(numrows, Cn + 1)).Value = MyCells.Range(Cells(2, Cn), Cells(numrows, Cn + 1)).Value
                                       'and write the table header
Set MyCells = Sheet1.Range(Cells(numrows + 2, 3), Cells(numrows + 2, 12))
MyCells = Array("Avg.", "WAvg.", "Max.", "WSet=>", "Min.", "Avg.", "Max.", "Avg.", "WAvg.", "Max.")

If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
                                        'produce a graph of CPU by Command
Set MyCells = Sheet1.Range(Cells(numrows + 2, 3), Cells(MyRow, 5))
MyCells.NumberFormat = "0.0"
                                        
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + numrows * rH, cWidth, cHeight)
Chart1.Chart.ChartWizard Source:=MyCells, PlotBy:=xlColumns, CategoryLabels:=0, _
    SeriesLabels:=1, HasLegend:=True, _
    Title:="CPU% by command " & Host & "  " & RunDate
    
With Chart1.Chart                       'apply customisation
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(numrows + 3, 2), Cells(MyRow, 2))
   Call ApplyStyle(Chart1, 0, 1)
End With
                                        'produce a graph of Memory by Command
Set MyCells = Sheet1.Range(Cells(numrows + 2, 7), Cells(MyRow, 9))
MyCells.NumberFormat = "0"
                                        
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop2 + numrows * rH, cWidth, cHeight)
Chart1.Chart.ChartWizard Source:=MyCells, PlotBy:=xlColumns, CategoryLabels:=0, _
    SeriesLabels:=1, HasLegend:=True, _
    Title:="Memory by command (MBytes) " & Host & "  " & RunDate
    
With Chart1.Chart                       'apply customisation
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(numrows + 3, 2), Cells(MyRow, 2))
   .Axes(xlValue).DisplayUnit = xlThousands
   .Axes(xlValue).HasDisplayUnitLabel = False
   Call ApplyStyle(Chart1, 0, 1)
End With
                                       'produce a graph of CharIO by Command
If Not topas Then
   Set MyCells = Sheet1.Range(Cells(numrows + 2, 10), Cells(MyRow, 12))
      MyCells.NumberFormat = "0"
                                        
   Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop3 + numrows * rH, cWidth, cHeight)
   Chart1.Chart.ChartWizard Source:=MyCells, PlotBy:=xlColumns, CategoryLabels:=0, _
      SeriesLabels:=1, HasLegend:=True, _
      Title:="CharIO by command (bytes/sec) " & Host & "  " & RunDate
    
   With Chart1.Chart                   'apply customisation
      .SeriesCollection(1).XValues = Sheet1.Range(Cells(numrows + 3, 2), Cells(MyRow, 2))
      Call ApplyStyle(Chart1, 0, 1)
   End With
End If
                                       'and now produce a graph of CPU by PID
                                       ' @RM - 1/23/2015
                                       ' This is crashing with Excel 2013 with latest Windows updates if Scatter = "YES"
If Scatter And Not topas And numrows <= 32000 Then
   Set MyCells = Sheet1.Range("B1..C" & CStr(numrows))
   Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop4 + numrows * rH, cWidth, cHeight)
   Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlXYScatter, _
      SeriesLabels:=1, CategoryLabels:=1, HasLegend:=False, _
      Title:="%Processor by PID " & Host & "  " & RunDate
                                        'apply customisation
   With Chart1.Chart
      .Axes(xlCategory).HasMajorGridlines = False
   End With
End If
                                       'scroll the window to the graph
Sheet1.Range("B2").Select
ActiveWindow.FreezePanes = True
Sheet1.Range("A1").Select
ActiveWindow.ScrollRow = numrows + 2
End Sub
                                       'last mod v3.3.0
Sub PP_UARG(numrows As Long, Sheet1 As Worksheet)
Dim TopSheet As Worksheet
Dim MyCells As Range

Sheet1.Columns(4).AutoFit
                                        'quick fix for Excel formatting problem
Sheet1.Range("A1") = "Time"
                                        'if TOP sheet present, add two columns
                                        
If SheetExists("TOP") Then
   Set TopSheet = Worksheets("TOP")
   Call GetLastColumn(TopSheet, 1)
   Set MyCells = TopSheet.Range("A1")
   MyCells(1, ColNum + 1) = "User"
   MyCells(1, ColNum + 2) = "Arg"
   MyCells(2, ColNum + 1) = "=VLOOKUP(B2,UARG!B$2:H$" & CStr(numrows) & ",5,0)"
   MyCells(2, ColNum + 2) = "=VLOOKUP(B2,UARG!B$2:H$" & CStr(numrows) & ",7,0)"
   TopSheet.Range(MyCells(2, ColNum + 1), MyCells(TopRows, ColNum + 2)).FillDown
   TopSheet.Range(MyCells(2, ColNum + 1), MyCells(TopRows, ColNum + 2)).Copy
   TopSheet.Range(MyCells(2, ColNum + 1), MyCells(TopRows, ColNum + 2)).PasteSpecial Paste:=xlPasteValues
   Application.CutCopyMode = False
   End If
                                        'freeze the headings
Sheet1.Range("B2").Select
ActiveWindow.FreezePanes = True
Sheet1.Range("A1").Select
End Sub
                                       'v3.3.A
Sub PP_VM(numrows As Long, Sheet1 As Worksheet)
Dim Chart1 As ChartObject
Dim MyCells As Range

Call DelInt(Sheet1, numrows, 1)
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
                                        'graph the paging rates
Set MyCells = Sheet1.Range("H1:I" & CStr(numrows))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlArea, _
   SeriesLabels:=1, Title:="File-backed paging (kByes/sec) " & Host & " " & RunDate
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
   Call ApplyStyle(Chart1, 2, 2)
End With
                                        'graph the swapspace rates
Set MyCells = Sheet1.Range("J1:K" & CStr(numrows))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop2 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlArea, _
   SeriesLabels:=1, Title:="Swap-space activity (kBytes/sec) " & Host & " " & RunDate
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection(1).XValues = Sheet1.Range(Cells(2, 1), Cells(numrows, 1))
   Call ApplyStyle(Chart1, 2, 2)
End With
End Sub
                                       'last mod v3.3.0
Sub PP_WLM(numrows As Long, Sheet1 As Worksheet)
Dim aa0 As String
Dim aa1 As String
Dim Chart1 As ChartObject              'new chart object
Dim cName As String                    'WLM class name
Dim Graphdata As Range                 'range for charting
'Public Host As String                 'Hostname from AAA sheet
Dim i As Integer                       'column pointer (subclass start)
Dim j As Integer                       'column pointer (subclass end)
Dim NewName As String                  'Name of new WLM sheet
Dim NewSheet As Worksheet
'Public RunDate As String              'NMON run date from AAA sheet
Dim SectionName As String
Dim sName As String                    'WLM subclass name
    
SectionName = Sheet1.Name
Call DelInt(Sheet1, numrows, 1)
Select Case SectionName
Case "WLMBIO"
   Sheet1.Range("A1") = "Block I/O by WLM classes " & Host
Case "WLMCPU"
   Sheet1.Range("A1") = "%CPU by WLM classes " & Host
Case "WLMMEM"
   Sheet1.Range("A1") = "Memory by WLM classes " & Host
End Select
                                       'handle subclasses
                                       'convert subclass names to a std format
Sheet1.Range("A1:" & LastColumn & "1").Replace What:=",", Replacement:=".", _
   LookAt:=xlPart, SearchOrder:=xlByRows, MatchCase:=False
i = 7
Do
   cName = Sheet1.Cells(1, i) & "."
   If cName = "." Then Exit Do         'no WLM classes
   i = i + 1
   sName = Sheet1.Cells(1, i)
   If Left(sName, Len(cName)) = cName Then
                                       'found start of subclass
      j = i + 1
      Do
         sName = Sheet1.Cells(1, j)
         If sName = "" Then Exit Do
         If Left(sName, Len(cName)) <> cName Then Exit Do
         j = j + 1
      Loop
                                       'found end of subclass
      j = j - 1
      If j - i = 0 Then
         Sheet1.Columns(i).Delete   'no point creating a sheet
      Else
         NewName = SectionName & "." & Left(cName, Len(cName) - 1)
                                       'create the new sheet
         Sheets.Add.Name = NewName
         Set NewSheet = Worksheets(NewName)
         NewSheet.Move After:=Sheets(Sheets.Count)
         NewSheet.Range("A1:A" & CStr(numrows)) = Sheet1.Range("A1:A" & CStr(numrows)).Value
         aa0 = ConvertRef(i - 1) & "1:" & ConvertRef(j - 1) & CStr(numrows)
         NewSheet.Range("B1").Resize(numrows, Sheet1.Range(aa0).Columns.Count).Value = Sheet1.Range(aa0).Value
         Sheet1.Range(aa0).Delete
         Call WLMgraphs(numrows, NewSheet)
         If NewSheet.Name = "WLMCPU" And SheetExists("LPAR") Then Call WLMPCPU(numrows, NewSheet)
      End If
   Else
   End If
Loop
Call WLMgraphs(numrows, Sheet1)
If Sheet1.Name = "WLMCPU" And SheetExists("LPAR") Then Call WLMPCPU(numrows, Sheet1)
End Sub
                                       'v3.3.C
Sub WLMgraphs(numrows As Long, Sheet1 As Worksheet)
Dim Chart1 As ChartObject
Dim Graphdata As Range
Dim SectionName As String

If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub
SectionName = Sheet1.Name
Call GetLastColumn(Sheet1, 1)
                                       'produce avg/max graph
Set Graphdata = avgmax(numrows, Sheet1, 0)
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop1 + numrows * rH, cWidth, cHeight)
Chart1.Chart.ChartWizard Source:=Graphdata, PlotBy:=xlRows, SeriesLabels:=1, _
    Title:=Sheet1.Range("A1").Value & "  " & RunDate
                                       'apply customisation
With Chart1.Chart
   .SeriesCollection(1).XValues = Sheet1.Range("B1:" & LastColumn & "1")
   Call ApplyStyle(Chart1, 0, 3)
End With
                                    'produce area graph
Set Graphdata = Sheet1.Range("A1:" & LastColumn & CStr(numrows))
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, csTop2 + numrows * rH, cWidth, csHeight)
Chart1.Chart.ChartWizard Source:=Graphdata, Gallery:=xlArea, _
    Title:=Sheet1.Range("A1").Value & "  " & RunDate, _
    CategoryLabels:=1, SeriesLabels:=1, HasLegend:=True
                                    'apply customisation
With Chart1.Chart
     Call ApplyStyle(Chart1, 2, ColNum - 1)
End With

End Sub
                                       'last mod v3.3.E
Sub PP_ZZZZ(numrows As Long, Sheet1 As Worksheet)
Dim CurrentRow As Long                  'loop counter
Dim MyName As String                    'name of target sheet
Dim numTvals As Long                    'number of time values on target sheet
Dim NextSheet As Worksheet              'target sheet
Dim Toffset As Integer                  'Offset for VLOOKUP
'Public T1 As String                    'first timestamp
Dim Times As Range                      'pointer to actual times on ZZZZ sheet
Dim Tvalues As Range                    'area on target sheet
'Public xToD As String                  'Number format for ToD graphs

Sheet1.Columns("B").NumberFormat = "h:mm:ss"
Sheet1.Columns("C").NumberFormat = "dd-mmm-yy"
Sheet1.Cells(1, 4) = "=B1+C1"
If Application.WorksheetFunction.IsErr(Sheet1.Cells(1, 4)) Then
   Set Times = Sheet1.Range("B1:B" & CStr(numrows))
   Toffset = 2
Else
   Set Times = Sheet1.Range("D1:D" & CStr(numrows))
   Times.FillDown
   Times.Value = Times.Value
   Times.NumberFormat = xToD
   Toffset = 4
End If
t1 = Sheet1.Cells(First, 1)
Set Times = Times.Offset(First - 1)
                                    'update the snapshots value on the AAA sheet
Snapshots = numrows
Worksheets("AAA").Range("snapshots").Value = numrows
                                    'Then go through each sheet and replace all time values
UserForm1.Repaint
For Each NextSheet In Worksheets
   MyName = NextSheet.Name
   If MyName = "ZZZZ" Then Exit For
   With UserForm1
        .Label1.Caption = "Editing Time Values: " & MyName
        .Repaint
   End With
                                    'find how many rows on target sheet
   For CurrentRow = 2 To MaxRows - 1
      If NextSheet.Range("A1").Item(CurrentRow, 1) = "" Then Exit For
      numTvals = CurrentRow
   Next
                                    'handle TOP/UARG/SUMMARY sheets separately
   If InStr(1, "SUMMARY#TOP#UARG", MyName) > 0 Then
                                    'build the formulas etc.
      NextSheet.Range("IV2") = "=VLOOKUP(A2,ZZZZ!A$1:D$" & CStr(numrows) & "," & CStr(Toffset) & ")"
      If numTvals > 2 Then NextSheet.Range("IV2:IV" & CStr(numTvals)).FillDown
      NextSheet.Range("A2").Resize(numTvals - 1).Value = NextSheet.Range("IV2:IV" & CStr(numTvals)).Value
      NextSheet.Range("IV1").EntireColumn.Delete
      NextSheet.Columns("A").NumberFormat = "h:mm:ss"
   Else
      If NextSheet.Cells(2, 1).Value = t1 Then
         Set Tvalues = NextSheet.Range("A2:A" & CStr(numTvals))
         Tvalues.Value = Times.Value
         Tvalues.NumberFormat = "h:mm:ss"
         NextSheet.Activate
         NextSheet.Range("B2").Select
         ActiveWindow.FreezePanes = True
         NextSheet.Range("A1").Select
         If NextSheet.ChartObjects.Count > 0 Then ActiveWindow.ScrollRow = numTvals + 2
      End If
   End If
Next

End Sub
                                       '
Function SheetExists(sheetname As String) As Boolean
'returns TRUE if the sheet exists in the active workbook
    SheetExists = False
    On Error GoTo NoSuchSheet
    If Len(Sheets(sheetname).Name) > 0 Then
        SheetExists = True
        Exit Function
    End If
NoSuchSheet:
End Function
                                       'last mod v4.0
Sub SYS_SUMM()
Dim aa0 As String                       'temp var
Dim aa1 As String                       'temp var
Dim Chart1 As ChartObject               'new chart object
'Public First As Integer                'First time interval to process
'Public Last As Long                    'Last time interval to process
'Public Host As String                  'Hostname from AAA sheet
Dim MyCells As Range                    'temp var
Dim numrows As Long
'Public RunDate As String               'NMON run date from AAA sheet
Dim SectionName As String               'Name of new sheet
Dim Sheet1 As Worksheet                 'pointer to SYS_SUMM sheet
Dim shCPU As Worksheet                  'pointer to CPU_ALL sheet
Dim shDisk As Worksheet                 'pointer to DISK_SUMM sheet
Dim i As Integer                        'First row for data table

SectionName = "SYS_SUMM"
UserForm1.Label1.Caption = "Creating: " & SectionName
UserForm1.Repaint

If Not SheetExists("CPU_ALL") Then Exit Sub
If Not SheetExists("DISK_SUMM") Then Exit Sub
Set shCPU = Worksheets("CPU_ALL")
Set shDisk = Worksheets("DISK_SUMM")
Sheets.Add.Name = SectionName
Set Sheet1 = Worksheets(SectionName)
Sheet1.Move Before:=Worksheets("AAA")
numrows = Worksheets("AAA").Range("snapshots")
If Last < numrows Then numrows = Last
numrows = numrows - First + 1
                                        'Produce the graph on SYS_SUMM
Sheet1.Range("F1").ColumnWidth = 4
                                        'add top line
Application.Calculation = xlCalculationManual
aa0 = CStr(numrows + 1)
Sheet1.Range("B1").Value = "Samples"
Sheet1.Range("B1").Font.Bold = True
Sheet1.Range("C1").Value = numrows
Sheet1.Range("D1").Value = "First"
Sheet1.Range("D1").Font.Bold = True
If SheetExists("ZZZZ") Then
    ' this may fail if data has been truncated
    Sheet1.Range("E1").Value = "=INDEX(ZZZZ!A:B," & CStr(First) & ",2)"
    Sheet1.Range("G1").Value = "=INDEX(ZZZZ!A:B," & CStr(numrows + First - 1) & ",2)"
End If
    
Sheet1.Range("F1").Value = "Last"
Sheet1.Range("F1").Font.Bold = True
Sheet1.Range("E1:G1").NumberFormat = "h:mm:ss"
                                        'add I/O and CPU stats (similar to pirat)
Sheet1.Range("B3").Value = "Disk tps statistics"
Sheet1.Range("B3").Font.Bold = True
Sheet1.Range("G3:Z3").Font.Bold = True
Sheet1.Range("H3:L3").Value = Worksheets("CPU_ALL").Range("B1:F1").Value

Sheet1.Range("B4").Value = "Avg disk tps during an interval:"
Sheet1.Range("E4").Value = "=AVERAGE(DISK_SUMM!D2:D" & aa0 & ")"
Sheet1.Range("E4:E8").NumberFormat = "#,##0"
Sheet1.Range("G4").Value = "Avg"

Sheet1.Range("B5").Value = "Max disk tps during an interval:"
Sheet1.Range("E5").Value = "=MAX(DISK_SUMM!D2:D" & aa0 & ")"
Sheet1.Range("G5").Value = "Max"

Sheet1.Range("B6").Value = "Max disk tps interval time:"
Sheet1.Range("E6").Value = "=INDEX(DISK_SUMM!A2:A" & aa0 & ",MATCH(E5,DISK_SUMM!D2:D" & aa0 & ",0),1)"
Sheet1.Range("E6").NumberFormat = "h:mm:ss"

Sheet1.Range("G6").Value = "Max:Avg"
Sheet1.Range("H6").Value = "=IF(H4>0,H5/H4,0)"
Sheet1.Range("I6").Value = "=IF(I4>0,I5/I4,0)"
Sheet1.Range("J6").Value = "=IF(J4>0,J5/J4,0)"
Sheet1.Range("K6").Value = "=IF(K4>0,K5/K4,0)"
Sheet1.Range("L6").Value = "=IF(L4>0,L5/L4,0)"

If Not (Linux Or topas) And SheetExists("LPAR") Then
    Sheet1.Range("M6").Value = "=IF(M4>0,M5/M4,0)"
    Sheet1.Range("N6").Value = "=IF(N4>0,N5/N4,0)"

   Sheet1.Range("G3").Value = "VP_CPU:"
   Sheet1.Range("H4").Value = "=AVERAGE(LPAR!Q2:Q" & aa0 & ")"  ' user%
   Sheet1.Range("I4").Value = "=AVERAGE(LPAR!R2:R" & aa0 & ")"  ' sys %
   Sheet1.Range("J4").Value = "=AVERAGE(LPAR!S2:S" & aa0 & ")"  ' wait %
   Sheet1.Range("K4").Value = "=AVERAGE(LPAR!T2:T" & aa0 & ")"  ' idle %
   
   Sheet1.Range("H5").Value = "=MAX(LPAR!Q2:Q" & aa0 & ")"
   Sheet1.Range("I5").Value = "=MAX(LPAR!R2:R" & aa0 & ")"
   Sheet1.Range("J5").Value = "=MAX(LPAR!S2:S" & aa0 & ")"
   Sheet1.Range("K5").Value = "=MAX(LPAR!T2:T" & aa0 & ")"
    
   Sheet1.Range("M3").Value = "PhysCPU"
   Sheet1.Range("M4").Value = "=AVERAGE(LPAR!B2:B" & aa0 & ")"
   Sheet1.Range("M5").Value = "=MAX(LPAR!B2:B" & aa0 & ")"
   
   Sheet1.Range("N3").Value = "Virtual CPUs"
   Sheet1.Range("N4").Value = "=AVERAGE(LPAR!C2:C" & aa0 & ")"
   Sheet1.Range("N5").Value = "=MAX(LPAR!C2:C" & aa0 & ")"
   
   Sheet1.Range("O3").Value = "Other LPARs"
   Sheet1.Range("O4").Value = "=AVERAGE(LPAR!D2:D" & aa0 & ")"
   Sheet1.Range("O5").Value = "=MAX(LPAR!D2:D" & aa0 & ")"
      
   Sheet1.Range("P3").Value = "Pool CPUs"
   Sheet1.Range("P4").Value = "=AVERAGE(LPAR!E2:E" & aa0 & ")"
   Sheet1.Range("P5").Value = "=MAX(LPAR!E2:E" & aa0 & ")"
   
   Sheet1.Range("Q3").Value = "Entitled"
   Sheet1.Range("Q4").Value = "=AVERAGE(LPAR!F2:F" & aa0 & ")"
   Sheet1.Range("Q5").Value = "=MAX(LPAR!F2:F" & aa0 & ")"
   
   Sheet1.Range("R3").Value = "Weight"
   Sheet1.Range("R4").Value = "=AVERAGE(LPAR!G2:G" & aa0 & ")"
   Sheet1.Range("R5").Value = "=MAX(LPAR!G2:G" & aa0 & ")"
      
   Sheet1.Range("H4:Z7").NumberFormat = "#,##0.0"
   
 '  @RM - changing this back to what it was in 34a
   Sheet1.Range("L3").Value = "CPU%"
   Sheet1.Range("L4").Value = "=M4/LPAR!C2*100."
   Sheet1.Range("L5").Value = "=M5/LPAR!C2*100."
Else
   Sheet1.Range("G3").Value = "CPU:"
   Sheet1.Range("H4").Value = "=AVERAGE(CPU_ALL!B2:B" & aa0 & ")"   ' user%
   Sheet1.Range("H5").Value = "=MAX(CPU_ALL!B2:B" & aa0 & ")"
   
   Sheet1.Range("I4").Value = "=AVERAGE(CPU_ALL!C2:C" & aa0 & ")"   ' sys %
   Sheet1.Range("I5").Value = "=MAX(CPU_ALL!C2:C" & aa0 & ")"
   
   Sheet1.Range("J4").Value = "=AVERAGE(CPU_ALL!D2:D" & aa0 & ")"   ' wait %
   Sheet1.Range("J5").Value = "=MAX(CPU_ALL!D2:D" & aa0 & ")"
   
   Sheet1.Range("K4").Value = "=AVERAGE(CPU_ALL!E2:E" & aa0 & ")"   ' idle %
   Sheet1.Range("K5").Value = "=MAX(CPU_ALL!E2:E" & aa0 & ")"

'  @RM - changing CPU% calculation to simply be user% + Sys%
   Sheet1.Range("L3").Value = "CPU%"
   Sheet1.Range("L4").Value = "=H4+I4"
   Sheet1.Range("L5").Value = "=H5+I5"
End If
   
Sheet1.Range("H4:Z6").NumberFormat = "#,##0.0"

If topas And SheetExists("LPAR") Then
   Sheet1.Range("M3").Value = "PhysCPU"
   Sheet1.Range("M4").Value = "=AVERAGE(LPAR!B2:B" & aa0 & ")"
   Sheet1.Range("M5").Value = "=MAX(LPAR!B2:B" & aa0 & ")"
   'Sheet1.Range("M6").Value = "=M5/M4"
   Sheet1.Range("M4:M6").NumberFormat = "#,##0.0"
End If

Sheet1.Range("B7").Value = "Total number of Mbytes read:"
Sheet1.Range("E7").Value = "=SUM(DISK_SUMM!B2:B" & aa0 & ")*Interval/1000"
Sheet1.Range("E7").NumberFormat = "#,##0"

Sheet1.Range("B8").Value = "Total number of Mbytes written:"
Sheet1.Range("E8").Value = "=SUM(DISK_SUMM!C2:C" & aa0 & ")*Interval/1000"
Sheet1.Range("E8").NumberFormat = "#,##0"

Sheet1.Range("B9").Value = "Read/Write Ratio:"
Sheet1.Range("E9").Value = "=IF(E8>0,E7/E8,0)"
Sheet1.Range("E9").NumberFormat = "#,##0.0"
                                       'tidy up
Application.Calculation = xlCalculationAutomatic
Application.Calculate
Sheet1.Range("B1:Z29").Value = Sheet1.Range("B1:Z29").Value
Sheet1.Range("A1").Select
If Graphs = "LIST" And Not Checklist(Sheet1.Name) Then Exit Sub

If SheetExists("LPAR") Then
   Set shCPU = Worksheets("LPAR")
   Set MyCells = shCPU.Range("A1:B" & CStr(numrows + 1))
Else
   ' @RM 06/4/2015 - make sure clipboard is not getting full (had a user break on the next line without this due to clipboard being full)
   Application.CutCopyMode = False
   ' @RM 06/4/2015 - on CPU_ALL sheet CPU% moved from column F to J (because of Linux steal CPU% change)
   Set MyCells = Union(shCPU.Range("A1:A" & CStr(numrows + 1)), shCPU.Range("J1:J" & CStr(numrows + 1)))
End If
Set Chart1 = Sheet1.ChartObjects.Add(cLeft, cTop, cWidth, cHeight)
Chart1.Chart.ChartWizard Source:=MyCells, Gallery:=xlLine, Format:=2, _
   CategoryLabels:=1, SeriesLabels:=1, Title:="System Summary " & Host & "  " & RunDate
                                        'apply customisation
With Chart1.Chart
   .SeriesCollection.NewSeries
   With .SeriesCollection(2)
     .AxisGroup = 2
     .MarkerStyle = xlNone
     .Name = shDisk.Cells(1, 4)
     .Values = shDisk.Range("D2:D" & CStr(numrows + 1))
   End With
   Call ApplyStyle(Chart1, 1, 2)
   .Axes(xlValue).HasMajorGridlines = False
   .Axes(xlValue, xlPrimary).HasTitle = True
   If SheetExists("LPAR") Then
      .Axes(xlValue, xlPrimary).AxisTitle.Characters.Text = "#CPUs"
   Else
      .Axes(xlValue, xlPrimary).AxisTitle.Characters.Text = "usr%+sys%"
      .Axes(xlValue, xlPrimary).MaximumScale = 100
   End If
   .Axes(xlValue, xlSecondary).HasTitle = True
   .Axes(xlValue, xlSecondary).AxisTitle.Characters.Text = "Disk xfers"
   .Axes(xlValue, xlSecondary).MinimumScale = 0
   .SeriesCollection(1).Border.ColorIndex = 25
   .SeriesCollection(2).Border.ColorIndex = 26
End With
                                       'and move all the text below the graph
Set MyCells = Chart1.BottomRightCell
Sheet1.Range("A2:A" & CStr(MyCells.row - 2)).EntireRow.Insert
End Sub
                                       'last mod v3.3.0
Sub TidyUp(CPUList() As String)
'Public GotEMC As Variant           'True if either EMC or FAStT present
'Public GotESS As Variant           'True if EMC/ESS or FAStT present
'Public NumCPUs As Integer          'number of CPU sheets to move
'Public Reorder As Variant          'Reorder sheets after analysis (True/False)
Dim aa0 As String                   'First non-DISK sheet moved
Dim MyName As String                'name of the current sheet
Dim n As Integer                    'loop counter
Dim NextSheet As Worksheet          'temp var
Dim numdisks As Integer             'number of disk sheets to move
Dim LastSheet As Worksheet          'anchor for moves

UserForm1.Label1.Caption = "Tidying up"
UserForm1.Repaint

Application.DisplayAlerts = False
For n = 1 To 10
    If SheetExists("Sheet" + CStr(n)) Then
        Worksheets("Sheet" + CStr(n)).Delete
    End If
Next n
If Not SheetExists("ZZZZ") Then Exit Sub
                                        'delete empty DISK sheets
For Each NextSheet In Worksheets
    If Left$(NextSheet.Name, 4) = "DISK" Then
       If NextSheet.Range("B1") = "" Then NextSheet.Delete
    End If
Next
                                       'delete sheets without graphs
If NoList Then
   For Each NextSheet In Worksheets
       If InStr(1, List, NextSheet.Name) = 0 Then NextSheet.Delete
   Next
End If
Application.DisplayAlerts = True

If NoList Or Not Reorder Then Exit Sub
UserForm1.Label1.Caption = "Re-ordering sheets"
UserForm1.Repaint
If SheetExists("DISK_SUMM") Then Worksheets("DISK_SUMM").Move Before:=Worksheets(CPUList(1))

If Not m_GotESS Then
   Set LastSheet = Worksheets("ZZZZ")
   For n = 1 To NumCPUs
      Set NextSheet = Worksheets(CPUList(n))
      UserForm1.Label1.Caption = "Re-ordering sheet: " & NextSheet.Name
      UserForm1.Repaint
      NextSheet.Move After:=LastSheet
      Set LastSheet = NextSheet
   Next n
Else
                                        'move ESS/EMC and FILE... sheets
   Set LastSheet = Worksheets(CPUList(1))
   For Each NextSheet In Worksheets
      MyName = NextSheet.Name
      If MyName = "ZZZZ" Then Exit For
      If Left$(MyName, 1) > "D" Or Left$(MyName, 2) = "DG" Then
         UserForm1.Label1.Caption = "Re-ordering sheet: " & MyName
         UserForm1.Repaint
         NextSheet.Move Before:=LastSheet
         If aa0 = "" Then aa0 = MyName
      End If
   Next

   UserForm1.Label1.Caption = "Re-ordering DISK & summary sheets"
   UserForm1.Repaint
   Set LastSheet = Worksheets(aa0)
   Worksheets("DISKBUSY").Move Before:=LastSheet
   If SVCTimes Then Worksheets("DISKSERV").Move Before:=LastSheet
End If
If SheetExists("SYS_SUMM") Then Worksheets("SYS_SUMM").Move Before:=Worksheets(1)
If SheetExists("LPAR") Then
   Worksheets("LPAR").Move Before:=Worksheets("CPU_ALL")
   Worksheets("CPU_ALL").Move Before:=Worksheets(CPUList(1))
End If
If SheetExists("ERROR") Then Worksheets("ERROR").Move After:=Worksheets("AAA")
End Sub
                                       'last mod v3.3.0
Sub WLMPCPU(numrows As Long, Sheet1 As Worksheet)
Dim aa0 As String
Dim MyCells As Range
Dim NewName As String
Dim NewSheet As Worksheet
                                       'create a copy of the CPU sheet
NewName = Replace(Sheet1.Name, "CPU", "PCPU")
Sheet1.Copy After:=Sheets(Sheets.Count)
Sheets.Item(Sheets.Count).Name = NewName
Set NewSheet = Worksheets(NewName)
aa0 = NewSheet.Range("A1").Value
NewSheet.Range("A1") = Replace(aa0, "%", "Physical ")
                                       'and convert values to physical CPUs
Set MyCells = NewSheet.Range("B2:" & LastColumn & CStr(numrows))
MyCells = "=" & Sheet1.Name & "!B2/100*LPAR!$B2"
MyCells.Value = MyCells.Value
MyCells.NumberFormat = "0.00"
Call WLMgraphs(numrows, NewSheet)

End Sub

Public Sub QuickSort(vArray As Variant, inLow As Long, inHi As Long)

  Dim pivot   As Variant
  Dim tmpSwap As Variant
  Dim tmpLow  As Long
  Dim tmpHi   As Long

  tmpLow = inLow
  tmpHi = inHi

  pivot = vArray((inLow + inHi) \ 2)

  While (tmpLow <= tmpHi)

     While (vArray(tmpLow) < pivot And tmpLow < inHi)
        tmpLow = tmpLow + 1
     Wend

     While (pivot < vArray(tmpHi) And tmpHi > inLow)
        tmpHi = tmpHi - 1
     Wend

     If (tmpLow <= tmpHi) Then
        tmpSwap = vArray(tmpLow)
        vArray(tmpLow) = vArray(tmpHi)
        vArray(tmpHi) = tmpSwap
        tmpLow = tmpLow + 1
        tmpHi = tmpHi - 1
     End If

  Wend

  If (inLow < tmpHi) Then QuickSort vArray, inLow, tmpHi
  If (tmpLow < inHi) Then QuickSort vArray, tmpLow, inHi
End Sub

Public Sub ProcessFile(RawData As Workbook)
    Dim X As Long
    Dim buffer As String
    Dim lines() As String
    Dim worksheetnum As Integer
    Dim counter As Long
    
    If BigData = False Then
        ' Note: Workbooks.Open does not seem to open the entire contents if very large rows are encountered
        Set RawData = Workbooks.Open(Filename:=Filename, Format:=5)
    Else
        ' Create a new workbook (using Excel 2007+ format because of the default save setting above)
         Set RawData = Workbooks.Add(xlWBATWorksheet)
        
         ' Add the entire contents of the input file to the RawData workbook's first sheet
         X = 0
         
         UserForm1.Label1.Caption = "Reading " + Filename
         UserForm1.Repaint
      
         ' load the entire file into buffer
         Open Filename For Input As #5
         buffer = Input$(LOF(5), #5)
         Close #5
         
         UserForm1.Label1.Caption = "Dividing up data where vbLf occurs"
         UserForm1.Repaint
      
         ' split the buffer into the lines String array where vbLf occurs
         lines = Split(buffer, vbLf)
         ' sort the data (must do it now so the entire thing > MaxRows is sorted)
         UserForm1.Label1.Caption = "Sorting file"
         UserForm1.Repaint
         Call QuickSort(lines, 1, UBound(lines))
         
         worksheetnum = 1
         counter = 0
         
         UserForm1.Label1.Caption = "Adding " + CStr(UBound(lines)) + " lines to sheet(s)"
         UserForm1.Repaint
                  
         For X = 0 To UBound(lines)
             If counter >= MaxRows Then
                 ' add another worksheet whenever MaxRows is reached
                 worksheetnum = worksheetnum + 1
                 RawData.Sheets.Add After:=RawData.Sheets(RawData.Sheets.Count)
                 counter = 0
             End If
                          
             ' add everything but blank lines
             If Trim(lines(X)) <> "" Then
                RawData.Worksheets(worksheetnum).Cells(counter + 1, 1).Value = lines(X)
                counter = counter + 1
             End If
         Next X
    End If
End Sub


                                   'last mod v4.1
Sub DISKBUSYRK()
Dim aa0 As String                       'temp var
Dim aa1 As String                       'temp var
Dim Chart1 As ChartObject               'new chart object
Dim MyCells As Range                    'temp var
Dim numrows As Long
Dim SectionName As String               'Name of new sheet
Dim Sheet1 As Worksheet                 'pointer to SYS_SUMM sheet
Dim shCPU As Worksheet                  'pointer to CPU_ALL sheet
Dim shDisk As Worksheet                 'pointer to DISK* sheet
Dim i As Integer                        'First row for data table

Exit Sub

SectionName = "DISKBUSYRK"
UserForm1.Label1.Caption = "Creating: " & SectionName
UserForm1.Repaint

If Not SheetExists("DISKBUSY") Then Exit Sub

Set shDisk = Worksheets("DISKBUSY")
Sheets.Add.Name = SectionName
Set Sheet1 = Worksheets(SectionName)
Sheet1.Move Before:=Worksheets("AAA")
numrows = Worksheets("AAA").Range("snapshots")
If Last < numrows Then numrows = Last
numrows = numrows - First + 1
                                        
Call GetLastColumn(shDisk, 1)
Set MyCells = shDisk.Range("A" & CStr(numrows + 2) & ":" & LastColumn & CStr(numrows + 6))

MyCells.Copy Sheet1.Range("A" & CStr(1))
Application.CutCopyMode = False
                                        
                                        
End Sub

Public Sub CheckEsoteric(Sheet1 As Worksheet)
    Dim Section As Range
    'see if we have an EMC system, this could be named, 'power', 'emcpower' or 'hdiskpower
    If m_Esoteric = "" Then
        Set Section = Sheet1.UsedRange.Find("hdiskpower", LookAt:=xlPart)
        m_GotEMC = Not (Section Is Nothing)
        If m_GotEMC = False Then
            Set Section = Sheet1.UsedRange.Find("emcpower", LookAt:=xlPart)
            m_GotEMC = Not (Section Is Nothing)
            If m_GotEMC = False Then
                Set Section = Sheet1.UsedRange.Find("power", LookAt:=xlPart)
                m_GotEMC = Not (Section Is Nothing)
                If m_GotEMC = False Then
                    Set Section = Sheet1.UsedRange.Find("dac0", LookAt:=xlPart)
                    m_GotEMC = Not (Section Is Nothing)
                    If m_GotEMC Then
                        m_Esoteric = "dac"
                    End If
                Else
                    m_Esoteric = "power"
                End If
            Else
                m_Esoteric = "emcpower"
            End If
        Else
            m_Esoteric = "hdiskpower"
        End If
                
        m_GotEMC = m_Esoteric <> ""
    End If
End Sub
