using Gee

namespace libvcm.voxel_model {

	public class VoxelModel: VoxelModelKind {
		public int layer_dpi { get; private set; }
		public int layer_height { get; private set; }
		public int build_width { get; private set; }
		public int build_length { get; private set; }
		public int build_height { get; private set; }

		public int block_count { get; private set; }
		public int block_size { get; private set; }
		public HashMap<int, RasterLayerKind> slices { get; private set; }

		public VoxelModel (int layer_dpi, int layer_height,
						   int build_width, int build_length, 
						   int build_height) {
			this.layer_dpi = layer_dpi;
			this.layer_height = layer_height;
			this.build_width = build_width;
			this.build_length = build_length;
			this.build_height = build_height;

			var tmp = float(layer_height);
			if (layer_width > layer_height) {
				tmp = float(layer_width);
			}
			tmp *= layer_dpi;
			this.block_size = 64; // a block is 64x64
			this.block_count = Math.ceil(tmp/this.block_size);

			this.slices = new HashMap<int, RasterLayerKind>();
		}

		public void set(int x, int y, int z, VoxelKind voxel) {
			if (!slices.has_key(z)) {
				slices[z] = new RasterLayer(block_size, block_count);
			}
			slices[z][x, y] = voxel;
		}

		public Voxelkind? get(int x, int y, int z) {
			if (slices.has_key(z)) {
				return slices[z][x,y];
			}
			else {
				return null;
			}
		}		
	}


}