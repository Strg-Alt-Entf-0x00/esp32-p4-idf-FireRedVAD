@echo off
echo =======================================================
echo   FireRedVAD ESP32-P4 - PyTorch Model Downloader
echo =======================================================
echo.
echo Downloading raw .pth.tar models from HuggingFace...
echo.

cd /d "%~dp0models_downloader"
python download_py_models_fireredvad.py --all

echo.
pause
