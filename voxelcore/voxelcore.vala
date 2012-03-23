using libvoxelpress.vectors;
using libvoxelpress.plugins;

namespace voxelcore {


	delegate void VoidFunction();
	void benchmark (VoidFunction run) {
		var benchmark = new Timer();
		benchmark.start();
		run();
		benchmark.stop();
		
		var minutes = Math.floor(benchmark.elapsed(null)/60);
		var seconds = Math.floor(benchmark.elapsed(null));
		var milliseconds = Math.floor(benchmark.elapsed(null)*1000);
		if (minutes > 0) {
			stdout.printf(" # Execution time: %s minute(s)\n", minutes.to_string());
		}
		else if (seconds > 0) {
			stdout.printf(" # Execution time: %s second(s)\n", seconds.to_string());
		}
		else {
			stdout.printf(" # Execution time: %s millisecond(s)\n", milliseconds.to_string());
		}
	}


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
			var vector_stage = new VectorStage(plugins_path, import_stage.faces);
			import_stage.done.connect(() => {
					var count = VectorModel.face_count;
					stdout.printf(@" # triangles processed: $count\n");
					vector_stage.speed_up();
					vector_stage.join();
				});

			unowned Thread<void*> current_thread = Thread.self<void*>();
			current_thread.set_priority(ThreadPriority.URGENT);
	   
			try {
				// Attempt to start this stuff up!
				stdout.printf(" # pipeline configured\n");
				benchmark(() => {
						import_stage.feed(args[1]);
					});
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