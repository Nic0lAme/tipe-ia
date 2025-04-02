class NeuralNetwork {
  // Couches
  int numLayers; // Nombre de couches
  int[] layers;  // Nombre de neurones par couches
  int entrySize, outputSize;

  // Paramètres du réseau de neurones
  Matrix[] weights; // Poids des liaisons (pour un indice i, liaisons entre couche i et couche i+1)
  Matrix[] bias; // Biais (pour un indice i, biais entre couche i et i+1)

  double lambda = 0.0000001;

  boolean useSoftMax = false; // Détermine l'utilisation de la fonction softmax sur la dernière couche du réseau

  ExecutorService executor;

  //b Pour *Import*
  NeuralNetwork() {
    this(1);
  }

  //c _sizes_ correspond aux tailles des niveaux
  NeuralNetwork(int... sizes) {
    numLayers = sizes.length;
    layers = new int[numLayers];
    for (int i = 0; i < numLayers; i++) layers[i] = sizes[i];
    executor = Executors.newFixedThreadPool(numThreadsLearning);

    Init();
  }

  public void UseSoftMax() { this.useSoftMax = true; } // Lorsque SoftMax est utilisé, il est nécessaire d'avoir des sorties qui s'additionnent à 1

  private void Init() {
    entrySize = layers[0];
    outputSize = layers[numLayers-1];
    weights = new Matrix[numLayers-1];
    bias = new Matrix[numLayers-1];

    for (int i = 0; i < numLayers-1; i++) {
      // Normal Xavier Weight Initialization
      bias[i] = new Matrix(layers[i+1], 1).Random(-sqrt(6) / sqrt(layers[i] + layers[i+1]), sqrt(6) / sqrt(layers[i] + layers[i+1]));
      weights[i] = new Matrix(layers[i+1], layers[i]).Random(-1, 1);
    }
  }

  //f Importe un réseau de neurones depuis le fichier _name_
  public NeuralNetwork Import(String name) {
   String[] input = loadStrings(name);
   String[] sizes = split(input[0], ',');

   numLayers = sizes.length;
   layers = new int[numLayers];
   for (int i = 0; i < sizes.length; i++) layers[i] = int(sizes[i]);

   Init();

   int cpt = 1;
   for (int i = 0; i < weights.length; i++) {
     String[] weightMatrixString = new String[weights[i].n];
     for (int k = 0; k < weights[i].n; k++) {
       weightMatrixString[k] = input[cpt];
       cpt++;
     }
     weights[i].LoadString(weightMatrixString);
   }

   for (int i = 0; i < bias.length; i++) {
     String[] biasMatrixString = new String[bias[i].n];
     for (int k = 0; k < bias[i].n; k++) {
       biasMatrixString[k] = input[cpt];
       cpt++;
     }
     bias[i].LoadString(biasMatrixString);
   }

   return this;
  }

  //f Sauvegarde les paramètres du réseau de neurones dans _name_
  public void Export(String name) {
   ArrayList<String> output = new ArrayList<String>();

   output.add("");
   for (int i = 0; i < layers.length; i++) {
     output.set(0, output.get(0) + str(layers[i]) + (i != layers.length - 1 ? "," : ""));
   }

   for (int i = 0; i < weights.length; i++) {
     String[] matrixSave = weights[i].SaveToString();
     for (String s : matrixSave) output.add(s);
     cl.pln("Exported weight\t", i+1, "/", weights.length);
   }
   for (int i = 0; i < bias.length; i++) {
     String[] matrixSave = bias[i].SaveToString();
     for (String s : matrixSave) output.add(s);
     cl.pln("Exported bias\t", i+1, "/", bias.length);
   }

   String[] writedOutput = new String[output.size()];
   saveStrings(name, output.toArray(writedOutput));
  }

  //f Donne la sortie du réseau de neurones _this_ pour l'entrée _entry_
  public Matrix Predict(Matrix entry) {
    return ForwardPropagation(entry)[this.numLayers - 1];
  }

  //f Prend la matrice _entry_ en entrée, et renvoie un tableau des valeurs de chaque couche
  // _entry.p_ correspond au nombre d'entrées données simultanément
  public Matrix[] ForwardPropagation(Matrix entry) {
    if (entry.n != entrySize) {
      println(entry.n, entrySize);
      println("Taille de l'entrée invalide");
      return null;
    }

    Matrix[] layerVal = new Matrix[this.numLayers];
    layerVal[0] = entry;
    for(int i = 0; i < this.numLayers - 1; i++) {
      layerVal[i + 1] = CalcLayer(i, layerVal[i]);
    }

    return layerVal;
  }

  //f Calcule la sortie correspondant à l'entrée _in_, de la couche _from_ à la couche _from+1_
  private Matrix CalcLayer(int from, Matrix in) {
    Matrix result = weights[from].Mult(in);

    result.Add(bias[from], 1, true);

    if(from == this.numLayers - 2 && this.useSoftMax) {
      double max = result.Get(0,0);
      for(int i = 0; i < result.n; i++)
        for(int j = 0; j < result.p; j++)
          if(result.Get(i,j) > max) max = result.Get(i,j);

      result.Add(new Matrix(result.n, result.p).Fill(-max));

      result.Map((x) -> Math.exp(x));
      if(result.HasNAN()) {
        println("IN MAP EXP");
        System.exit(-1);
      }

      result.NormColumn();
      if(result.HasNAN()) {
        println("IN NORMCOLUMN");
        System.exit(-1);
      }
      return result;
    }

    result.Map((x) -> sigmoid(x));
    if(result.HasNAN()) {
      println("IN MAP SIGMOID");
      System.exit(-1);
    }

    return result;
  }

  //f Effectue la rétropropagation du réseau de neurones
  // On prend en entrée les valeurs d'_activations_ des layers
  // On donne les valeurs attendues dans _expectedOutput_
  public Matrix[][] BackPropagation(Matrix[] activations, Matrix expectedOutput) {

    //dJ/dZl
    Matrix a = activations[this.numLayers-1].C();
    Matrix gradient = a.C().Add(expectedOutput, -1).HProduct(a.C().Add(a.C().HProduct(a), -1));

    Matrix[] weightGrad = new Matrix[this.numLayers - 1];
    Matrix[] biasGrad = new Matrix[this.numLayers - 1];

    boolean hasNaN = false;
    for(int l = this.numLayers - 2; l >= 0; l--) {
      if(gradient.HasNAN()) {
        println("IN GRADIENT");
        System.exit(-1);
      }

      //dJ/dWl = dJ/dZl * dZl/dWl
      weightGrad[l] = gradient.Mult(activations[l].T()).Scale(1/ (double)max(1, expectedOutput.p));
      if(weightGrad[l].HasNAN()) {
        println("IN WEIGHTGRAD");
        System.exit(-1);
      }
      //weightGrad[l].DebugShape();

      //dJ/dbl = dJ/dZl * dZl/dbl
      biasGrad[l] = gradient.AvgLine();
      if(biasGrad[l].HasNAN()) {
        println("IN BIASGRAD");
        System.exit(-1);
      }
      //biasGrad[l].DebugShape();

      if(lambda != 0) {
        weightGrad[l].Add(weights[l], lambda / max(1, weights[l].n * weights[l].p));
        biasGrad[l].Add(bias[l], lambda / max(1, bias[l].n));
      }

      if(weightGrad[l].HasNAN() || biasGrad[l].HasNAN()) hasNaN = true;

      a = activations[l].C();
      gradient = (weights[l].T().Mult(gradient)).HProduct(a.C().Add(a.C().HProduct(a), -1));
    }

    /*
    if(hasNaN) {
      for(int l = 0; l < this.numLayers; l++) {
        cl.pln("Layer", l);

        activations[l].Debug();

        if(l == this.numLayers - 1) continue;
        weightGrad[l].Debug();
        biasGrad[l].Debug();
      }

      System.exit(-1);
    }
    */

    return new Matrix[][]{weightGrad, biasGrad};
  }

  //f Effectue une étape d'apprentissage, ayant pour entrée _X_ et pour sortie _Y_
  // Le taux d'apprentissage est _learning\_rate_
  public double Learn(Matrix X, Matrix Y, double learning_rate) {
    // Gradients des poids ([0]) et des biais([1]) pour chaque couche l ([][l])
    Matrix[][] gradients = new Matrix[2][this.numLayers-1];

    // Activations de la dernière couche pendant la forward propagation
    Matrix S;

    // Sans multithreading, back propagation classique
    if (numThreadsLearning <= 1) {
      Matrix[] activations = ForwardPropagation(X);
      S = activations[this.numLayers - 1].C();
      gradients = BackPropagation(activations, Y);
    }

    // Avec multithreading : le batch est divisé en numThreadsLearning sous-batchs, la
    // back propagation est effectuée sur chaque sous-batchs, et les résultats sont moyennés
    else {
      ArrayList<Callable<Object>> tasks = new ArrayList<Callable<Object>>();
      final Matrix[] trainingData = X.Split(numThreadsLearning);
      final Matrix[] answers = Y.Split(numThreadsLearning);

      // Gradients calculés, par sous-batch et par couche
      // TODO: remplacer les arraylist par des arrays pour éviter erreurs et conversions
      ArrayList<Matrix[]> weightsGradients = new ArrayList<Matrix[]>(numThreadsLearning);
      ArrayList<Matrix[]> biasGradients = new ArrayList<Matrix[]>(numThreadsLearning);
      final Matrix[] partialS = new Matrix[numThreadsLearning];
      Object syncObject = new Object();

      for (int i = 0; i < numThreadsLearning; i++) {
        final int index = i;

        // Tâche d'apprentissage : backpropagation sur un sous-batch, et les données
        // sont stockées dans les tableaux weightsGradients, biasGradients et partialS
        // Le thread i remplit les cases i des tableaux (quand ce sera des tableaux)
        class LearningTask implements Callable<Object> {
          public Object call() {
            Matrix[] activations = ForwardPropagation(trainingData[index]);
            Matrix output = activations[numLayers - 1].C();
            Matrix[][] gradientPart = BackPropagation(activations, answers[index]);

            synchronized(syncObject) {
              weightsGradients.add(gradientPart[0]);
              biasGradients.add(gradientPart[1]);
              partialS[index] = output;
            }

            return this;
          }
        }
        tasks.add(new LearningTask());
      }

      // Déclenche l'apprentissage des sous-batchs en parallèle
      try {
        List<Future<Object>> executorsAns = executor.invokeAll(tasks);
      } catch (InterruptedException e) {
        cl.pln("NeuralNetwork, Learn : Erreur critique, bonne chance pour la suite");
      }

      // Recombine les données pour former les gradients et l'activation de la dernière couche
      for (int l = 0; l < this.numLayers-1; l++) {
        double[] coeffs = new double[numThreadsLearning];
        Matrix[] wlGradients = new Matrix[numThreadsLearning]; // Gradients pour les poids de la couche l
        Matrix[] blGradients = new Matrix[numThreadsLearning]; // Gradients pour les biais de la couche l
        for (int k = 0; k < coeffs.length; k++) {
          coeffs[k] = trainingData[k].p;
          wlGradients[k] = weightsGradients.get(k)[l];
          blGradients[k] = biasGradients.get(k)[l];
        }
        gradients[0][l] = new Matrix(0).AvgMatrix(wlGradients, coeffs);
        gradients[1][l] = new Matrix(0).AvgMatrix(blGradients, coeffs);
      }
      S = new Matrix(0).Concat(partialS);
    }

    synchronized (stopLearning) {
      if (stopLearning.get()) {
        try { println("Learning stopped"); stopLearning.wait(); println("Le retour");}
        catch (Exception e) { e.printStackTrace(); }
      }
    }
    boolean hasNaN = false;
    for(int l = 0; l < this.numLayers - 1; l++) {
      this.weights[l].Add(gradients[0][l], -learning_rate);
      this.bias[l].Add(gradients[1][l], -learning_rate);

      if(weights[l].HasNAN() || bias[l].HasNAN()) hasNaN = true;
    }

    double J = this.ComputeLoss(S, Y);

    /*
    if(hasNaN || J != J) {
      for(int l = 0; l < this.numLayers; l++) {
        cl.pln("Layer", l);

        activations[l].Debug();

        if(l == this.numLayers - 1) continue;
        weights[l].Debug();
        bias[l].Debug();
      }

      System.exit(-1);
    }
    */

    return J;
  }

  //f Permet le calcul du loss
  // _S_ est la sortie du système
  // _Y_ est la sortie attendue
  public double ComputeLoss(Matrix S, Matrix Y) {
    double J = 0;
    for(int c = 0; c < Y.p; c++) { //colonne de la sortie
      for(int i = 0; i < Y.n; i++) { //ligne de la sortie
        if((double)S.Get(i, c) != 0) J -= Y.Get(i, c) * Math.log(Math.abs((double)S.Get(i, c))) / Y.p;
      }
    }
    return J;
  }

  public double MiniBatchLearn(Matrix[] data, int numOfEpoch, int batchSize, double lr) {
    return MiniBatchLearn(data, numOfEpoch, batchSize, lr, lr, 1);
  }

  public double MiniBatchLearn(Matrix[] data, int numOfEpoch, int batchSize, double minLR, double maxLR, int period) {
    return MiniBatchLearn(data, numOfEpoch, batchSize, minLR, maxLR, period, new Matrix[][]{data}, "");
  }

  public double MiniBatchLearn(Matrix[] data, int numOfEpoch, int batchSize, double minLR, double maxLR, int period, Matrix[][] testSets, String label) {
    cl.pln("Mini Batch Gradient Descent " + label + " - " + numOfEpoch + " Epochs - " + batchSize + " Batch Size - " + String.format("%9.3E", maxLR) + " LR");

    double lossAverage = 0;

    int startTime = millis();
    int numOfBatches = floor(data[0].p / batchSize);
    for (int k = 0; k < numOfEpoch; k++) {
      double learningRate = CyclicalLearningRate(k, minLR, maxLR, period);
      cl.pln("(" + label + ") \tEpoch " + (k+1) + "/" + numOfEpoch + "\t Learning Rate : " + String.format("%6.4f", learningRate));

      for (int i = 0; i < data[0].p-1; i++) {
        int j = floor(random(i, data[0].p));
        data[0].ComutCol(i, j);
        data[1].ComutCol(i, j);
      }

      lossAverage = 0;

      for (int i = 0; i < numOfBatches; i++) {
        Matrix batch = data[0].GetCol(i*batchSize, i*batchSize + batchSize - 1);
        Matrix batchAns = data[1].GetCol(i*batchSize, i*batchSize + batchSize - 1);
        double l = this.Learn(batch, batchAns, learningRate);
        lossAverage += l / numOfBatches;
        graphApplet.AddValue(l);

        if (abortTraining.get()) return lossAverage;

        if (i % (numOfBatches / 4) == 0)
          cl.pln("\t Epoch " + String.format("%05d",k+1) +
            " Batch " + String.format("%05d",i+1) + " : " + String.format("%9.3E",l) +
            "\t Time remaining " + RemainingTime(startTime, k * numOfBatches + i + 1, numOfBatches * numOfEpoch)
          );
      }

      if((k+1)%6 != 0 && k != numOfEpoch - 1) continue;

      for(int s = 0; s < testSets.length; s++) {
        float[] score = CompilScore(session.AccuracyScore(this, testSets[s], false));
        cl.p("\t Score", str(s), ":", String.format("%7.5f", Average(score)));
      }
      cl.pln();
    }

    return lossAverage;
  }

  @Override
  public String toString() {
    String str = "NeuralNetwork[";
    for (int i = 0; i < numLayers; i++) {
      str += str(layers[i]);
      if (i < numLayers -1) str += ", ";
    }
    return str + "]";
  }
}

double sigmoid(double x) {
  return 1/(1+Math.exp(-x));
}

// En gros ça fait un blinker de period min suivi de period max
double CyclicalLearningRate(int iter, double min, double max, int period) {
  if(iter%period + 1 <= period/2) return max;
  return min;
}
