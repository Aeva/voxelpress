

namespace voxelcore {

	int main (string[] args) {
		if (args.length == 1) {
			stdout.printf("No input files;  nothing done.\n");
			return 0;
		}
		else {
			// test out obj loading code
			try {
				IVectorModel model = new ObjModel(args[1]);
				var face_count = model.faces.size;
				stdout.printf("Opened a model!\n");
				stdout.printf(@"The model contains $face_count faces");
			} catch (IOError err) {
				stdout.printf("An IO error occured =(\n");
			} catch (VectorModelError err) {
				stdout.printf("A Vector model error occured =(\n");
			}
		}
		return 0;
	}
}