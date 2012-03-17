using libvoxelpress;


namespace libvoxelpress.plugins {
   	public interface IModelImportPlugin : GLib.Object {
		public abstract void load(string path);
	}

	
	public interface IVectorPlugin : GLib.Object {
		public abstract Vector transform(Vector input);
	}


	public interface IVoxelPlugin : GLib.Object {
		// ???
	}

	
	public interface IOutputPlugin : GLib.Object {
		// ???
	}
}