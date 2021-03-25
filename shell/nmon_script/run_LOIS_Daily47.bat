cd C:\NMON\out

copy controlLOIS.txt control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonD47.xlsm"

move /Y wes01_1* wes01.xlsx
move /Y wes02_1* wes02.xlsx
move /Y ihs01_1* ihs01.xlsx
move /Y ihs02_1* ihs02.xlsx
move /Y was01_1* was01.xlsx
move /Y was02_1* was02.xlsx
move /Y icm01_1* icm01.xlsx
move /Y icm02_1* icm02.xlsx
move /Y tsm01_1* tsm01.xlsx
move /Y ipm02_1* ipm02.xlsx

set MacroName=MACRO.XLSM!Macro1
"C:\Program Files\Microsoft Office\Office14\excel.exe" wes01.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" wes02.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ihs01.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ihs02.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" was01.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" was02.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" icm01.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" icm02.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" tsm01.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ipm02.xlsx MACRO.XLSM 
