using libvoxelpress;

namespace voxelcore {

	private void print_vector (Vector vector) {
		double a = vector.vector[0];
		double b = vector.vector[1];
		double c = vector.vector[2];
		stdout.printf(@" ( $a, $b, $c )");
	}

	private void print_face (Face face) {
		stdout.printf("Vertices:");
		for (int i=0; i<3; i+=1) {
			print_vector(face.vertices[i]);
		}
		stdout.printf("\n");
		stdout.printf("normals:");
		for (int i=0; i<3; i+=1) {
			print_vector(face.normals[i]);
		}
		stdout.printf("\n");
	}

	private void do_something_neat(IVectorModel model) {
		stdout.printf("Opened a model!\n");
		var face_count = model.faces.size; 
		stdout.printf(@"The model contains $face_count faces!!!!\n");
		print_face(model.faces[0]);
	}

	int main (string[] args) {
		// FIXME use stuff like Glib.OptionContext for parsing options.
		if (args.length == 1) {
			stdout.printf("No input files;  nothing done.\n");
			return 0;
		}
		else {
			try {
				IVectorModel model = new ObjModel(args[1]);
				do_something_neat(model);
			} catch (IOError err) {
				stdout.printf("An IO error occured =(\n");
			} catch (VectorModelError err) {
				stdout.printf("A Vector model error occured =(\n");
			}
		}
		return 0;
	}
}