using libvoxelpress.vectors;

namespace libvoxelpress.debug {
    public void print_vector (Vector vector) {
        double a = vector.vector[0];
        double b = vector.vector[1];
        double c = vector.vector[2];
        stdout.printf(@" ( $a, $b, $c )");
    }

    public void print_face (Face face) {
        stdout.printf("Vertices:");
        for (int i=0; i<3; i+=1) {
            print_vector(face.vertices[i]);
        }
        stdout.printf("\n");
        stdout.printf("normals:");
        for (int i=0; i<3; i+=1) {
            print_vector(face.normals[i]);
        }
        stdout.printf("\n");
    }

    public void print_face_count (VectorModel model) {
        var face_count = model.faces.size; 
        stdout.printf(@"The model contains $face_count faces!!!!\n");
    }
}