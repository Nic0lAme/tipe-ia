class Matrix {
  final int n, p;            //n : # lines | p : # columns
  double [][] values;      //values stored in the matrix
  
  Matrix(int _n, int _p) {
    n=_n; p=_p;
    Init();
  }
  
  Matrix(int _n) { // Made to create fast square matrixes
    n=_n; p=_n;
    Init();
  }
  
  void Init() {
    values = new double[n][p];
  }
  
  void Debug() {                  // Print the matrix in the console
    for(int i = 0; i < n; i++) {
      for(int j = 0; j < p; j++) {
        print(this.Get(i, j), " "); 
      }
      println();
    }
  }
  
  Matrix C() {                    // Crée une copie de la matrice - utile pour faire les opérations Add, Mult, T en gardant le résultat sur une autre matrice
    Matrix new_mat = new Matrix(n, p);
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        new_mat.Set(i, j, this.Get(i,j));
        
    return new_mat;
  }
  
  void Fill(double val) {          // Fill the matrix with some value
    for(int i = 0; i < n; i++)
      for(int j = 0; j < p; j++)
        this.values[i][j] = val; 
  } 
  
  Matrix FromArray(double[][] val) {      // Copy the value of an array in the matrix
    if (val.length != n || val[0].length != p) { println(this, "FromArray", "Wrong size array"); return this; }
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        this.values[i][j] = val[i][j];
        
    return this;
  }
  
  Matrix Random(double min, double max) {
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        this.values[i][j] = min + (max - min)*random(1);
    return this;
  }
  
  Matrix Random() {
    return Random(0, 1);
  }
  
  Matrix Identity() {                  // Create identity matrix if the matrix is a square one
    if (this.n != this.p) { println(this, "Identity", "Not square matrix"); return this; }
    for (int i = 0; i < this.n; i++)
      for (int j = 0; j < this.n; j++)
        this.Set(i, j, i == j ? 1 : 0);
        
    return this;
  }
  
  void Set(int i, int j, double val) {  // Change the i, j value to value val
    if (i < 0 || i >= n || j < 0 || j >= p) { println(this, i, j, val, "Set", "Wrong indices"); return; }
    this.values[i][j] = val;
  }
  
  double Get(int i, int j) {            // Get value of i, j
    if (i < 0 || i >= n || j < 0 || j >= p) { println(this, i, j, "Get", "Wrong indices"); return 0; }
    return this.values[i][j];
  }
  
  Matrix Map(FunctionMap func) {
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        this.values[i][j] = func.calc(this.values[i][j]);
    return this;
  }
  
  Matrix T() {                          // Transform this to its transposed
    double [][] n_mat = new double[p][n];
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        n_mat[j][i] = this.Get(i, j);
        
    int temp = n;
    n = p;
    p = temp;
    this.values = new double[n][p];
    this.FromArray(n_mat);
    return this;
  }
  
  Matrix Add(Matrix m) {                  // Add some matrix m to this
    if (n != m.n || p != m.p) { println(this, m, "Add", "Wrong sized matrixes"); return this; }
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        this.Set(i, j, this.Get(i, j) + m.Get(i,j));
        
    return this;
  }
  
  Matrix Scale(double scal) {              // Scale matrix by some factor
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        this.Set(i, j, scal * this.Get(i, j));
        
    return this;
  }
  
  Matrix Mult(Matrix m) {                   // Create a new matrix, which is this * m
    if (p != m.n) { println(this, m, "Mult", "Wrong sized matrixes"); return this; }
    
    Matrix new_mat = new Matrix(n, m.p);
    double s = 0;
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < m.p; j++) {
        s = 0;
        for (int k = 0; k < p; k++)
          s += this.Get(i, k) * m.Get(k, j);

        new_mat.Set(i, j, s);
      }
    }
    return new_mat;
  }
  
  Matrix MinMatrix(int i, int j) {          // Return the associated matrix from minor i, j
    if (i < 0 || i >= this.n || j < 0 || j >= this.p) { println(this, i, j, "MinMatrices", "Wrong indices"); return this; }
    if (this.n == 0 || this.p == 0) { println(this, "MinMatrices", "Matrix is too small"); return this; }
    
    Matrix min = new Matrix(this.n - 1, this.p - 1);
    for (int e = 0; e < this.n - 1; e++)
      for (int f = 0; f < this.p - 1; f++)
        min.Set(e, f, this.Get(e >= i ? e+1 : e, f >= j ? f+1 : f));
    
    return min;
  }
  
  double Det() {          // Return matrix determinant
    if (this.n != this.p) { println(this, "Det", "Not square matrix"); return 0; }
    if (this.n == 1) {
      return this.Get(0,0);
    }
    
    double det = 0;
    for (int k = 0; k < this.n; k++)
      det += pow(-1, k) * this.Get(k, 0) * this.MinMatrix(k, 0).Det();
    
    return det;
  }
  
  Matrix Comatrix() {      // Return the comatrix
    if (this.n != this.p) { println(this, "Comatrix", "Not square matrix"); return new Matrix(this.n, this.p); }
    Matrix comat = new Matrix(this.n);
    
    for (int i = 0; i < this.n; i++)
      for (int j = 0; j < this.n; j++)
        comat.Set(i,j, pow(-1, i+j) * this.MinMatrix(i,j).Det());
    
    return comat;
  }
  
  Matrix Inversed() {      // Return the inversed matrix
    if (this.n != this.p) { println(this, "Inversed", "Not square matrix"); return new Matrix(this.n, this.p); }
    return this.Comatrix().T().Scale(1/this.Det());
  }
    
}

@FunctionalInterface
interface FunctionMap {
  double calc(double x);
}
