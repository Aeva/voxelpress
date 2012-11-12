/*

  This file is part of VoxelPress.

  VoxelPress is free software: you can redistribute it and/or modify it
  under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  VoxelPress is distributed in the hope that it will be useful, but
  WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  General Public License for more details.

  You should have received a copy of the GNU General Public License
  along with VoxelPress.  If not, see <http://www.gnu.org/licenses/>.

  Have a nice day!

*/


namespace libvcm.voxel_model {
	public class RasterLayer: Object, RasterLayerKind {
		public DataBlockKind[,] blocks { get; private set; }
		public int center_x { get; private set; }
		public int center_y { get; private set; }
		public int width { get; private set; }
		public int length { get; private set; }
		public int block_size  { get; private set; }
		
		public RasterLayer (int block_size, int layer_width, int layer_length) {
			this.block_size = block_size;
			width = layer_width;
			length = layer_length;
			center_x = width / 2;
			center_y = length / 2;
			var tmp_x = (double) layer_width / (double) block_size;
			var tmp_y = (double) layer_length / (double) block_size;
			int x_ct = (int) Math.ceil(tmp_x);
			int y_ct = (int) Math.ceil(tmp_y);
			blocks = new DataBlockKind[x_ct, y_ct];
		}

		public bool in_boundary(int local_x, int local_y) {

			return (local_x >= 0 && local_y >= 0 &&
					local_x < width && local_y < length);
		}

		public new VoxelKind? get (int x, int y) {
			int local_x = center_x + x;
			int local_y = center_y + y;
			VoxelKind? ret = null;

			if (in_boundary(local_x, local_y)) {
				var block = blocks[local_x/block_size, local_y/block_size];
				if (block != null) {
					ret = block[local_x%block_size, local_y%block_size];
				}
			}
			
			return ret;
		}
		
		public new void set (int x, int y, VoxelKind vox) {
			int local_x = center_x + x;
			int local_y = center_y + y;
			if (in_boundary(local_x, local_y)) {
				int block_x = local_x/block_size;
				int block_y = local_y/block_size;
				
				lock(blocks) {
					var block = blocks[block_x, block_y];
					if (block == null) {
						block = new DataBlock(block_size);
						blocks[block_x, block_y] = block;
					}
					block[local_x%block_size, local_y%block_size] = vox;
				}
			}
		}
	}
}