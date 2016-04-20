@echo off
:WemoInsight2
WemoInsightEmoncms.exe -conf WemoInsight2.conf
echo WemoInsight2 CRASHED RESTARTING
goto WemoInsight2