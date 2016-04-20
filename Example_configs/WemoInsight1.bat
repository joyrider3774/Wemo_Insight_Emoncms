@echo off
:WemoInsight1
WemoInsightEmoncms.exe -conf WemoInsight1.conf
echo WemoInsight1 CRASHED RESTARTING
goto WemoInsight1