using Gee;
using libvoxelpress.vectors;
using libvoxelpress.plugins;


public class DerpAdjustment : GLib.Object, VectorPlugin {
	public void transform (Face face) throws VectorModelError {
		stdout.printf("Derp :)\n");
	}
}


public VectorMetaData register_plugin (Module module) {
	var info = new VectorMetaData();
	info.object_type = typeof (DerpAdjustment);
	info.name = "Derp Adjustment";
	info.priority = 100; // Higher number = lower priority.  Defaults to 90.
	info.explicit = true; // Only active with proper command line switch.  Defaults to false.
	return info;
}