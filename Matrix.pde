class Matrix {
  final int n, p;            //n : # lines | p : # columns
  double [][] values;      //values stored in the matrix

  Matrix(int _n, int _p) {
    n=_n; p=_p;
    Init();
  }

  //f Made to create fast square matrixes
  Matrix(int _n) {
    n=_n; p=_n;
    Init();
  }
  
  //f
  void Delete() {
    values = null;
  }
  
  //f
  void Init() {
    values = new double[n][p];
  }

  //f Print the matrix in the console
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
  
  //f Debug the shape of this matrix
  void DebugShape() {
    cl.pln(this.n, this.p);
  }
  
  //f Debug column j of this matrix
  void DebugCol(int j) {
    cl.p("Colonne " + str(j) + " [");
    for (int i = 0; i < this.n; i++) {
      cl.p(this.Get(i, j) + " ");
    }
    cl.p("]");
    cl.pln();
  }
  
  //s Ne retourne pas de log
  String[] SaveToString() {
    return SaveToString(false); 
  }
  
  //f Save this matrix into a string array
  String[] SaveToString(boolean doLog) {
    String[] output = new String[this.n];
    int startTime = millis();
    for (int i = 0; i < this.n; i++) {
      output[i] = "";
      for (int j = 0; j < this.p; j++)
        output[i] += this.Get(i,j) + (j != this.p - 1 ? "," : "");
      if(doLog) cl.pln("\t" + (i + 1) + "/" + this.n + "\t Time remaining " + RemainingTime(startTime, i+1, this.n));
    }
    return output;
  }
  
  //f Load this matrix from a string array
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

  //f Crée une copie de la matrice - utile pour faire les opérations Add en gardant le résultat sur une autre matrice
  Matrix C() {
    Matrix new_mat = new Matrix(n, p);
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        new_mat.Set(i, j, this.Get(i,j));

    return new_mat;
  }

  //f Fill the matrix with some value val
  void Fill(double val) {
    for(int i = 0; i < n; i++)
      for(int j = 0; j < p; j++)
        this.values[i][j] = val;
  }

  //f Copy the value of an array in the matrix
  Matrix FromArray(double[][] val) {
    if (val.length != n || val[0].length != p) { cl.pln(this, "FromArray", "Wrong size array"); Exception e = new Exception(); e.printStackTrace(); return this; }
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        this.values[i][j] = val[i][j];

    return this;
  }

  //f Every value of the matrix random from min to max
  Matrix Random(double min, double max) {
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        this.values[i][j] = min + (max - min)*random(1);
    return this;
  }
  
  //s Retourne une matrice aléatoire à valeurs dans [0;1]
  Matrix Random() {
    return Random(0, 1);
  }

  //f Create identity matrix if the matrix is a square one
  Matrix Identity() {
    if (this.n != this.p) { cl.pln(this, "Identity", "Not square matrix"); Exception e = new Exception(); e.printStackTrace(); return this; }
    for (int i = 0; i < this.n; i++)
      for (int j = 0; j < this.n; j++)
        this.Set(i, j, i == j ? 1 : 0);

    return this;
  }

  //f Change the i, j value to value val
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

  //f Get value of i, j
  double Get(int i, int j) {
    if (i < 0 || i >= n || j < 0 || j >= p) { cl.pln(this, i, j, "Get", "Wrong indices"); Exception e = new Exception(); e.printStackTrace(); return 0; }
    return this.values[i][j];
  }
  
  //f Check if this matrix contain _val_
  boolean Contains(double val) {
    for (int i = 0; i < this.n; i++)
      for (int j = 0; j < this.p; j++)
        if (val == this.Get(i,j)) return true;
    return false;
  }
  
  //f Check if this matrix contain a _NaN_
  boolean HasNAN() {
    for (int i = 0; i < this.n; i++)
      for (int j = 0; j < this.p; j++)
        if (this.Get(i,j) != this.Get(i,j)) return true;
    return false;
  }

  //f Map funciton func (using (x) -> notation) to this
  Matrix Map(FunctionMap func) {
    for (int i = 0; i < this.n; i++)
      for (int j = 0; j < this.p; j++)
        this.Set(i,j,func.calc(this.Get(i, j)));
    return this;
  }

  //f Create a new matrix, equal to the transposed matrix of this
  Matrix T() {
    double [][] n_matcoeff = new double[p][n];
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        n_matcoeff[j][i] = this.Get(i, j);

    return new Matrix(this.p,this.n).FromArray(n_matcoeff);
  }
  
  //s broadcast to false et scal = 1
  Matrix Add(Matrix m) {
    return this.Add(m, 1, false);
  }
  
  //s broadcast to false
  Matrix Add(Matrix m, double scal) {
    return this.Add(m, scal, false);
  }

  //f Add some matrix m to this ; does this + scal * m
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

  //f Scale matrix by some factor
  Matrix Scale(double scal) {
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        this.Set(i, j, scal * this.Get(i, j));

    return this;
  }

  //f Dilat j-th column by -scal-
  Matrix Dilat(int j, double scal) {
    if (j < 0 || j >= this.p) { cl.pln(this, j, "Dilat", "Wrong Column Index"); Exception e = new Exception(); e.printStackTrace(); return this; }

    for(int i = 0; i < this.n; i++)
      this.Set(i,j, this.Get(i,j) * scal);

    return this;
  }

  //f Comut col j1 and j2
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
  
  //s Ne prend que la colonne j
  Matrix GetCol(int j) {
    return GetCol(new int[]{j});
  }

  //s Range is inclusive
  Matrix GetCol(int a, int b) {
    if (a > b) { cl.pln(this, a, b, this.p, "GetCol", "Indices are in wrong order"); Exception e = new Exception(); e.printStackTrace(); return this; }
    int[] range = new int[b-a+1];
    for(int i = a; i < b+1; i++) range[i-a] = i;
    return GetCol(range);
  }
  
  //s Pas de limite de colonnes
  Matrix GetCol(int[] jList) {
    return GetCol(jList, 0, jList.length);
  }
  
  //s startCol = 0
  Matrix GetCol(int[] jList, int numCol) {
    return GetCol(jList, 0, numCol);
  }

  //f Create a new matrix with the column with indices in jList, restreint entre _startCol_ et _endCol_
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
  
  //f Set _j-th_ column from a double array
  Matrix ColumnFromArray(int j, double[] col) {
    if (j < 0 || j >= this.p) { cl.pln(this, j, "ColumnFromArray", "Wrong Column Index"); Exception e = new Exception(); e.printStackTrace(); return this; }
    if (col.length != this.n) { cl.pln(this, col.length, "ColumnFromArray", "Wrong Sized Column"); Exception e = new Exception(); e.printStackTrace(); return this; }

    for(int i = 0; i < this.n; i++) this.Set(i, j, col[i]);

    return this;
  }
  
  //f Create an array from a _j-th_ column
  double[] ColToArray(int j) {
    double[] col = new double[this.n];
    if (j < 0 || j >= this.p) { cl.pln(this, j, "ColToArray", "Wrong Column Index"); Exception e = new Exception(); e.printStackTrace(); return col; }
    for (int i = 0; i < this.n ;i++) {
      col[i] = this.Get(i,j);
    }
    return col;
  }

  //f Sum coeff from j-th column
  double SumCol(int j) {
    if (j < 0 || j >= this.p) { cl.pln(this, j, "SumCol", "Wrong Column Index"); Exception e = new Exception(); e.printStackTrace(); return 0; }

    double sum = 0;
    for(int i = 0; i < this.n; i++)
      sum += this.Get(i,j);

    return sum;
  }

  //f Compute the column matrix of the average of each row from this
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

  //f Create a new matrix, which is this * m
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

  //f Hadamard Product : Multiply the coefficient of this matrix by the ones of another one
  Matrix HProduct(Matrix m) {
    if(p != m.p || n != m.n) { cl.pln(this, m, "HPrduct", "Wrong sized matrixes"); Exception e = new Exception(); e.printStackTrace(); return this; }

    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        this.Set(i,j,this.Get(i,j) * m.Get(i,j));

    return this;
  }

  //f Sum of each column is scaled to be 1
  Matrix NormColumn() {
    double s = 0;
    for(int j = 0; j < this.p; j++) {
      s = SumCol(j);
      if(s != 0) this.Dilat(j, 1/s);
    }

    return this;
  }

  //f Return the associated matrix from minor i, j
  Matrix MinMatrix(int i, int j) {
    if (i < 0 || i >= this.n || j < 0 || j >= this.p) { cl.pln(this, i, j, "MinMatrices", "Wrong indices"); Exception e = new Exception(); e.printStackTrace(); return this; }
    if (this.n == 0 || this.p == 0) { cl.pln(this, "MinMatrices", "Matrix is too small"); Exception e = new Exception(); e.printStackTrace(); return this; }

    Matrix min = new Matrix(this.n - 1, this.p - 1);
    for (int e = 0; e < this.n - 1; e++)
      for (int f = 0; f < this.p - 1; f++)
        min.Set(e, f, this.Get(e >= i ? e+1 : e, f >= j ? f+1 : f));

    return min;
  }

  //f Return matrix determinant
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

  //f Return the comatrix
  Matrix Comatrix() {
    if (this.n != this.p) { cl.pln(this, "Comatrix", "Not square matrix"); Exception e = new Exception(); e.printStackTrace(); return new Matrix(this.n, this.p); }
    Matrix comat = new Matrix(this.n);

    for (int i = 0; i < this.n; i++)
      for (int j = 0; j < this.n; j++)
        comat.Set(i,j, pow(-1, i+j) * this.MinMatrix(i,j).Det());

    return comat;
  }

  //f Return the inversed matrix
  Matrix Inversed() {
    if (this.n != this.p) { cl.pln(this, "Inversed", "Not square matrix"); Exception e = new Exception(); e.printStackTrace(); return new Matrix(this.n, this.p); }
    return this.Comatrix().T().Scale(1/this.Det());
  }

}

@FunctionalInterface
interface FunctionMap {
  double calc(double x);
}
