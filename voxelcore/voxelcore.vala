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
		try {
			assert(Thread.supported());
		} catch (Error e) {
			stdout.printf("Threading is not supported on this system? o_O\n");
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
			var vector_stage = new VectorStage(plugins_path);		
			import_stage.next = vector_stage;

			unowned Thread<void*> current_thread = Thread.self<void*>();
			current_thread.set_priority(ThreadPriority.URGENT);
	   
			try {
				// Attempt to start this stuff up!
				var benchmark = new Timer();
				benchmark.start();
				import_stage.feed(args[1]);
				//vector_stage.join();
				benchmark.stop();
				stdout.printf(" - Execution time: %s seconds\n", benchmark.elapsed(null).to_string());
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