@echo off

rmdir /q /s "html"
mkdir "html"

"C:\Program Files (x86)\Natural Docs\NaturalDocs.exe" .\natural_docs\ -r
