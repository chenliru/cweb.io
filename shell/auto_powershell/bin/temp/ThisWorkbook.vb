
Private Sub Workbook_Open()
Dim Batch As Integer
Dim Filename As String

Dim Sheet1 As Worksheet
Set Sheet1 = ThisWorkbook.Worksheets(1)
Filename = Sheet1.Range("Filelist").Value
Batch = 1

If Filename <> "" Then
   Call Main(Batch)
   If Batch = 1 Then
      If Workbooks.Count = 1 Then
         Application.DisplayAlerts = False
         Application.Quit
      Else
         ThisWorkbook.Close False
      End If
   End If
End If
End Sub
