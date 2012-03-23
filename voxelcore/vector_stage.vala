using Gee;
using libvoxelpress.plugins;
using libvoxelpress.vectors;
using libvoxelpress.debug;




namespace voxelcore {
    public class VectorStage: GLib.Object {
		private WorkerPool<Face> thread_pool {get; set;}
        public PluginRepository<VectorPlugin> repository {get; private set;}
        public ArrayList<VectorPlugin> pipeline {get; set;}
		private AsyncQueue<Face?> faces = new AsyncQueue<Face?>();

		public bool started { get { return thread_pool.running; } }
		public bool active { get { return thread_pool.running && !thread_pool.dry_up; } }


		public signal void done();

        public VectorStage (string search_path, ImportStage import_stage) {
            repository = new PluginRepository<VectorPlugin> (search_path + "/vector");
            pipeline = new ArrayList<VectorPlugin>();
            try {
				thread_pool = new WorkerPool<Face> (faces, 1, true);
            } catch (ThreadError e) {
                stdout.printf("Failed to create thread pool.\n");
            }
            // FIXME: Sort plugins by priority, and ignore explicit plugins when appropriate.
            // FIXME: Add "fragmentation" stuff to the end of each pipeline.
            foreach (var plugin in repository.plugins) {
                pipeline.add(plugin.create_new());
            }
			pipeline.add(new Vector2Fragment());
			import_stage.new_face.connect(feed);
			thread_pool.event_hook.connect(worker_func);
			thread_pool.start();
        }

		private void feed (Face face) {
			faces.push(face);
		}

		public void speed_up () {
			thread_pool.increase_pool(2);
		}

		public void join () {
			if (active) {
				thread_pool.join_all();
			}
			done();
		}

		private void worker_func (Face face) {
			foreach (VectorPlugin stage in pipeline) {
				try {
					stage.transform(face);
				} catch (VectorModelError e) {
					// FIXME do something useful here
				}
			}
		}
    }


	public class Vector2Fragment : GLib.Object, VectorPlugin {
		// implied final plugin for the vector_stage
		public void transform (Face face) throws VectorModelError {
			//stdout.printf(".");
		}
	}
}