#!/system/bin/sh

REM_INFO_FILE=/data/rem.txt
REM_PANIC_FILE=/data/kprem.txt

#remove the REM file
if [ -f $REM_INFO_FILE ]; then
    rm $REM_INFO_FILE
fi

if [ -f $REM_PANIC_FILE ]; then
    rm $REM_PANIC_FILE
fi
