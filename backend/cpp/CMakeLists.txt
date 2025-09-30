cmake_minimum_required(VERSION 3.14)
project(cpp_backend CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED True)

# Find packages
find_package(Crow REQUIRED)
find_package(nlohmann_json REQUIRED)

# Add executable
add_executable(cpp_backend main.cpp)

# Link libraries
target_link_libraries(cpp_backend PRIVATE Crow::Crow nlohmann_json::nlohmann_json)