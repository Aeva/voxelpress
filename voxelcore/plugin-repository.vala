using Gee;
using libvoxelpress.plugins;


namespace voxelcore {
	public class PluginModule : Object {
		public PluginMetaData meta_data;
		private Module module;
		private delegate PluginMetaData RegisterPluginFunc (Module module);
		
		public PluginModule (string path) {
			module = Module.open (path, ModuleFlags.BIND_LAZY);
			assert(module != null);
			void* function;
			module.symbol("register_plugin", out function);
			RegisterPluginFunc register_plugin = (RegisterPluginFunc) function;
			meta_data = register_plugin(module);		
			stdout.printf(" - loaded \"%s\"\n", meta_data.name);
		}
		
		public BasicPlugin create_new () {
			return (BasicPlugin) Object.new(meta_data.object_type);
		}
	}
	
	
	public class PluginRepository : Object {
		public ArrayList<PluginModule> import_plugins {get; set; default = new ArrayList<PluginModule>();}
		public ArrayList<PluginModule> vector_plugins {get; set; default = new ArrayList<PluginModule>();}
		public ArrayList<PluginModule> voxel_plugins {get; set; default = new ArrayList<PluginModule>();}
		public ArrayList<PluginModule> export_plugins {get; set; default = new ArrayList<PluginModule>();}
		
		public PluginRepository (string search_path) {
			try {
				var dir = File.new_for_path(search_path);
				var enumerator = dir.enumerate_children(FILE_ATTRIBUTE_STANDARD_NAME, 0);
				FileInfo info;
				while ((info = enumerator.next_file()) != null) {
					var plugin = new PluginModule(search_path + "/" + info.get_name());
					
					switch (plugin.meta_data.plugin_kind) {
					case PluginKind.IMPORT:
						import_plugins.add(plugin);
						break;
					case PluginKind.VECTOR:
						vector_plugins.add(plugin);
						break;
					case PluginKind.VOXEL:
						voxel_plugins.add(plugin);
						break;
					case PluginKind.EXPORT:
						export_plugins.add(plugin);
						break;
					}
				}
			}
			catch (Error e) {
				stderr.printf ("Error: %s\n", e.message);
			}
		}
	}
}
