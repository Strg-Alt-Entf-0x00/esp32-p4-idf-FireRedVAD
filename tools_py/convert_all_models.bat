@echo off
echo =======================================================
echo   FireRedVAD ESP32-P4 - Model Converter
echo =======================================================
echo.
echo Converting PyTorch models to .frvd formats...
echo Output: examples/console_vad/ and examples/console_vad_dev/
echo.

cd /d "%~dp0"

echo [1/4] Generating FP32 models...
python models_converter\export_weights.py --all --output-dir ..\examples\console_vad\models_frvd
python models_converter\export_weights.py --all --output-dir ..\examples\console_vad_dev\models_frvd

echo.
echo [2/4] Generating INT16 models...
python models_converter\export_weights.py --all --output-dir ..\examples\console_vad\models_frvd --quantize-int16
python models_converter\export_weights.py --all --output-dir ..\examples\console_vad_dev\models_frvd --quantize-int16

echo.
echo [3/4] Generating INT8 models...
python models_converter\export_weights.py --all --output-dir ..\examples\console_vad\models_frvd --quantize-int8
python models_converter\export_weights.py --all --output-dir ..\examples\console_vad_dev\models_frvd --quantize-int8

echo.
echo [4/4] Generating INT8-CH models...
python models_converter\export_weights.py --all --output-dir ..\examples\console_vad\models_frvd --quantize-int8-per-ch
python models_converter\export_weights.py --all --output-dir ..\examples\console_vad_dev\models_frvd --quantize-int8-per-ch

echo.
echo =======================================================
echo Done! Models are saved in:
echo   - examples/console_vad/models_frvd/
echo   - examples/console_vad_dev/models_frvd/
echo.
echo NOTE: Models are also committed in the repository.
echo       No download needed for end users.
echo =======================================================
pause
