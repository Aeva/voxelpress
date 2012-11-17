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


using libvoxelcore.materials;


namespace libvoxelcore.vector_model {


	public interface VertexKind: Object {
		public abstract double x { get; set; }
		public abstract double y { get; set; }
		public abstract double z { get; set; }
		public abstract MaterialKind? material { get; set; }
	}


	public interface FaceKind: Object {
		public abstract VertexKind[] vertices { get; set; }
	}


}