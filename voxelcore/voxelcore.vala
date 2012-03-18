using libvoxelpress.vectors;
using libvoxelpress.plugins;

namespace voxelcore {
	int main (string[] args) {
		try {
			assert(Module.supported());
		} catch (Error e) {
			stdout.printf("Module loading not supported? o_O\n");
			return 1;
		}
		string executable = Filename.display_basename(args[0]);
		string plugins_path = args[0][0:-1*executable.length] + "plugins";
	   
		// FIXME use stuff like Glib.OptionContext for parsing options.
		if (args.length == 1) {
			stdout.printf("No input files;  nothing done.\n");
			return 0;
		}
		else {
			// Configure the pipeline
			var import_stage = new ImportStage(plugins_path);
	   
		
			try {
				// Attempt to start this stuff up!
				import_stage.feed(args[1]);
			} catch (IOError err) {
				stdout.printf("An IO error occured =(\n");
				return 1;
			} catch (VectorModelError err) {
				stdout.printf("A Vector model error occured =(\n");
				return 1;
			}
		}
		return 0;
	}
}