# FireVAD Console Example
cmake_minimum_required(VERSION 3.16)

# Add esp_firevad component from parent directory (two levels up = root)
set(EXTRA_COMPONENT_DIRS ../..)

include($ENV{IDF_PATH}/tools/cmake/project.cmake)
project(firered_vad_console)

# Prepare SPIFFS image directory AFTER project initialization
# Copies models and audio files into a staging directory for SPIFFS embedding
set(SPIFFS_IMAGE_DIR "${CMAKE_BINARY_DIR}/spiffs_staging")

# Only prepare SPIFFS if source directories exist
if(EXISTS "${CMAKE_SOURCE_DIR}/models_frvd" AND EXISTS "${CMAKE_SOURCE_DIR}/example_wave")
    file(MAKE_DIRECTORY ${SPIFFS_IMAGE_DIR})
    
    file(GLOB_RECURSE MODEL_FILES RELATIVE "${CMAKE_SOURCE_DIR}/models_frvd" "${CMAKE_SOURCE_DIR}/models_frvd/*")
    file(GLOB_RECURSE AUDIO_FILES RELATIVE "${CMAKE_SOURCE_DIR}/example_wave" "${CMAKE_SOURCE_DIR}/example_wave/*")
    
    # Copy model files
    foreach(file ${MODEL_FILES})
        configure_file("${CMAKE_SOURCE_DIR}/models_frvd/${file}" 
                      "${SPIFFS_IMAGE_DIR}/models_frvd/${file}" COPYONLY)
    endforeach()
    
    # Copy audio files
    foreach(file ${AUDIO_FILES})
        configure_file("${CMAKE_SOURCE_DIR}/example_wave/${file}" 
                      "${SPIFFS_IMAGE_DIR}/example_wave/${file}" COPYONLY)
    endforeach()
    
    # Create SPIFFS partition image from staging directory
    spiffs_create_partition_image(storage ${SPIFFS_IMAGE_DIR} FLASH_IN_PROJECT)
    
    message(STATUS "SPIFFS image prepared with models and audio files")
else()
    message(WARNING "models_frvd or example_wave directories not found - SPIFFS will be empty")
endif()

