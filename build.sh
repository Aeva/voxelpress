rm test_voxelpress.sh
rm -R bin
mkdir bin
cd bin
mkdir plugins
mkdir backends

# compile libvoxelpress
valac --pkg gee-1.0 --library=libvoxelpress -H libvoxelpress.h ../libvoxelpress/IVectorModel.vala ../libvoxelpress/plugin-api.vala -X -fPIC -X -shared -o libvoxelpress.so

# compile voxelcore
valac --pkg gee-1.0 --pkg gio-2.0 --pkg gmodule-2.0 libvoxelpress.vapi ../voxelcore/plugin-repository.vala ../voxelcore/voxelcore.vala -X libvoxelpress.so -X -I. -o voxelpress

# TODO compile standard plugins

# TODO compile standard backends

# for testing, I guess
cd ..
echo "cd bin; LD_LIBRARY_PATH=. ./voxelpress \$@" >> test_voxelpress.sh
chmod +x test_voxelpress.sh

# wrap up?
rm *.c
echo "Done."