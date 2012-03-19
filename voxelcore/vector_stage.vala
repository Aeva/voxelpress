using Gee;
using libvoxelpress.plugins;
using libvoxelpress.vectors;


namespace voxelcore {
	public class VectorStage: GLib.Object {
		public PluginRepository<VectorPlugin> repository {get; private set;}
		public ArrayList<VectorPlugin> pipeline {get; private set;}
		private ThreadPool<Face?> thread_pool;
		
		public VectorStage (string search_path) {
			repository = new PluginRepository<VectorPlugin> (search_path + "/vector");
			pipeline = new ArrayList<VectorPlugin>();
			try {
				thread_pool = new ThreadPool<work_reciept?>((Func<work_reciept?>)this.worker, 4, false);
			} catch (ThreadError e) {
				stdout.printf("Failed to create thread pool.\n");
			}

			// FIXME: Sort plugins by priority, and ignore explicit plugins when appropriate.
			// FIXME: Add "fragmentation" stuff to the end of each pipeline.
			foreach (var plugin in repository.plugins) {
				pipeline.add(plugin.create_new());
			}
		}

		private struct work_reciept {
			public ArrayList<VectorPlugin> pipeline;
			public Face? face;
		}

		private void worker (work_reciept? work) {
			if (work !=null && work.face != null && work.pipeline != null) {
				stdout.printf("crashes here\n");
				foreach (VectorPlugin stage in work.pipeline) {
					try {
						stage.transform(work.face);
					} catch (VectorModelError e) {
						// FIXME do something useful here
					}
				}
			}
		}

		public void feed (VectorModel model) {
			foreach (Face face in model.faces) {
				var stub = work_reciept {
					this.pipeline,
					face
				};
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