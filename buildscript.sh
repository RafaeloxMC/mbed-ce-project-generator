echo "Enter project name:"
read project
echo "Enter build target:"
read target

cd ./$project/build

cmake .. -GNinja \
             -DCMAKE_BUILD_TYPE=Develop \
             -DMBED_TARGET=$target \
             -DMBED_UPLOAD_METHOD=STLINK

ninja

openocd \
             -f /usr/share/openocd/scripts/interface/stlink.cfg \
             -f /usr/share/openocd/scripts/target/stm32l1.cfg \
             -c "program $project.elf verify reset exit"
