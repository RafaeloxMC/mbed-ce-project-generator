echo "Please enter the name for your new project:"
read name
echo "Please enter your build target:"
read target
echo "Creating project $name for $target..."
mkdir $name
cd ./$name
git init
git submodule add --depth 1 https://github.com/mbed-ce/mbed-os.git mbed-os

echo '{
   "target_overrides": {
      "*": {
         "platform.stdio-baud-rate": 115200,
         "platform.stdio-buffered-serial": 1,

         // Uncomment to use mbed-baremetal instead of mbed-os
         // "target.application-profile": "bare-metal"
      }
   }
}' > mbed_app.json5

echo '#include "mbed.h"

int main()
{
   while(true) {}

   // main() is expected to loop forever.
   // If main() actually returns the processor will halt
   return 0;
}' > main.cpp

echo "cmake_minimum_required(VERSION 3.19)
cmake_policy(VERSION 3.19...3.22)

set(MBED_APP_JSON_PATH mbed_app.json5)

include(mbed-os/tools/cmake/mbed_toolchain_setup.cmake)
project($name
    LANGUAGES C CXX ASM) 
include(mbed_project_setup)

add_subdirectory(mbed-os)

add_executable(\${PROJECT_NAME} main.cpp)
target_link_libraries(\${PROJECT_NAME} mbed-os) # Can also link to mbed-baremetal here
mbed_set_post_build(\${PROJECT_NAME})" > CMakeLists.txt

mkdir build
cd build
cmake .. -GNinja -DCMAKE_BUILD_TYPE=Develop -DMBED_TARGET=$target
ninja

echo "Done! Run the following command to flash the program: ninja flash-$name"
