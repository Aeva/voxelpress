using Gee;
using libvoxelpress.plugins;
using libvoxelpress.vectors;


namespace voxelcore {
	public class VectorStage: GLib.Object {
		public PluginRepository<VectorPlugin> repository {get; private set;}
		public ArrayList<VectorPlugin> pipeline {get; private set;}
		
		public VectorStage (string search_path) {
			repository = new PluginRepository<VectorPlugin> (search_path + "/vector");
			pipeline = new ArrayList<VectorPlugin>();

			// FIXME: Sort plugins by priority, and ignore explicit plugins when appropriate.
			// FIXME: Add "fragmentation" stuff to the end of each pipeline.
			foreach (var plugin in repository.plugins) {
				pipeline.add(plugin.create_new());
			}
		}

		public void feed (VectorModel model) {
			// FIXME: Thread this, and stuff.
			foreach (Face face in model.faces) {
				foreach (VectorPlugin stage in pipeline) {
					try {
						stage.transform(face);
					} catch (Error e) {
						// FIXME handle discard events
					}
				}
			}
		}
	}
}