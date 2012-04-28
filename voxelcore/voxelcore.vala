using libvoxelpress.plugins;
using libvoxelpress.vectors;
using libvoxelpress.fragments;

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

		string out_file = "";
		double resolution = 0.6;
		double thickness = 0.6;
		OptionEntry[] entries = new OptionEntry[] {
			OptionEntry () {
				long_name="outfile",
				short_name='o', 
				flags=OptionFlags.IN_MAIN,
				arg=OptionArg.FILENAME_ARRAY,
				arg_data=out_file,
				description="Where to save the results.",
				arg_description="file"
			},
			OptionEntry () {
				long_name="resolution",
				short_name='r', 
				flags=OptionFlags.IN_MAIN,
				arg=0,
				arg_data=&resolution,
				description="Grid resolution, in mm.",
				arg_description=".6"
			},
			OptionEntry () {
				long_name="thickness",
				short_name='t', 
				flags=OptionFlags.IN_MAIN,
				arg=0,
				arg_data=&thickness,
				description="Voxel height, in mm.",
				arg_description=".4"
			}
		};
		entries.resize(entries.length + 1); // crashes if you don't do this

		// Initialize pipeline stages
		var import_stage = new ImportStage(plugins_path);
		var vector_stage = new VectorStage(plugins_path, import_stage);

		// Setup option context & parse options
		var options = new OptionContext("file...");
		options.add_main_entries(entries, null);
		options.add_group(vector_stage.get_plugin_options());
		try {
			options.parse(ref args);
		} catch (OptionError err) {
			stdout.printf("Option error...?\n");
			return 1;
		}

		// Configure the pipeline
		import_stage.done.connect(() => {
				var count = import_stage.face_count;
				stdout.printf(@" # triangles imported: $count\n");
				vector_stage.speed_up();
				vector_stage.join();
			});
		vector_stage.done.connect(() => {
				var min = vector_stage.min;
				var max = vector_stage.max;
				var width = max.x - min.x;
				var depth = max.y - min.y;
				var height = max.z - min.z;

				stdout.printf(" # vector stage complete:\n");
				bool layer_shown = false;
				int z = min.z+27;
				var layer = vector_stage.debug.layers.fetch(z);
				if (layer != null) {
					string buf = "";
					for (int x=min.x; x<=max.x; x+=1) {
						buf += " ==> | ";
						for (int y=min.y; y<=max.y; y+=1) {
							Fragment? pick = layer.data.fetch(new Coordinate(x, y, z));
							if (pick == null) {
								buf += ".";
							}
							else {
								buf += "#";
							}
						}
					buf += "\n";
					}
					stdout.printf(buf);
				}
				else {
					stdout.printf("No layer at z=%s\n", z.to_string());
				}
				
				stdout.printf(@" - width=$width");
				stdout.printf(@", depth=$depth");
				stdout.printf(@", height=$height\n");
			});
		vector_stage.done.connect(() => {
				var min = vector_stage.min;
				var max = vector_stage.max;
				var width = max.x - min.x;
				var length = max.y - min.y;
				var depth = max.z - min.z;

				int[] data = {};
				for (int z=min.z; z<=max.z; z+=1) {
					var layer = vector_stage.debug.layers.fetch(z);

					for (int y=min.y; y<=max.y; y+=1) {
						for (int x=max.x; x<=max.x; x+=1) {
							Fragment? pick = layer.data.fetch(new Coordinate(x,y,z));
							data += pick != null ? 1 : 0;
						}
					}
				}

				/*
				stdout.printf(" - data size=%s\n", data.length.to_string());
				stdout.printf(@" - width=$width");
				stdout.printf(@", length=$length");
				stdout.printf(@", depth=$depth\n");
				*/
				var file = File.new_for_path("../scratch/test.json");
				if (file.query_exists ()) {
					file.delete ();
				}
				var OUT = new DataOutputStream(file.create(FileCreateFlags.REPLACE_DESTINATION));
				OUT.put_string(json_dump(width,length,depth,1,1,1,encode(data)));

				stdout.printf("----> Exported json file to scratch folder\n");

			});

		// Start this fancy thing up!
		try {
			if (out_file == "") {
				stdout.printf("No outfile given, nothing done.\n");
				return 1;
			}
			if (args.length > 0) {
				unowned Thread<void*> current_thread = Thread.self<void*>();
				current_thread.set_priority(ThreadPriority.URGENT);

				// build pipeline
				vector_stage.setup_pipeline(resolution, thickness);
				stdout.printf(" # pipeline configured\n");

				// fire it up
				benchmark(() => { import_stage.import(args); });
			}
			else {
				stdout.printf("Nothing to do.\n");
			}
		} catch (IOError err) {
			stdout.printf("An IO error occured =(\n");
			return 1;
		} catch (VectorModelError err) {
			stdout.printf("A Vector model error occured =(\n");
			return 1;
		} catch (OptionError err) {
			stdout.printf("Option error?\n");
			return 1;		
		}
		return 0;
	}
}