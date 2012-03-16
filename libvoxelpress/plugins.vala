using libvoxelpress;


namespace libvoxelpress.plugins {
   	public interface IModelImportPlugin : GLib.Object {
		public abstract string[] extensions {get; set;}
		public abstract void load(string uri);
	}

	
	public interface IVectorPlugin : GLib.Object {
		public abstract string name {get; set;}
		public abstract int priority {get; set;}
		public abstract Vector transform(Vector input);
	}


	public interface IVoxelPlugin : GLib.Object {
		public abstract string name {get; set;}
		public abstract int priority {get; set;}
		// ???
	}

	
	public interface IOutputPlugin : GLib.Object {
		public abstract string name {get; set;}
	}
}