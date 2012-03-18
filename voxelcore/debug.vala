using libvoxelpress.vectors;

namespace voxelcore.debug {
    private void print_vector (Vector vector) {
        double a = vector.vector[0];
        double b = vector.vector[1];
        double c = vector.vector[2];
        stdout.printf(@" ( $a, $b, $c )");
    }

    private void print_face (Face face) {
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

    private void do_something_neat(VectorModel model) {
        stdout.printf("Opened a model!\n");
        var face_count = model.faces.size; 
        stdout.printf(@"The model contains $face_count faces!!!!\n");
        print_face(model.faces[0]);
    }
}