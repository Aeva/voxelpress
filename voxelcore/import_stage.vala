using Gee;
using libvoxelpress.plugins;
using libvoxelpress.vectors;


namespace voxelcore {
	public class ImportStage: GLib.Object {
		public PluginRepository<ImportPlugin> repository {get; private set;}
		public AsyncQueue<Face?> faces { get; set; }
		public signal void done();

		public ImportStage (string search_path) {
			faces = new AsyncQueue<Face?>();
			VectorModel.faces = faces;
			repository = new PluginRepository<ImportPlugin> (search_path + "/import");
		}

		public void feed (string path) {
			// FIXME intelligently guess the correct loader, instead of doing this:
			VectorModel? model = null;
			foreach (var plugin in repository.plugins) {
				model = plugin.create_new();
				try {
					model.load(path);
				} catch (Error e) {
					continue;
				}
				break;
			}
			done();
		}
	}
}