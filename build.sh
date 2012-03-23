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
valac --pkg gee-1.0 --pkg gio-2.0 --library=libvoxelpress -H libvoxelpress.h ../libvoxelpress/debug.vala ../libvoxelpress/vector_model.vala ../libvoxelpress/vector_math.vala ../libvoxelpress/plugin_api.vala -X -fPIC -X -shared -o libvoxelpress.so -X -lm

# compile voxelcore
echo ""
echo "------ voxelcore ------"
valac --thread --pkg gee-1.0 --pkg gio-2.0 --pkg gmodule-2.0 libvoxelpress.vapi ../voxelcore/plugin_repository.vala ../voxelcore/import_stage.vala ../voxelcore/vector_stage.vala ../voxelcore/voxel_stage.vala ../voxelcore/vector_fragmentation.vala ../voxelcore/threading.vala ../voxelcore/voxelcore.vala -X libvoxelpress.so -X -I. -o voxelpress

# compile standard plugins
echo ""
echo "------ import plugin obj-model ------"
valac --pkg gee-1.0 --pkg gio-2.0 --pkg gmodule-2.0 libvoxelpress.vapi ../voxelcore/plugins/import/obj_model.vala -C
gcc -shared -fPIC $(pkg-config --cflags --libs glib-2.0 gmodule-2.0 gee-1.0 gio-2.0) -o plugins/import/obj_model.so obj_model.c libvoxelpress.so -I.
rm obj_model.c

echo ""
echo "------ vector plugin scale ------"
valac --pkg gee-1.0 --pkg gio-2.0 --pkg gmodule-2.0 libvoxelpress.vapi ../voxelcore/plugins/vector/scale.vala -C
gcc -shared -fPIC $(pkg-config --cflags --libs glib-2.0 gmodule-2.0 gee-1.0 gio-2.0) -o plugins/vector/scale.so scale.c libvoxelpress.so -I.
rm scale.c

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