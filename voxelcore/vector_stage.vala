using Gee;
using libvoxelpress.plugins;
using libvoxelpress.vectors;




namespace voxelcore {
    class VectorThread {
        public static ArrayList<VectorPlugin> pipeline;
        public Face face;
    }


	void worker_func (VectorThread work) {
		if (work.face == null) {
			stdout.printf("thread crapped the bed\n");
			return;
		}
		foreach (VectorPlugin stage in work.pipeline) {
			try {
				stage.transform(work.face);				
			} catch (VectorModelError e) {
				// FIXME do something useful here
			}
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
                thread_pool = new ThreadPool<VectorThread>((Func<VectorThread>)worker_func, 4, true);
            } catch (ThreadError e) {
                stdout.printf("Failed to create thread pool.\n");
            }

            // FIXME: Sort plugins by priority, and ignore explicit plugins when appropriate.
            // FIXME: Add "fragmentation" stuff to the end of each pipeline.
            foreach (var plugin in repository.plugins) {
                pipeline.add(plugin.create_new());
            }
			//while (thread_pool.get_num_threads() > 0) {
			//}
        }

        public void feed (VectorModel model) {
            foreach (Face face in model.faces) {
                try {
					var worker = new VectorThread();
					worker.face = face;
                    thread_pool.push(worker);
                } catch (ThreadError e) {
                    // FIXME do something useful
                    stdout.printf("Some thread error happenend while running the vector stage.\n");
                }
            }
        }
    }
}