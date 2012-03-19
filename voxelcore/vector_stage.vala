using Gee;
using libvoxelpress.plugins;
using libvoxelpress.vectors;




namespace voxelcore {
    private class VectorThread {
        public static ArrayList<VectorPlugin> pipeline;
        public Face face;
        public VectorThread(Face face) {
            this.face = face;
        }
    }


    public class VectorStage: GLib.Object {
        private ThreadPool<VectorThread> thread_pool;
        public PluginRepository<VectorPlugin> repository {get; private set;}
        public ArrayList<VectorPlugin> pipeline {
            get { return VectorThread.pipeline; }
            private set { VectorThread.pipeline = value; }
        }
        
        public VectorStage (string search_path) {
            repository = new PluginRepository<VectorPlugin> (search_path + "/vector");
            pipeline = new ArrayList<VectorPlugin>();
            try {
                thread_pool = new ThreadPool<VectorThread>((Func<VectorThread>)this.worker, 4, false);
            } catch (ThreadError e) {
                stdout.printf("Failed to create thread pool.\n");
            }

            // FIXME: Sort plugins by priority, and ignore explicit plugins when appropriate.
            // FIXME: Add "fragmentation" stuff to the end of each pipeline.
            foreach (var plugin in repository.plugins) {
                pipeline.add(plugin.create_new());
            }
        }

        private void worker (VectorThread work) {
			foreach (VectorPlugin stage in work.pipeline) {
				try {
					stage.transform(work.face);
				} catch (VectorModelError e) {
					// FIXME do something useful here
				}
			}
        }

        public void feed (VectorModel model) {
            foreach (Face face in model.faces) {
                var stub = new VectorThread(face);

                try {
                    thread_pool.push(stub);
                } catch (ThreadError e) {
                    // FIXME do something useful
                    stdout.printf("Some thread error happenend while running the vector stage.\n");
                }
            }
        }
    }
}