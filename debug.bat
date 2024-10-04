if not exist "debug" mkdir debug

jai src/build.jai -exe tee -output_path ../debug

xcopy SDL2.dll debug\ /Y
xcopy res debug\res\ /E /Y