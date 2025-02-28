class Matrix {
  final int n, p;            //n : # lines | p : # columns
  double [][] values;      //values stored in the matrix

  Matrix(int _n, int _p) {
    n=_n; p=_p;
    Init();
  }

  // Made to create fast square matrixes
  Matrix(int _n) {
    n=_n; p=_n;
    Init();
  }

  void Delete() {
    values = null;
  }

  void Init() {
    values = new double[n][p];
  }

  // Print the matrix in the console
  void Debug() {
    //if(true) return; //if you want to disable all debug
    for(int i = 0; i < n; i++) {
      for(int j = 0; j < p; j++) {
        cl.p(this.Get(i, j), "\t");
      }
      cl.pln();
    }
    cl.pln();
  }

  void DebugShape() {
    cl.pln(this.n, this.p);
  }

  void DebugCol(int j) {
    cl.p("Colonne " + str(j) + " [");
    for (int i = 0; i < this.n; i++) {
      cl.p(this.Get(i, j) + " ");
    }
    cl.p("]");
    cl.pln();
  }
  
  String[] SaveToString() {
    return SaveToString(false); 
  }
  
  String[] SaveToString(boolean doLog) {
    String[] output = new String[this.n];
    int startTime = millis();
    for (int i = 0; i < this.n; i++) {
      output[i] = "";
      for (int j = 0; j < this.p; j++)
        output[i] += this.Get(i,j) + (j != this.p - 1 ? "," : "");
      if(doLog) cl.pln("\t" + (i + 1) + "/" + this.n + "\t Time remaining " + String.format("%.3f", (float)(millis() - startTime) / 1000 * (this.n - i - 1) / (i+1)));
    }
    return output;
  }

  void LoadString(String[] lignes) {
    if (lignes.length != n || split(lignes[0], ',').length != p) {
      cl.pln(this, "LoadString", "Wrong size string load");
      return;
    }

    for (int i = 0; i < n; i++) {
      String[] ligne = split(lignes[i], ',');
      for (int j = 0; j < p; j++) {
        this.Set(i, j, Double.valueOf(ligne[j]));
      }
    }
  }

  // Crée une copie de la matrice - utile pour faire les opérations Add en gardant le résultat sur une autre matrice
  Matrix C() {
    Matrix new_mat = new Matrix(n, p);
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        new_mat.Set(i, j, this.Get(i,j));

    return new_mat;
  }

  // Fill the matrix with some value val
  void Fill(double val) {
    for(int i = 0; i < n; i++)
      for(int j = 0; j < p; j++)
        this.values[i][j] = val;
  }

  // Copy the value of an array in the matrix
  Matrix FromArray(double[][] val) {
    if (val.length != n || val[0].length != p) { cl.pln(this, "FromArray", "Wrong size array"); Exception e = new Exception(); e.printStackTrace(); return this; }
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        this.values[i][j] = val[i][j];

    return this;
  }

  // Every value of the matrix random from min to max
  Matrix Random(double min, double max) {
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        this.values[i][j] = min + (max - min)*random(1);
    return this;
  }

  Matrix Random() {
    return Random(0, 1);
  }

  // Create identity matrix if the matrix is a square one
  Matrix Identity() {
    if (this.n != this.p) { cl.pln(this, "Identity", "Not square matrix"); Exception e = new Exception(); e.printStackTrace(); return this; }
    for (int i = 0; i < this.n; i++)
      for (int j = 0; j < this.n; j++)
        this.Set(i, j, i == j ? 1 : 0);

    return this;
  }

  // Change the i, j value to value val
  void Set(int i, int j, double val) {
    if (i < 0 || i >= n || j < 0 || j >= p) { cl.pln(this, i, j, val, "Set", "Wrong indices"); Exception e = new Exception(); e.printStackTrace(); return; }
    if(val != val) { // Val is a NaN
      Exception e = new Exception();
      e.printStackTrace();

      cl.pln("Want to SET a NaN");
      return;
    }
    this.values[i][j] = val;
  }

  // Get value of i, j
  double Get(int i, int j) {
    if (i < 0 || i >= n || j < 0 || j >= p) { cl.pln(this, i, j, "Get", "Wrong indices"); Exception e = new Exception(); e.printStackTrace(); return 0; }
    return this.values[i][j];
  }

  boolean Contains(double val) {
    for (int i = 0; i < this.n; i++)
      for (int j = 0; j < this.p; j++)
        if (val == this.Get(i,j)) return true;
    return false;
  }

  // Map funciton func (using (x) -> notation) to this
  Matrix Map(FunctionMap func) {
    for (int i = 0; i < this.n; i++)
      for (int j = 0; j < this.p; j++)
        this.Set(i,j,func.calc(this.Get(i, j)));
    return this;
  }

  // Create a new matrix, equal to the transposed matrix of this
  Matrix T() {
    double [][] n_matcoeff = new double[p][n];
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        n_matcoeff[j][i] = this.Get(i, j);

    return new Matrix(this.p,this.n).FromArray(n_matcoeff);
  }

  Matrix Add(Matrix m) {
    return this.Add(m, 1, false);
  }

  Matrix Add(Matrix m, double scal) {
    return this.Add(m, scal, false);
  }

  // Add some matrix m to this ; does this + scal * m
  Matrix Add(Matrix m, double scal, boolean broadcast) {
    if ((this.n != m.n) || (!broadcast && p != m.p) || (broadcast && m.p != 1 && this.p != m.p) ) {
      cl.pln(this, m, "Add", "Wrong sized matrixes");
      Exception e = new Exception(); e.printStackTrace();
      return this;
    }
    if (this.p == m.p) broadcast = false;
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        // Le broadcasting permet d'additionner à une matrice un vecteur, qui s'étend sur toutes les colonnes (oui j'ai expliqué en fr celui-là)
        this.Set(i, j, this.Get(i, j) + scal * m.Get(i, broadcast ? 0 : j));

    return this;
  }

  // Scale matrix by some factor
  Matrix Scale(double scal) {
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        this.Set(i, j, scal * this.Get(i, j));

    return this;
  }

  // Dilat j-th column by -scal-
  Matrix Dilat(int j, double scal) {
    if (j < 0 || j >= this.p) { cl.pln(this, j, "Dilat", "Wrong Column Index"); Exception e = new Exception(); e.printStackTrace(); return this; }

    for(int i = 0; i < this.n; i++)
      this.Set(i,j, this.Get(i,j) * scal);

    return this;
  }

  // Comut col j1 and j2
  Matrix ComutCol(int j1, int j2) {
    if (j1 < 0 || j1 >= this.p || j2 < 0 || j2 >= this.p) { cl.pln(this, j1, j2, this.p, "ComutCol", "Wrong Column Index"); Exception e = new Exception(); e.printStackTrace(); return this; }

    double temp;
    for(int i = 0; i < this.n; i++) {
      temp = this.Get(i, j1);
      this.Set(i, j1, this.Get(i, j2));
      this.Set(i, j2, temp);
    }

    return this;
  }

  Matrix GetCol(int j) { return GetCol(new int[]{j}); } // Could be optimised but it is okay I guess

  // Range is inclusive
  Matrix GetCol(int a, int b) {
    if (a > b) { cl.pln(this, a, b, this.p, "GetCol", "Indices are in wrong order"); Exception e = new Exception(); e.printStackTrace(); return this; }
    int[] range = new int[b-a+1];
    for(int i = a; i < b+1; i++) range[i-a] = i;
    return GetCol(range);
  }

  Matrix GetCol(int[] jList) {
    return GetCol(jList, 0, jList.length);
  }

  Matrix GetCol(int[] jList, int numCol) {
    return GetCol(jList, 0, numCol);
  }

  // Create a new matrix with the column with indices in jList
  Matrix GetCol(int[] jList, int startCol, int endCol) {
    if (jList.length < 1) { cl.pln(this, jList, this.p, "GetCol", "List must be of length >= 1"); Exception e = new Exception(); e.printStackTrace(); return this; }
    if (jList.length < endCol || startCol > endCol) { cl.pln(this, jList, this.p, startCol, endCol, "GetCol", "Conflict with startCol & endCol"); Exception e = new Exception(); e.printStackTrace(); return this; }
    for(int j : jList)
      if (j < 0 || j >= this.p) { cl.pln(this, j, this.p, "GetCol", "Wrong Column Index"); Exception e = new Exception(); e.printStackTrace(); return this; }

    Matrix new_mat = new Matrix(this.n, endCol - startCol);
    for(int k = 0; k < endCol - startCol; k++) {
      for(int i = 0; i < this.n; i++)
        new_mat.Set(i, k, this.Get(i, jList[k + startCol]));
    }

    return new_mat;
  }

  Matrix ColumnFromArray(int j, double[] col) {
    if (j < 0 || j >= this.p) { cl.pln(this, j, "ColumnFromArray", "Wrong Column Index"); Exception e = new Exception(); e.printStackTrace(); return this; }
    if (col.length != this.n) { cl.pln(this, col.length, "ColumnFromArray", "Wrong Sized Column"); Exception e = new Exception(); e.printStackTrace(); return this; }

    for(int i = 0; i < this.n; i++) this.Set(i, j, col[i]);

    return this;
  }

  // Sum coeff from j-th column
  double SumCol(int j) {
    if (j < 0 || j >= this.p) { cl.pln(this, j, "SumCol", "Wrong Column Index"); Exception e = new Exception(); e.printStackTrace(); return 0; }

    double sum = 0;
    for(int i = 0; i < this.n; i++)
      sum += this.Get(i,j);

    return sum;
  }

  // Compute the column matrix of the average of each row from this
  Matrix AvgLine() {
    Matrix matrixOfAverage = new Matrix(this.n, 1);
    for(int i = 0; i < this.n; i++) {
      double avg = 0;
      for(int j = 0; j < this.p; j++)
        avg += this.Get(i,j) / this.p;

      matrixOfAverage.Set(i, 0, avg);
    }
    return matrixOfAverage;
  }

  // Create a new matrix, which is this * m
  Matrix Mult(Matrix m) {
    if (p != m.n) { cl.pln(this, m, "Mult", "Wrong sized matrixes"); Exception e = new Exception(); e.printStackTrace(); return this; }

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

  // Hadamard Product : Multiply the coefficient of this matrix by the ones of another one
  Matrix HProduct(Matrix m) {
    if(p != m.p || n != m.n) { cl.pln(this, m, "HPrduct", "Wrong sized matrixes"); Exception e = new Exception(); e.printStackTrace(); return this; }

    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        this.Set(i,j,this.Get(i,j) * m.Get(i,j));

    return this;
  }

  // Sum of each column is scaled to be 1
  Matrix NormColumn() {
    double s = 0;
    for(int j = 0; j < this.p; j++) {
      s = SumCol(j);
      if(s != 0) this.Dilat(j, 1/s);
    }

    return this;
  }

  // Return the associated matrix from minor i, j
  Matrix MinMatrix(int i, int j) {
    if (i < 0 || i >= this.n || j < 0 || j >= this.p) { cl.pln(this, i, j, "MinMatrices", "Wrong indices"); Exception e = new Exception(); e.printStackTrace(); return this; }
    if (this.n == 0 || this.p == 0) { cl.pln(this, "MinMatrices", "Matrix is too small"); Exception e = new Exception(); e.printStackTrace(); return this; }

    Matrix min = new Matrix(this.n - 1, this.p - 1);
    for (int e = 0; e < this.n - 1; e++)
      for (int f = 0; f < this.p - 1; f++)
        min.Set(e, f, this.Get(e >= i ? e+1 : e, f >= j ? f+1 : f));

    return min;
  }

  // Return matrix determinant
  double Det() {
    if (this.n != this.p) { cl.pln(this, "Det", "Not square matrix"); Exception e = new Exception(); e.printStackTrace(); return 0; }
    if (this.n == 1) {
      return this.Get(0,0);
    }

    double det = 0;
    for (int k = 0; k < this.n; k++)
      det += pow(-1, k) * this.Get(k, 0) * this.MinMatrix(k, 0).Det();

    return det;
  }

  // Return the comatrix
  Matrix Comatrix() {
    if (this.n != this.p) { cl.pln(this, "Comatrix", "Not square matrix"); Exception e = new Exception(); e.printStackTrace(); return new Matrix(this.n, this.p); }
    Matrix comat = new Matrix(this.n);

    for (int i = 0; i < this.n; i++)
      for (int j = 0; j < this.n; j++)
        comat.Set(i,j, pow(-1, i+j) * this.MinMatrix(i,j).Det());

    return comat;
  }

  // Return the inversed matrix
  Matrix Inversed() {
    if (this.n != this.p) { cl.pln(this, "Inversed", "Not square matrix"); Exception e = new Exception(); e.printStackTrace(); return new Matrix(this.n, this.p); }
    return this.Comatrix().T().Scale(1/this.Det());
  }

}

@FunctionalInterface
interface FunctionMap {
  double calc(double x);
}
