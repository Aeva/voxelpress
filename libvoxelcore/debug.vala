

using libvoxelcore.voxel_model;
using libvoxelcore.vector_model;
using libvoxelcore.loaders;


bool print_layer(VoxelModel model, int z) {
	if (model.layers[z] == null) {
		return false;
	}
	int half_x = model.model_width /2;
	int half_y = model.model_length /2;

	var layer = (RasterLayer) model.layers[z];
	string render = "";

	for (int y=half_y*-1; y<=half_y; y+=1) {
		for (int x=half_x*-1; x<=half_x; x+=1) {
			VoxelKind? vox = layer[x, y];
			if (vox == null) {
				render += " -";
			}
			else {
				render += " #";
			}
		}
		render += "\n";
	}
	
	stdout.printf(render);
	return true;
}


int main(string[] args) {
	double build_width = 9.0; //200.0;
	double build_length = 9.0; //200.0;
	double build_height = 8.0; //100.0;
	double layer_height = 0.4;
	double nozzle_diameter = 0.5;

	double xy_res = 1/(nozzle_diameter/2.0);
	double z_res = 1/layer_height;

	var model = new VoxelModel(build_width, build_length, build_height,
						   xy_res, z_res);


	var vec_test = new VectorModel();
	vec_test.on_face_created.connect((face) => {
			stdout.printf("... A face was added to the vector model\n");
		});

	var vert1 = new Vertex(1, 0, 0, null);
	var vert2 = new Vertex(0, 1, 0, null);
	var vert3 = new Vertex(0, 0, 1, null);


	stdout.printf("debug derp\n");
	vec_test.add_tri(vert1, vert2, vert3);



	model[0, 0, 0] = new Voxel();
	for (int i=-5; i<=5; i+=1) {
		model[0, -i, i] = new Voxel();
		model[-i, 0, i] = new Voxel();
		model[0, i, i] = new Voxel();
		model[i, 0, i] = new Voxel();		
	}

	model[8, 8, 0] = new Voxel();
	model[7, 8, 0] = new Voxel();
	model[6, 7, 0] = new Voxel();
	model[5, 7, 0] = new Voxel();
	model[4, 6, 0] = new Voxel();
	model[3, 6, 0] = new Voxel();
	model[2, 5, 0] = new Voxel();
	model[1, 5, 0] = new Voxel();
	model[0, 4, 0] = new Voxel();
	model[-1, 4, 0] = new Voxel();
	model[-2, 3, 0] = new Voxel();
	model[-3, 3, 0] = new Voxel();
	model[-4, 2, 0] = new Voxel();
	model[-5, 2, 0] = new Voxel();






	stdout.printf(" - %s --> %g\n", "page_width", model.page_width);
	stdout.printf(" - %s --> %g\n", "page_length", model.page_length);
	stdout.printf(" - %s --> %g\n", "page_height", model.page_height);
	stdout.printf(" - %s --> %g\n", "xy_res", model.xy_res);
	stdout.printf(" - %s --> %g\n", "z_res", model.z_res);
	stdout.printf(" - %s --> %d\n", "model_width", model.model_width);
	stdout.printf(" - %s --> %d\n", "model_length", model.model_length);
	stdout.printf(" - %s --> %d\n", "model_height", model.model_height);
	stdout.printf(" - %s --> %d\n", "min_x", model.min_x);
	stdout.printf(" - %s --> %d\n", "max_x", model.max_x);
	stdout.printf(" - %s --> %d\n", "min_y", model.min_y);
	stdout.printf(" - %s --> %d\n", "max_y", model.max_y);
	stdout.printf(" - %s --> %d\n", "min_z", model.min_z);
	stdout.printf(" - %s --> %d\n", "max_z", model.max_z);
	stdout.printf(" - %s --> %d\n", "block_size", model.block_size);
	stdout.printf(" - %s --> %d\n", "empty", model.empty ? 1 : 0);

	stdout.printf("\nPress Enter to see cross sections...");
	stdin.read_line();

	for (int i=model.min_z; i<=model.max_z; i+=1) {
		stdout.printf("\n\n");
		var printed = print_layer(model, i);
		if (printed) {
			stdout.printf(@"\n( z: $i ) Press Enter...");
			stdin.read_line();
		}
	}


	return 0;
}