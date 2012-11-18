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
using libvoxelcore.materials;


namespace libvoxelcore.vector_model {


	public class VectorModel: Object, VectorModelKind {
		public ArrayList<FaceKind> faces { get; set; }
		public signal void on_face_created(FaceKind face);


		public void add_tri(VertexKind v1, VertexKind v2, VertexKind v3) {
			var face = new Face(v1, v2, v3);
			faces.add(face);
			on_face_created(face);
		}


		public void add_quad(VertexKind v1, VertexKind v2, VertexKind v3, VertexKind v4) {
			// this ... might work?
			add_tri(v1, v2, v3);
			add_tri(v3, v4, v1);
		}

	   
		public VectorModel() {
			faces = new ArrayList<FaceKind>();
		}
	}


}