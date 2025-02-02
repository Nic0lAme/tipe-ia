class Matrix {
  int n, p;            //n : # lines | p : # columns
  float [][] mat;      //values stored in the matrix
  
  Matrix(int _n, int _p) {
    n=_n; p=_p;
    mat = new float[n][p];
  }
  
  void Debug() {                  // Print the matrix in the console
    for(int j = 0; j < p; j++) {
      for(int i = 0; i < n; i++) {
        print(mat[i][j], " "); 
      }
      println();
    }
  }
  
  Matrix C() {
    Matrix new_mat = new Matrix(n, p);
    new_mat.mat = mat;
    return new_mat;
  }
  
  void Fill(float val) {          // Fill the matrix with some value
    for(int i = 0; i < n; i++) {
      for(int j = 0; j < p; j++) {
        mat[i][j] = val; 
      }
    }
  } 
  
  void Set(int i, int j, float val) {  // Change the i, j value to value val
    if (i < 0 || i >= n || j < 0 || j >= p) return;
    mat[i][j] = val;
  }
  
  float Get(int i, int j) {
    if (i < 0 || i >= n || j < 0 || j >= p) return 0;
    return mat[i][j];
  }
  
  Matrix T() {
    Matrix new_mat = new Matrix(p, n);
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < p; j++) {
        new_mat.Set(j, i, mat[i][j]);
      }
    }
    return new_mat;
  }
  
  Matrix Add(Matrix m) {
    if (n != m.n || p != m.p) {
      println(this, m, "Add", "Wrong sized matrixes");
      return this;
    }
    Matrix new_mat = new Matrix(n, p);
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < p; j++) {
        new_mat.Set(i, j, mat[i][j] + m.Get(i,j));
      }
    }
    return new_mat;
  }
  
  Matrix Mult(Matrix m) {
    if (p != m.n) {
      println(this, m, "Mult", "Wrong sized matrixes");
      return this;
    }
    
    Matrix new_mat = new Matrix(n, m.p);
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < m.p; j++) {
        float s = 0;
        for (int k = 0; k < p; k++) {
          s += mat[i][k] * m.Get(j, j);
        }
        new_mat.Set(i, j, s);
      }
    }
    return new_mat;
  }
  
}

void setup() {
  size(200, 200);
  background(255);
  
  Matrix m = new Matrix(3,3);
  m.Fill(3.5);
  m.Debug();
}
