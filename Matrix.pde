import com.aparapi.Kernel;
import com.aparapi.Range;

class Matrix {
  final int n, p;            //n : # lines | p : # columns
  float[] values;      //values stored in the matrix

  //c Crée une matrice de taille _n_ \* _p_ (# de lignes \* # de colonnes)
  Matrix(int n, int p) {
    this.n=n; this.p=p;
    Init();
  }

  //b Crée des matrices carrées de taille _n_
  Matrix(int n) {
    this.n=n; this.p=n;
    Init();
  }

  //f Supprime la matrice _this_
  void Delete() {
    values = null;
  }

  //f Initialise la matrice (remet ses valeurs à 0)
  void Init() {
    values = new float[n*p];
  }

  //f Afficher la matrice _this_ dans la console
  void Debug() {
    //if(true) return; //if you want to disable all debug
    for(int i = 0; i < n; i++) {
      for(int j = 0; j < p; j++) {
        cl.p(this.values[i * this.p + j], "\t");
      }
      cl.pln();
    }
    cl.pln();
  }

  //f Affiche les dimensions de _this_ matrice dans la console
  void DebugShape() {
    cl.pln(this.n, this.p);
  }

  //f Affiche la colonne _j_ de _this_ matrice dans la console
  void DebugCol(int j) {
    cl.p("Colonne " + str(j) + " [");
    for (int i = 0; i < this.n; i++) {
      cl.p(this.values[i * this.p + j] + " ");
    }
    cl.p("]");
    cl.pln();
  }

  //s Ne retourne pas de log
  String[] SaveToString() {
    return SaveToString(false);
  }

  //f Sauvegarde les valeurs de _this_ matrice dans une _String[]_
  // Si _doLog_, affiche le temps restant dans la console
  // Format : Les deux premiers nombres sont la taille de la matrice
  // Les lignes de la matrice sont séparées par des points-virgules.
  // Il y au max 50 nombres (séparés par une  virgule) par ligne.
  String[] SaveToString(boolean doLog) {
    ArrayList<String> output = new ArrayList<String>();
    int startTime = millis();
    int compteur = 0;

    output.add(str(this.n) + "," + str(this.p));
    String buffer = "";
    for (int i = 0; i < this.n; i++) {
      for (int j = 0; j < this.p; j++) {
        buffer += this.values[i * this.p + j] + (j != this.p - 1 ? "," : "");
        compteur += 1;
        if (compteur >= 5) { compteur = 0; output.add(buffer); buffer = ""; }
      }
      if (i != this.n) buffer += ";";
      if(doLog) cl.pln("\t" + (i + 1) + "/" + this.n + "\t Time remaining " + RemainingTime(startTime, i+1, this.n));
    }
    if (!buffer.equals("")) output.add(buffer);

    output.set(0, output.get(0) + "," + str(output.size()));
    return output.toArray(new String[output.size()]);
  }

  //f Charge dans la matrice _this_ les _lignes_
  void LoadString(String[] lignes) {
    String[] params = split(lignes[0], ",");
    if (Integer.valueOf(params[0]) != n || Integer.valueOf(params[1]) != p) {
      cl.pln(this, "LoadString", "Wrong size string load");
      return;
    }

    int i = 0, j = 0;
    for (int k = 1; k < lignes.length; k++) {
      String[] first = split(lignes[k], ";");
      for (int l = 0; l < first.length; l++) {
        if (l != 0) {
          j = 0;
          i++;
        }
        String[] sec = split(first[l], ",");
        for (int c = 0; c < sec.length; c++) {
          if (sec[c].equals("")) continue;
          this.Set(i, j, Float.valueOf(sec[c]));
          j++;
        }
      }
    }
  }

  //f Crée une copie de la matrice - utile pour faire les opérations Add en gardant le résultat sur une autre matrice
  Matrix C() {
    Matrix new_mat = new Matrix(n, p);
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        new_mat.Set(i, j, this.values[i * this.p + j]);

    return new_mat;
  }

  //f Remplie la matrice _this_ du float _val_
  Matrix Fill(float val) {
    for(int i = 0; i < n; i++)
      for(int j = 0; j < p; j++)
        this.values[i * this.p + j] = val;
    return this;
  }

  //s Copie les valeurs du tableau 1D _val_ dans la matice _this_
  Matrix FromArray(float[] vals) {
    if (this.n*this.p != vals.length) { cl.pln(this, "FromArray", "Wrong size 1D array"); Exception e = new Exception(); e.printStackTrace(); return this; }
    for (int i = 0; i < n*p; i++) values[i] = vals[i];
    return this;
  }

  //f Copie les valeurs du tableau 2D _val_ dans la matice _this_
  Matrix FromArray(float[][] val) {
    if (val.length != n || val[0].length != p) { cl.pln(this, "FromArray", "Wrong size 2D array"); Exception e = new Exception(); e.printStackTrace(); return this; }
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        this.values[i * this.p + j] = val[i][j];

    return this;
  }

  //f Chaque valeur de la matrice est tiré aléatoirement et uniformément entre _min_ et _max_
  Matrix Random(float min, float max) {
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        this.values[i*this.p + j] = min + (max - min)*random(1);
    return this;
  }

  //s Retourne une matrice aléatoire à valeurs dans [0;1]
  Matrix Random() {
    return Random(0, 1);
  }

  //f Chaque valeur de la matrice est tiré aléatoirement et uniformément entre _min_ et _max_
  Matrix RandomGaussian(float mean, float deviation) {
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        this.values[i*this.p + j] = mean + deviation * (float)globalRandom.nextGaussian();
    return this;
  }

  //f Si la matrice _this_ est carré, fait d'elle la matrice identité
  Matrix Identity() {
    if (this.n != this.p) { cl.pln(this, "Identity", "Not square matrix"); Exception e = new Exception(); e.printStackTrace(); return this; }
    for (int i = 0; i < this.n; i++)
      for (int j = 0; j < this.n; j++)
        this.values[i * this.p + j] = (i == j ? 1 : 0);

    return this;
  }

  //f Change la valeur de _this_ à la ligne _i_, la colonne _j_, en lui donnant la valeur _val_
  Matrix Set(int i, int j, float val) {
    if (i < 0 || i >= n || j < 0 || j >= p) { cl.pln(this, i, j, val, "Set", "Wrong indices"); Exception e = new Exception(); e.printStackTrace(); return this; }
    if(val != val) { // Val is a NaN
      Exception e = new Exception();
      e.printStackTrace();

      cl.pln("Want to SET a NaN");

      System.exit(-1);
      return this;
    }
    this.values[i * this.p + j] = val;

    return this;
  }

  //f Réccupère la valeur de _this_ à la ligne _i_ et la colonne _j_
  float Get(int i, int j) {
    if (i < 0 || i >= n || j < 0 || j >= p) { cl.pln(this, i, j, "Get", "Wrong indices"); Exception e = new Exception(); e.printStackTrace(); return 0; }
    return this.values[i * this.p + j];
  }

  //f Vérifie si _val_ est dans la matrice _this_
  boolean Contains(float val) {
    for (int i = 0; i < this.n; i++)
      for (int j = 0; j < this.p; j++)
        if (val == this.values[i * this.p + j]) return true;
    return false;
  }

  //f Vérifie si la matrice _this_ contient _NaN_
  boolean HasNAN() {
    for (int i = 0; i < this.n; i++)
      for (int j = 0; j < this.p; j++)
        if (this.values[i * this.p + j] != this.values[i * this.p + j]) return true;
    return false;
  }

  //f Map la fonction _func_ à la matrice _this_
  // La fonction doit être définie en utilisant la notation lambda : (x) -> notation
  Matrix Map(FunctionMap func) {
    for (int i = 0; i < this.n; i++)
      for (int j = 0; j < this.p; j++)
        this.values[i * this.p + j] = func.calc(this.values[i * this.p + j]);
    return this;
  }

  //f Crée une nouvelle matrice, transposée de _this_
  Matrix T() {
    float [] n_matcoeff = new float[n * p];
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        n_matcoeff[j * this.n + i] = this.values[i * this.p + j];

    Matrix ret = new Matrix(this.p, this.n);
    ret.values = n_matcoeff;
    return ret;
  }

  //s broadcast à false & scal = 1
  Matrix Add(Matrix m) {
    return this.Add(m, 1, false);
  }

  //s broadcast à false
  Matrix Add(Matrix m, float scal) {
    return this.Add(m, scal, false);
  }

  //f Ajoute _m_ à la matrice _this_
  // Modifie la matrice _this_
  // Fait l'opération this + m \* scal
  // Si _broadcast_, la matrice _m_ peut être une matrice colonne, et sera étalé sur l'ensemble de _this_
  Matrix Add(Matrix m, float scal, boolean broadcast) {
    if ((this.n != m.n) || (!broadcast && p != m.p) || (broadcast && m.p != 1 && this.p != m.p) ) {
      cl.pln(this, m, "Add", "Wrong sized matrixes");
      Exception e = new Exception(); e.printStackTrace();
      return this;
    }
    if (this.p == m.p) broadcast = false;
    for (int i = 0; i < n; i++)
      for (int j = 0; j < p; j++)
        // Le broadcasting permet d'additionner à une matrice un vecteur, qui s'étend sur toutes les colonnes (oui j'ai expliqué en fr celui-là)
        this.values[i * this.p + j] = (this.values[i * this.p + j] + scal * m.values[i * m.p + (broadcast ? 0 : j)]);

    return this;
  }

  //f Ajoute un scalaire
  Matrix AddScal(float scal) {
    for(int k = 0; k < this.values.length; k++) this.values[k] += scal;
    return this;
  }

  //f Multiplie l'ensemble de la matrice _this_ par le facteur _scal_
  Matrix Scale(float scal) {
    for(int k = 0; k < this.values.length; k++) this.values[k] *= scal;
    return this;
  }

  //f Multiplie la _j_-ième colonne de _this_ par _scal_
  Matrix Dilat(int j, float scal) {
    if (j < 0 || j >= this.p) { cl.pln(this, j, "Dilat", "Wrong Column Index"); Exception e = new Exception(); e.printStackTrace(); return this; }

    for(int i = 0; i < this.n; i++)
      this.values[i * this.p + j] *= scal;

    return this;
  }

  //f Comuter les colonnes _j1_ et _j2_
  Matrix ComutCol(int j1, int j2) {
    if (j1 < 0 || j1 >= this.p || j2 < 0 || j2 >= this.p) { cl.pln(this, j1, j2, this.p, "ComutCol", "Wrong Column Index"); Exception e = new Exception(); e.printStackTrace(); return this; }

    float temp;
    for(int i = 0; i < this.n; i++) {
      temp = this.values[i * this.p + j1];
      this.values[i * this.p + j1] = this.values[i * this.p + j2];
      this.values[i * this.p + j2] = temp;
    }

    return this;
  }

  //s
  Matrix ShuffleCol(Matrix mat) {
    return ShuffleCol(new Matrix[]{mat})[0];
  }

  //f Mélange de la même manière les matrices _mats_ (Fisher–Yates shuffle)
  Matrix[] ShuffleCol(Matrix[] mats) {
    Matrix[] newMats = new Matrix[mats.length];
    for(int k = 0; k < mats.length; k++) newMats[k] = mats[k].C();

    // Mélange les données (Fisher–Yates shuffle)
    for (int i = 0; i < this.p - 1; i++) {
      int j = floor(random(i, this.p));
      for(int k = 0; k < mats.length; k++) newMats[k].ComutCol(i,j);
    }
    return newMats;
  }

  Matrix[] Split(int numberOfSplit) {
    if (numberOfSplit > this.p) return new Matrix[] {this.C()};
    Matrix[] output = new Matrix[numberOfSplit];
    int size = this.p / numberOfSplit;
    for (int i = 0; i < output.length; i++) {
      output[i] = this.GetCol(i*size, i < output.length - 1 ? constrain(i*size + size-1, 0, this.p-1) : this.p - 1);
    }
    return output;
  }

  //s Ne prend que la colonne j
  Matrix GetCol(int j) {
    return GetCol(new int[]{j});
  }

  //s Prend les colonnes de [_a_;_b_]
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

  //f Crée une nouvelle matrice à partir de _this_, prenant les colonnes d'indice dans _jList_, restreint entre _startCol_ et _endCol_
  Matrix GetCol(int[] jList, int startCol, int endCol) {
    if (jList.length < 1) { cl.pln(this, jList, this.p, "GetCol", "List must be of length >= 1"); Exception e = new Exception(); e.printStackTrace(); return this; }
    if (jList.length < endCol || startCol > endCol) { cl.pln(this, jList, this.p, startCol, endCol, "GetCol", "Conflict with startCol & endCol"); Exception e = new Exception(); e.printStackTrace(); return this; }
    for(int j : jList)
      if (j < 0 || j >= this.p) { cl.pln(this, j, this.p, "GetCol", "Wrong Column Index"); Exception e = new Exception(); e.printStackTrace(); return this; }

    Matrix new_mat = new Matrix(this.n, endCol - startCol);
    for(int k = 0; k < endCol - startCol; k++) {
      for(int i = 0; i < this.n; i++)
        new_mat.values[i * new_mat.p + k] = this.values[i * this.p + jList[k + startCol]];
    }

    return new_mat;
  }

  //f Met les valeurs du tableau _col_ dans la _j-ième_ colonne de _this_
  Matrix ColumnFromArray(int j, float[] col) {
    if (j < 0 || j >= this.p) { cl.pln(this, j, "ColumnFromArray", "Wrong Column Index"); Exception e = new Exception(); e.printStackTrace(); return this; }
    if (col.length != this.n) { cl.pln(this, col.length, "ColumnFromArray", "Wrong Sized Column"); Exception e = new Exception(); e.printStackTrace(); return this; }

    for(int i = 0; i < this.n; i++) this.values[i * this.p + j] = col[i];

    return this;
  }

  //f Crée un tableau à partir de la _j_-ième colonne de _this_
  float[] ColumnToArray(int j) {
    float[] col = new float[this.n];
    if (j < 0 || j >= this.p) { cl.pln(this, j, "ColumnToArray", "Wrong Column Index"); Exception e = new Exception(); e.printStackTrace(); return col; }
    for (int i = 0; i < this.n ;i++) {
      col[i] = this.values[i * this.p + j];
    }
    return col;
  }

  //f Calcule la somme totale des coefficients de la matrice _this_
  float TotalSum() {
    float sum = 0;
    for(int i = 0; i < this.n; i++)
      for(int j = 0; j < this.p; j++)
        sum += this.values[i * this.p + j];
    return sum;
  }

  //f Somme les coefficients de la colonne _j_ de _this_
  float SumCol(int j) {
    if (j < 0 || j >= this.p) { cl.pln(this, j, "SumCol", "Wrong Column Index"); Exception e = new Exception(); e.printStackTrace(); return 0; }

    float sum = 0;
    for(int i = 0; i < this.n; i++)
      sum += this.values[i * this.p + j];

    return sum;
  }

  //f Renvoie la matrice colonne ayant pour valeur les valeurs moyennes des lignes de _this_
  Matrix AvgLine() {
    Matrix matrixOfAverage = new Matrix(this.n, 1);
    for(int i = 0; i < this.n; i++) {
      float avg = 0;
      for(int j = 0; j < this.p; j++)
        avg += this.values[i * this.p + j] / this.p;

      matrixOfAverage.values[i] = avg;
    }
    return matrixOfAverage;
  }

  //s Chaque matrice a le même poids
  public Matrix AvgMatrix(Matrix[] mats) {
    float[] coeffs = new float[mats.length];
    for(int i = 0; i < mats.length; i++) coeffs[i] = 1;
    return AvgMatrix(mats, coeffs);
  }

  //f Retourne la matrice résultant de la moyenne des matrices de _mats_
  // On utilise comme poids les _coeffs_
  public Matrix AvgMatrix(Matrix[] mats, float[] coeffs) {
    if(mats.length != coeffs.length) { cl.pln(this, "AvgMatrix", "Matrixes and Coefficients of different sizes"); Exception e = new Exception(); e.printStackTrace(); return mats[0]; }
    for(int i = 1; i < mats.length; i++) {
      if(mats[i].n != mats[0].n || mats[i].p != mats[0].p) { cl.pln(this, "AvgMatrix", "Uncompatible matrix sizes"); Exception e = new Exception(); e.printStackTrace(); return mats[0]; }
    }

    float sumCoeffs = 0;
    for(float c : coeffs) sumCoeffs += c;
    if(sumCoeffs == 0) { cl.pln(this, "AvgMatrix", "Coefficients sum to 0"); Exception e = new Exception(); e.printStackTrace(); return mats[0]; }

    Matrix avgMat = new Matrix(mats[0].n, mats[0].p);
    for(int i = 0; i < mats.length; i++) {
      avgMat.Add(mats[i], coeffs[i]/sumCoeffs);
    }
    return avgMat;
  }

  public Matrix Concat(Matrix[] mats) {
    if(mats.length == 0) return new Matrix(0);
    for(int i = 1; i < mats.length; i++) {
      if(mats[i].n != mats[0].n) { cl.pln(mats[0], mats[i], "Concat"); Exception e = new Exception(); e.printStackTrace(); return mats[0]; }
    }
    int sum = 0;
    for(int i = 0; i < mats.length; i++) sum += mats[i].p;

    Matrix concatedMat = new Matrix(mats[0].n, sum);
    int index = 0;
    for(int i = 0; i < mats.length; i++) {
      for(int j = 0; j < mats[i].p ; j++) {
        concatedMat.ColumnFromArray(index + j, mats[i].ColumnToArray(j));
      }
      index += mats[i].p;
    }

    return concatedMat;
  }

  //f Crée une nouvelle matrice, correspondant au produit de _this_ par _m_
  Matrix Mult(Matrix m) {
    if (p != m.n) { cl.pln(this, m, "Mult", "Wrong sized matrixes"); Exception e = new Exception(); e.printStackTrace(); return this; }

    int initTime = millis();

    Matrix new_mat = new Matrix(n, m.p);
    float s = 0;
    for (int i = 0; i < n; i++) {
      for (int j = 0; j < m.p; j++) {
        s = 0;
        for (int k = 0; k < p; k++)
          s += this.values[i *  this.p + k] * m.values[k * m.p + j];

        new_mat.values[i * new_mat.p + j] = s;
      }
    }

    //println("MULT : (" + str(this.n) + "*" + str(this.p) + ")x(" + str(m.n) + "*"  + str(m.p) + ") Time : " + str(millis() - initTime));

    return new_mat;
  }

  Matrix GPUMult(Matrix m) {
    int initTime = millis();

    float[] A = this.values;
    float[] B = m.values;

    float[] C = new float[this.n * m.p];

    final int N = this.n;
    final int K = this.p;
    final int M = m.p;

    matrixMultKernel.SetData(A, B, C, N, K, M);
    matrixMultKernel.execute(Range.create(N * M));

    //println("GPUMULT : (" + str(this.n) + "*" + str(this.p) + ")x(" + str(m.n) + "*"  + str(m.p) + ") Time : " + str(millis() - initTime));


    return new Matrix(this.n, m.p).Unflatten(C);
  }

  float[] Flatten() {
    return this.values;
  }

  Matrix Unflatten(float[] flat) {
    if(flat.length != this.n * this.p) { cl.pln(this, flat, "Unflatten", "Wrong sized array"); Exception e = new Exception(); e.printStackTrace(); return this; }

    this.values = flat;
    return this;
  }

  //f Renvoie une nouvelle matrice, correspondant au produit de Hadamard entre _this_ et _m_
  Matrix HProduct(Matrix m) {
    if((p != m.p && m.p != 1)  || n != m.n) { cl.pln(this, m, "HPrduct", "Wrong sized matrixes"); Exception e = new Exception(); e.printStackTrace(); return this; }

    for(int k = 0; k < this.values.length; k++)
      this.values[k] = this.values[k] * (m.p == 1 ? m.values[k / this.p] : m.values[k]);

    return this;
  }

  //f Normalise les colonnes de la matrice _this_
  // La somme de chaque colonne est ramené à 1
  Matrix NormColumn() {
    float s = 0;
    for(int j = 0; j < this.p; j++) {
      s = SumCol(j);
      if(s <= 0) {
        this.Debug();
        println("SOME PROBLEMS IN THE VALUES OF THE ARRAY (NORM COLUMN)");
        System.exit(-1);
      }
      if(Math.log10(s) * Math.log10(s) > 100) {
        println("NORMS BEGIN TO BE REALLY HIGH");
      }
      this.Dilat(j, (float)1 / s);
    }

    return this;
  }

  //f Norme la matrice _this_
  // Applique (x - mean) / sqrt(variance)
  Matrix Norm() {
    float[] mean = new float[this.p];
    for(int j = 0; j  < this.p; j++) {
      float sum = 0f;
      for(int i = 0; i < this.n; i++) sum += this.values[i * this.p + j];
      mean[j] = sum / this.n;
    }

    float[] variance = new float[this.p];
    for(int j = 0; j  < this.p; j++) {
      float sum = 0f;
      for(int i = 0; i < this.n; i++) sum += Math.pow(this.values[i * this.p + j] - mean[j], 2);
      variance[j] = sum / this.n;
    }

    for(int i = 0; i < this.n; i++) {
      for(int j = 0; j < this.p; j++) {
        this.values[i * this.p + j] = (this.values[i * this.p + j] - mean[j]) / (sqrt(variance[j] + 1e-8));
      }
    }

    return this;
  }

  //f Retourne une nouvelle matrice, correspondant à la matrice _this_ dont on a enlevé la ligne _i_ et la colonne _j_
  Matrix MinMatrix(int i, int j) {
    if (i < 0 || i >= this.n || j < 0 || j >= this.p) { cl.pln(this, i, j, "MinMatrices", "Wrong indices"); Exception e = new Exception(); e.printStackTrace(); return this; }
    if (this.n == 0 || this.p == 0) { cl.pln(this, "MinMatrices", "Matrix is too small"); Exception e = new Exception(); e.printStackTrace(); return this; }

    Matrix min = new Matrix(this.n - 1, this.p - 1);
    for (int e = 0; e < this.n - 1; e++)
      for (int f = 0; f < this.p - 1; f++)
        min.values[e * min.p + f] = this.values[(e >= i ? e+1 : e) * this.p + (f >= j ? f+1 : f)];

    return min;
  }

  //f Retourne le déterminant de la matrice _this_
  // Calcul récursif de complexité _n_²
  float Det() {
    if (this.n != this.p) { cl.pln(this, "Det", "Not square matrix"); Exception e = new Exception(); e.printStackTrace(); return 0; }
    if (this.n == 1) {
      return this.values[0];
    }

    float det = 0;
    for (int k = 0; k < this.n; k++)
      det += pow(-1, k) * this.values[k * this.p] * this.MinMatrix(k, 0).Det();

    return det;
  }

  //f Retourne la comatrice de _this_
  Matrix Comatrix() {
    if (this.n != this.p) { cl.pln(this, "Comatrix", "Not square matrix"); Exception e = new Exception(); e.printStackTrace(); return new Matrix(this.n, this.p); }
    Matrix comat = new Matrix(this.n);

    for (int i = 0; i < this.n; i++)
      for (int j = 0; j < this.n; j++)
        comat.Set(i,j, pow(-1, i+j) * this.MinMatrix(i,j).Det());

    return comat;
  }

  //f (OBSOLETE) Retourne la matrice inverse de _this_ (si elle existe)
  Matrix OLD_Inversed() {
    if (this.n != this.p) { cl.pln(this, "OLD_Inversed", "Not square matrix"); Exception e = new Exception(); e.printStackTrace(); return new Matrix(this.n, this.p); }
    float det = this.Det();
    if(det == 0) { cl.pln(this, "Inversed", "The matrix determinant is 0"); Exception e = new Exception(); e.printStackTrace(); return new Matrix(this.n, this.p); }

    return this.Comatrix().T().Scale(1/det);
  }

  Matrix Inversed() {
    if (this.n != this.p) { cl.pln(this, "Inversed", "Not square matrix"); Exception e = new Exception(); e.printStackTrace(); return new Matrix(this.n, this.p); }
    Matrix augmentedMatrix = new Matrix(2 * this.n, this.n);

    for(int k = 0; k < this.values.length; k++)
      augmentedMatrix.values[k] = this.values[k];

    for (int i = 0; i < this.n; i++) {
      augmentedMatrix.values[(i + this.n) * this.p + i] = 1;
    }

    // Élimination de Gauss-Jordan
    for (int i = 0; i < this.n; i++) {
      float pivot = 0; int k = i;
      while(k < this.n) {
        pivot = augmentedMatrix.values[i * this.p + k];
        if(pivot != 0) break;
        k++;
      }
      if(k == this.n) { cl.pln(this, "Inversed", "Not inversible"); Exception e = new Exception(); e.printStackTrace(); return new Matrix(this.n, this.p); }

      augmentedMatrix.ComutCol(i, k);
      augmentedMatrix.Dilat(i, 1/pivot);

      for (int j = 0; j < this.n; j++) {
        if (j == i) continue;

        float factor = augmentedMatrix.values[i * this.p + j];

        for (int l = 0; l < 2 * this.n; l++) {
          augmentedMatrix.values[l * this.p + j] -= factor * augmentedMatrix.values[l * this.p + i];
        }
      }
    }

    Matrix inverse = new Matrix(this.n, this.n);
    for (int i = 0; i < this.n; i++) {
      for (int j = 0; j < this.n; j++) {
          inverse.values[i * this.p + j] = augmentedMatrix.values[(i + this.n) * this.p + j];
      }
    }

    return inverse;
  }

  //f Retourne une nouvelle matrice _mat_ sur laquelle on a effectué la convolution complète _filter_
  Matrix FullConvolution(Matrix filter) {
    int initTime = millis();

    Matrix nMat = new Matrix(this.n + filter.n - 1, this.p + filter.p - 1);

    for(int i = 0; i < this.n + filter.n - 1; i++) {
      for(int j = 0; j < this.p + filter.p - 1; j++) {
        nMat.Set(i, j, this.Filter(this, filter, i - filter.n + 1, j - filter.p + 1));
      }
    }

    convolutionTime += millis() - initTime;

    return nMat;
  }

  //f Retourne une nouvelle matrice _mat_ sur laquelle on a effectué la convolution _filter_
  Matrix Convolution(Matrix filter) {
    int initTime = millis();

    Matrix nMat = new Matrix(this.n - filter.n + 1, this.p - filter.p + 1);

    for(int i = 0; i < nMat.n; i++) {
      for(int j = 0; j < nMat.p; j++) {
        nMat.Set(i, j, this.Filter(this, filter, i, j));
      }
    }

    convolutionTime += millis() - initTime;

    return nMat;
  }

  //f Retourne la valeur (_x_, _y_) de la matrice _mat_ à laquelle on applique la convolution de filtre _filter_
  // _x_ représente la ligne et _y_ la colonne (oui, c'est moche)
  float Filter(Matrix mat, Matrix filter, int x, int y) {
    float ret = 0;
    for(int i = 0; i < filter.n; i++) {
      for(int j = 0; j < filter.p; j++) {
        int rx = x + i;
        int ry = y + j;
        if(rx < 0 || ry < 0 || rx >= mat.n || ry >= mat.p) continue; // Considère les pixels en dehors de l'image comme des 0

        ret += mat.values[rx * mat.p + ry] * filter.values[i * filter.p + j];
      }
    }

    return ret;
  }

  //f Dans les faits complétement inutilisables (prend de l'ordre de 50 ms là où une simple prend moins de 1 ms)
  Matrix GPUConvolution(Matrix filter) {
    float[] m = this.Flatten();
    float[] f = filter.Flatten();

    int initTime = millis();

    final int mn= this.n;
    final int mp = this.p;
    final int fn = filter.n;
    final int fp = filter.p;

    final int N = (this.n - filter.n + 1);
    final int P = (this.p - filter.p + 1);

    float[] ret = new float[N*P];

    Kernel kernel = new Kernel() {
      @Override
      public void run() {
        int gid = getGlobalId();
        int x = gid / P;
        int y = gid % P;

        float r = 0;
        for(int i = 0; i < fn; i++) {
          for(int j = 0; j < fp; j++) {
            int rx = x + i;
            int ry = y + j;
            if(rx < 0 || ry < 0 || rx >= mn || ry >= mp) continue; // Considère les pixels en dehors de l'image comme des 0

            r += m[rx * mp + ry] * f[i * fp + j];
          }
        }

        ret[y * P + x] = r;
      }
    };

    kernel.execute(Range.create(N * P));
    kernel.dispose();

    return new Matrix(N, P).Unflatten(ret);
  }

  //f Retourne une copie de la matrice _this_ retournée de 180°
  Matrix Rotate180() {
    Matrix rotated = this.C();

    for(int i = 0; i < this.n; i++) {
      for(int j = 0; j < this.p; j++) {
        rotated.values[i * this.p + j] = this.values[(this.n - i - 1) * this.p + (this.p - j - 1)];
      }
    }

    return rotated;
  }

  //f Fonction de MaxPooling de l'image _img_ (sous forme de matrice) en utilisant un pool de taille _w_ * _h_
  Matrix[] MaxPooling(int w, int h) {
    Matrix pooledMat = new Matrix(ceil((float)this.n / h), ceil((float)this.p / w));
    Matrix mask = new Matrix(this.n, this.p);

    for(int i = 0; i < pooledMat.n; i++) {
      for(int j = 0; j < pooledMat.p; j++) {
        float max = 0;
        int kmax = -1; int lmax = -1;

        for(int k = h * i; k < h * (i+1); k++) {
          for(int l = w * j; l < w * (j+1); l++) {
            if(k >= this.n || l >= this.p) continue;
            if(max >= this.values[k * this.p + l]) continue;

            max = this.values[k * this.p + l];
            kmax = k;
            lmax = l;
          }
        }

        if(kmax != -1 && lmax != -1) mask.Set(kmax, lmax, 1);

        pooledMat.values[i * pooledMat.p + j] = max;
      }
    }

    return new Matrix[]{pooledMat, mask};
  }

  Matrix ToCol() {
    Matrix newMat = new Matrix(this.n * this.p, 1);
    newMat.values = this.values;

    return newMat;
  }

  Matrix FromCol(int w, int h) {
    if (w * h != this.n) { cl.pln(this, "FromCol", "Wrong Size column"); Exception e = new Exception(); e.printStackTrace(); return new Matrix(this.n, this.p); }

    Matrix newMat = new Matrix(h, w);
    newMat.values = this.values;

    return newMat;
  }

  @Override
  public String toString() {
    return "Matrix[" + this.n + "," + this.p + "]";
  }
}

class MatrixMultKernel extends Kernel {
  private float[] A;
  private float[] B;
  private float[] C;
  private int N;
  private int K;
  private int M;

  public void SetData(float[] A, float[] B, float[] C, int N, int K, int M) {
    this.A = A;
    this.B = B;
    this.C = C;
    this.N = N;
    this.K = K;
    this.M = M;
  }

  @Override
  public void run() {
    int gid = getGlobalId();
    int row = gid / M;
    int col = gid % M;

    float sum = 0;
    for(int k = 0; k < K; k++)
      sum += A[row * K + k] * B[k * M + col];

    C[row * M + col] = sum;
  }
}

@FunctionalInterface
interface FunctionMap {
  float calc(float x);
}
