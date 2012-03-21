using Gee;
using libvoxelpress.plugins;
using libvoxelpress.vectors;




namespace voxelcore {
    public class VectorStage: GLib.Object {
		private WorkerPool<Face> thread_pool {get; set;}
        public PluginRepository<VectorPlugin> repository {get; private set;}
        public ArrayList<VectorPlugin> pipeline {get; set;}
        
        public VectorStage (string search_path) {
            repository = new PluginRepository<VectorPlugin> (search_path + "/vector");
            pipeline = new ArrayList<VectorPlugin>();
            try {
				thread_pool = new WorkerPool<Face> (4, true);
            } catch (ThreadError e) {
                stdout.printf("Failed to create thread pool.\n");
            }

            // FIXME: Sort plugins by priority, and ignore explicit plugins when appropriate.
            // FIXME: Add "fragmentation" stuff to the end of each pipeline.
            foreach (var plugin in repository.plugins) {
                pipeline.add(plugin.create_new());
            }
			thread_pool.event_hook.connect(worker_func);
			thread_pool.start();
        }

		public void join () {
			thread_pool.join_all();
		}

        public void feed (VectorModel model) {
            foreach (Face face in model.faces) {
                try {
					thread_pool.feed(face);
                } catch (ThreadError e) {
                    // FIXME do something useful
                    stdout.printf("Some thread error happenend while running the vector stage.\n");
                }
            }
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
}