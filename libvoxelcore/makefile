#### Makefile for libvoxelpress and voxelcore

# commands
VC = valac
CC = gcc

# compiler flags
COMMON_VFLAGS = --pkg gee-1.0 --pkg gio-2.0 --pkg gmodule-2.0 --target-glib=2.32 -X -lm
DEBUG_VFLAGS = -g --save-temps -o debug.out
#PLUGIN_VFLAGS = bin/libvoxelpress.vapi -C
#PLUGIN_CFLAGS = -shared -fPIC $$(pkg-config --cflags --libs glib-2.0 gmodule-2.0 gee-1.0 gio-2.0) -I./bin libvoxelpress.so
#LIBVPRESS_VFLAGS = --library=libvoxelpress -H bin/libvoxelpress.h -X -lm -X -fPIC -X -shared -o libvoxelpress.so
#VOXELCORE_VFLAGS = --thread bin/libvoxelpress.vapi --pkg json-glib-1.0 -X libvoxelpress.so -X -I./bin -o bin/voxelpress

# source code files
LIBVPRESS_SRC = materials/interfaces.vala \
		materials/color_material.vala \
		vector_models/interfaces.vala \
		voxel_models/interfaces.vala \
		voxel_models/raster_layer.vala \
		voxel_models/data_block.vala \
		voxel_models/voxel_model.vala \
		voxel_models/voxel.vala 
		#vector_models/*.vala


#### targets

#all: reset_build build_folder libvoxelpress voxelcore plugins quick_run


debug:
	echo ""
	echo "------ voxelpress debug ------"
	$(VC) $(COMMON_VFLAGS) $(DEBUG_VFLAGS) $(LIBVPRESS_SRC) debug.vala