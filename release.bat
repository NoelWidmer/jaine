if not exist "release" mkdir release

jai src/build.jai -release -exe nw -output_path ../release

xcopy SDL2.dll release\ /Y
xcopy res release\res\ /E /Y