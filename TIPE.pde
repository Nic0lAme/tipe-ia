class Matrix {
  int n, p;            //n : # lines | p : # columns
  float [][] mat;      //values stored in the matrix
  
  Matrix(int _n, int _p) {
    n=_n; p=_p;
    mat = new float[n][p];
  }
  
  void Fill(float val) {          // Fill the matrix with some value
    for(int i = 0; i < n; i++) {
       for(int j = 0; j < p; j++) {
          mat[i][j] = val; 
       }
    }
  } 
  
  void Set(int i, int j, float val) {  // Change the i, j value to value val
    if (i < 0 || i >=n || j < 0 || j >= p) return;
    mat[i][j] = val;
  }
  
  void Debug() {                  // Print the matrix in the console
     for(int j = 0; j < p; j++) {
        for(int i = 0; i < n; i++) {
          print(mat[i][j], " "); 
        }
        println();
     }
  }
  
  
}

void setup() {
  size(200, 200);
  background(255);
  
  Matrix m = new Matrix(3,3);
  m.Fill(3.5);
  m.Debug();
}
