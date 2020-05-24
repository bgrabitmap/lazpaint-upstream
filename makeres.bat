@echo off
REM creating resource, only necessary when compiling with FPC
windres lazpaint\lazpaint.rc lazpaint\lazpaint.res --preprocessor=type
if not exist "lazpaint\lazpaint.res" goto error
exit /b 0

:error
echo Failed to create lazpaint\lazpaint.res. windres may not be in the PATH.
exit /b 1

