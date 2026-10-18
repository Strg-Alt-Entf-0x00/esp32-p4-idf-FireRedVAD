# FireVAD Console Example
cmake_minimum_required(VERSION 3.16)

# Add esp_firevad component from parent directory (two levels up = root)
set(EXTRA_COMPONENT_DIRS ../..)

include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(firered_vad_console)

