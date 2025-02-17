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
        print(this.Get(i, j), "\t"); 
      }
      println();
    }
    println();
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
        this.Set(i,j,func.calc(this.Get(i, j)));
    return this;
  }
  
  Matrix T() {                          // Create a new matrix, equal to the transposed matrix of this
    double [][] n_matcoeff = new double[p][n];
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        n_matcoeff[j][i] = this.Get(i, j);
        
    return new Matrix(this.p,this.n).FromArray(n_matcoeff);
  }
  
  Matrix Add(Matrix m) {
    return this.Add(m, 1, true);
  }
  
  Matrix Add(Matrix m, double scal, boolean broadcast) {                  // Add some matrix m to this ; does this + scal * m
    if ((n != m.n) || (!broadcast && p != m.p) || (broadcast && m.p != 1 && this.p != m.p) ) { println(this, m, "Add", "Wrong sized matrixes"); return this; }
    if (this.p == m.p) broadcast = false;
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        // Le broadcasting permet d'additionner à une matrice un vecteur, qui s'étend sur toutes les colonnes (oui j'ai expliqué en fr celui-là)
        this.Set(i, j, this.Get(i, j) + scal * m.Get(i, broadcast ? 0 : j));
        
    return this;
  }
  
  Matrix Scale(double scal) {              // Scale matrix by some factor
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        this.Set(i, j, scal * this.Get(i, j));
        
    return this;
  }
  
  Matrix Dilat(int j, double scal) {        // Dilat j-th column by -scal-
    if (j < 0 || j >= this.p) { println(this, j, "Dilat", "Wrong Column Index"); return this; }
    
    for(int i = 0; i < this.n; i++)
      this.Set(i,j, this.Get(i,j) * scal);
    
    return this;
  }
  
  double SumCol(int j) {        // Sum coeff from j-th column
    if (j < 0 || j >= this.p) { println(this, j, "SumCol", "Wrong Column Index"); return 0; }
    
    double sum = 0;
    for(int i = 0; i < this.n; i++)
      sum += this.Get(i,j);
    
    return sum;
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
  
  Matrix HProduct(Matrix m) {      // Hadamard Product : Multiply the coefficient of this matrix by the ones of another one
    if(p != m.p || n != m.n) { println(this, m, "HPrduct", "Wrong sized matrixes"); return this; }
    
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        this.Set(i,j,this.Get(i,j) * m.Get(i,j));
        
    return this;
  }
  
  Matrix NormColumn() {            // Sum of each column is scaled to be 1
    for(int j = 0; j < this.p; j++)
      this.Dilat(j, 1/SumCol(j));
    
    return this;
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
