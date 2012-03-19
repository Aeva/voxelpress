using Gee;
using libvoxelpress.plugins;
using libvoxelpress.vectors;


namespace voxelcore {
	public class VectorStage: GLib.Object {
		public PluginRepository<VectorPlugin> repository {get; private set;}
		public ArrayList<VectorPlugin> pipeline {get; private set;}
		private ThreadPool<Face> thread_pool;
		
		public VectorStage (string search_path) {
			repository = new PluginRepository<VectorPlugin> (search_path + "/vector");
			pipeline = new ArrayList<VectorPlugin>();
			thread_pool = new ThreadPool<Face>((Func<Face>)this.worker, 4, false);

			// FIXME: Sort plugins by priority, and ignore explicit plugins when appropriate.
			// FIXME: Add "fragmentation" stuff to the end of each pipeline.
			foreach (var plugin in repository.plugins) {
				pipeline.add(plugin.create_new());
			}
		}

		private void* worker (Face face) {
			foreach (VectorPlugin stage in pipeline) {
				try {
					stage.transform(face);
				} catch (Error e) {
					// FIXME handle discard events
				}
			}
		}

		public void feed (VectorModel model) {
			try {

				foreach (Face face in model.faces) {
				}
			} catch (Error e) {
				// FIXME be more specific...
				stdout.print("Error occured in vector stage.\n");
			}
		}
	}
}