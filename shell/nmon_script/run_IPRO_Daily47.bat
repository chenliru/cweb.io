cd C:\NMON\out

copy controlIPRO.txt control.txt
"C:\Program Files\Microsoft Office\Office14\excel.exe" "aNmonD47.xlsm"

move /Y ecm01_1* ecm01.xlsx
move /Y ecm02_1* ecm02.xlsx
move /Y ecm03_1* ecm03.xlsx
move /Y ecm04_1* ecm04.xlsx
move /Y ecm05_1* ecm05.xlsx
move /Y ecm06_1* ecm06.xlsx
move /Y ecm07_1* ecm07.xlsx
move /Y ecm08_1* ecm08.xlsx
move /Y ecm09_1* ecm09.xlsx
move /Y ecm10_1* ecm10.xlsx
move /Y ecm11_1* ecm11.xlsx

set MacroName=MACRO.XLSM!Macro1
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm01.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm02.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm03.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm04.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm05.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm06.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm07.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm08.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm09.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm10.xlsx MACRO.XLSM 
"C:\Program Files\Microsoft Office\Office14\excel.exe" ecm11.xlsx MACRO.XLSM 
