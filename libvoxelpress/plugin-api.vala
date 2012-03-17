using libvoxelpress.vectors;


namespace libvoxelpress.plugins {
	public enum PluginKind {
		IMPORT,
		VECTOR,
		VOXEL,
		EXPORT
	}
	

	public struct PluginMetaData {
		public string name;
		public int priority;
		public PluginKind plugin_kind;
		public Type object_type;
	}
	
		
	public interface BasicPlugin : GLib.Object {
	}


	public interface ImportPlugin : BasicPlugin, VectorModel {
		public abstract void load(string path) throws IOError, VectorModelError;
	}
}