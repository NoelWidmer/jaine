if not exist "dbg" mkdir dbg

jai src/build.jai -exe nw -output_path ../dbg

xcopy SDL2.dll dbg\ /Y
xcopy res dbg\res\ /E /Y