rm test_voxelpress.sh
rm -R bin
mkdir bin
cd bin
mkdir plugins
mkdir plugins/import
mkdir plugins/vector
mkdir plugins/voxel
mkdir plugins/export
mkdir backends

# compile libvoxelpress
echo ""
echo "------ libvoxelpress ------"
valac --pkg gee-1.0 --pkg gio-2.0 --library=libvoxelpress -H libvoxelpress.h ../libvoxelpress/debug.vala ../libvoxelpress/VectorModel.vala ../libvoxelpress/plugin-api.vala -X -fPIC -X -shared -o libvoxelpress.so

# compile voxelcore
echo ""
echo "------ voxelcore ------"
valac --pkg gee-1.0 --pkg gio-2.0 --pkg gmodule-2.0 libvoxelpress.vapi ../voxelcore/plugin-repository.vala ../voxelcore/import_stage.vala ../voxelcore/vector_stage.vala ../voxelcore/voxelcore.vala -X libvoxelpress.so -X -I. -o voxelpress

# compile standard plugins
echo ""
echo "------ import plugin obj-model ------"
valac --pkg gee-1.0 --pkg gio-2.0 --pkg gmodule-2.0 libvoxelpress.vapi ../voxelcore/plugins/import/obj-model.vala -C
gcc -shared -fPIC $(pkg-config --cflags --libs glib-2.0 gmodule-2.0 gee-1.0 gio-2.0) -o plugins/import/obj-model.so obj-model.c libvoxelpress.so -I.
rm obj-model.c

# maybe this one should be optional, but too bad =)
echo ""
echo "------ vector plugin derp-adjustment ------"
valac --pkg gee-1.0 --pkg gio-2.0 --pkg gmodule-2.0 libvoxelpress.vapi ../voxelcore/plugins/vector/derp.vala -C
gcc -shared -fPIC $(pkg-config --cflags --libs glib-2.0 gmodule-2.0 gee-1.0 gio-2.0) -o plugins/vector/derp.so derp.c libvoxelpress.so -I.
rm derp.c




# TODO compile standard backends

# for testing, I guess
cd ..
echo "cd bin; LD_LIBRARY_PATH=. ./voxelpress \$@" >> test_voxelpress.sh
chmod +x test_voxelpress.sh

# wrap up?
echo ""
echo "Done."