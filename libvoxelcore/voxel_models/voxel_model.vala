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


using Gee;


namespace libvcm.voxel_model {
	public class VoxelModel: Object, VoxelModelKind {
		public double page_width { get; private set; }  // x, in mm
		public double page_length { get; private set; } // y, in mm
		public double page_height { get; private set; } // z, in mm

		// xy_res is dots per mm.
		// For repraps, this would be 1/nozzel_radius.  The radius is
		// used instead of the diameter so as to make insetting simple.
		public double xy_res { get; private set; }

		// z_res is layers per mm.
		// For repraps, this would be 1/layer_thickness.
		public double z_res { get; private set; }

		// The following are in units of voxels.
		public int model_width { get; private set; }
		public int model_length { get; private set; }
		public int model_height { get; private set; }
		public int min_x { get; private set; }
		public int max_x { get; private set; }
		public int min_y { get; private set; }
		public int max_y { get; private set; }
		public int min_z { get; private set; }
		public int max_z { get; private set; }
		public int block_size { get; private set; }
		public bool empty { get; private set; }

		// Model data
		public HashMap<int, RasterLayerKind> layers { get; set; }


		public VoxelModel (double p_width, double p_length, double p_height,
						   double xy_res, double z_res) {

			layers = new HashMap<int, RasterLayerKind>();
			this.xy_res = xy_res;
			this.z_res = z_res;
			page_width = p_width;
			page_length = p_length;
			page_height = p_height;

			model_width = (int) (page_width * xy_res);
			model_length = (int) (page_length * xy_res);
			model_height = (int) (page_height * z_res);

			block_size = 16;
			empty = true;
		}


		public new VoxelKind? get(int x, int y, int z) {
			lock (layers) {
				if (layers[z] == null) {
					return null;
				}
			}
			// This bit is intentionally outside of the lock, since the
			// layers themselves are thread safe
			return layers[z][x,y];
		}


		public new void set(int x, int y, int z, VoxelKind voxel) {
			lock (layers) {
				if (empty) {
					empty = false;
					min_x = x;
					max_x = x;
					min_y = y;
					max_y = y;
					min_z = z;
					max_z = z;
				}
				else {
					min_x = x < min_x ? x : min_x;
					max_x = x > max_x ? x : max_x;
					min_y = y < min_y ? y : min_y;
					max_y = y > max_y ? y : max_y;
					min_z = z < min_z ? z : min_z;
					max_z = z > max_z ? z : max_z;
				}
				if (layers[z] == null) {
				layers[z] = new RasterLayer(
					block_size, model_width, model_height);
				}
			}
			// This bit is intentionally outside of the lock, since the
			// layers themselves are thread safe
			layers[z][x,y] = voxel;
		}
    }
}