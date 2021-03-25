Attribute VB_Name = "NewMacros"
Sub refresh()
Attribute refresh.VB_ProcData.VB_Invoke_Func = "Normal.NewMacros.refresh"
'
' refresh Macro
'
'
    Selection.WholeStory
    Selection.Fields.Update
End Sub
Sub merge()
'
' merge Macro
'
'
    ChangeFileOpenDirectory "C:\auto_nmon\tmp"
    
    Dim MyFile As String
    Dim OutFile As String
        
  
    MyFile = Dir("*.docx")
    Do While MyFile <> ""
       Selection.InsertFile FileName:=MyFile, Range:="", _
         ConfirmConversions:=False, Link:=False, Attachment:=False
        MyFile = Dir
    Loop
            
End Sub


