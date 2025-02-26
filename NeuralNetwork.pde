class NeuralNetwork {
  // Couches
  int numLayers; // Nombre de couches
  int[] layers;  // Nombre de neurones par couches
  int entrySize, outputSize;

  // Paramètres du réseau de neurones
  Matrix[] weights; // Poids des liaisons (pour un indice i, liaisons entre couche i et couche i+1)
  Matrix[] bias; // Biais (pour un indice i, biais entre couche i et i+1)

  boolean useSoftMax = false; // Détermine l'utilisation de la fonction softmax sur la dernière couche du réseau

  NeuralNetwork() {
    this(1);
  }

  NeuralNetwork(int... sizes) {
    numLayers = sizes.length;
    layers = new int[numLayers];
    for (int i = 0; i < numLayers; i++) layers[i] = sizes[i];

    Init();
  }

  public void UseSoftMax() { this.useSoftMax = true; } // Lorsque SoftMax est utilisé, il est nécessaire d'avoir des sorties qui s'additionnent à 1

  private void Init() {
    entrySize = layers[0];
    outputSize = layers[numLayers-1];
    weights = new Matrix[numLayers-1];
    bias = new Matrix[numLayers-1];

    for (int i = 0; i < numLayers-1; i++) {
      bias[i] = new Matrix(layers[i+1], 1).Random(-1, 1);
      weights[i] = new Matrix(layers[i+1], layers[i]).Random(-1, 1);
    }
  }

  // Importe un réseau de neurones depuis un fichier
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

  // Sauvegarde les paramètres du réseau de neurones
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

  public Matrix Predict(Matrix entry) {
    return ForwardPropagation(entry)[this.numLayers - 1];
  }

  // Prend une matrice en entrée, et renvoie un tableau des valeurs de chaque couche
  // entry.p correspond au nombre d'entrées données simultanément
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

  // Calcule la sortie correspondant à l'entrée in, de la couche from à la couche from+1
  private Matrix CalcLayer(int from, Matrix in) {
    Matrix result = weights[from].Mult(in);
    result.Add(bias[from], 1, true);

    if(from == this.numLayers - 2 && this.useSoftMax) {
      result.Map((x) -> Math.exp(x));
      return result.NormColumn();
    }

    return result.Map((x) -> sigmoid(x));
  }

  public Matrix[][] BackPropagation(Matrix[] activations, Matrix expectedOutput) {

    //dJ/dZl
    Matrix a = activations[this.numLayers-1].C();
    Matrix gradient = a.C().Add(expectedOutput, -1).HProduct(a.C().Add(a.C().HProduct(a), -1));

    Matrix[] weightGrad = new Matrix[this.numLayers - 1];
    Matrix[] biasGrad = new Matrix[this.numLayers - 1];

    float lambda = 0.001;
    boolean hasNaN = false;
    for(int l = this.numLayers - 2; l >= 0; l--) {
      if(gradient.Contains(Double.NaN)) hasNaN = true;

      //dJ/dWl = dJ/dZl * dZl/dWl
      weightGrad[l] = gradient.Mult(activations[l].T()).Scale(1/ (double)max(1, expectedOutput.p)).Add(weights[l], lambda / max(1, weights[l].n * weights[l].p));
      //weightGrad[l].DebugShape();

      if(weightGrad[l].Contains(Double.NaN)) hasNaN = true;

      //dJ/dbl = dJ/dZl * dZl/dbl
      biasGrad[l] = gradient.AvgLine().Add(bias[l], lambda / max(1, bias[l].n));
      //biasGrad[l].DebugShape();

      if(biasGrad[l].Contains(Double.NaN)) hasNaN = true;

      a = activations[l].C();
      gradient = (weights[l].T().Mult(gradient)).HProduct(a.C().Add(a.C().HProduct(a), -1));
    }

    if(hasNaN) {
      for(int l = 0; l < this.numLayers; l++) {
        cl.pln("Layer", l);

        activations[l].Debug();

        if(l == this.numLayers - 1) continue;
        weightGrad[l].Debug();
        biasGrad[l].Debug();
      }
    }

    return new Matrix[][]{weightGrad, biasGrad};
  }

  public double Learn(Matrix X, Matrix Y, float learning_rate) {
    Matrix[] activations = ForwardPropagation(X);
    Matrix S = activations[this.numLayers - 1].C();

    Matrix[][] gradients = BackPropagation(activations, Y);


    for(int l = 0; l < this.numLayers - 1; l++) {
      this.weights[l].Add(gradients[0][l], -learning_rate);
      this.bias[l].Add(gradients[1][l], -learning_rate);
    }

    double J = 0;
    for(int c = 0; c < Y.p; c++) { //colonne de la sortie
      for(int i = 0; i < Y.n; i++) { //ligne de la sortie
        J -= Y.Get(i, c) * log(abs((float)S.Get(i, c))) / Y.p;
      }
    }

    return J;
  }

  public void LearningPhase(Matrix X, Matrix Y, int numOfEpoch, float minLearningRate, float maxLearningRate, int period, int numPerIter, String label) {
    float learningRate; double loss;
    IntList range = new IntList();
    for(int j = 0; j < X.p; j++) range.append(j);

    int startTime = millis();

    IntList selectedIndex = range.copy();
    Matrix selectedX;
    Matrix selectedY;
    int startIndex = X.p;
    for(int k = 0; k < numOfEpoch; k++) {
      startIndex += numPerIter / 16; // Décalage de 1/16 dans l'array ie on change 1/16 de l'entrée
      if(numPerIter != 0) {
        if(startIndex + numPerIter >= X.p) {
          selectedIndex = range.copy();
          selectedIndex.shuffle();

          startIndex = 0;
        }

        selectedX = X.GetCol(selectedIndex.array(), startIndex, min(numPerIter + startIndex, X.p - 1));
        selectedY = Y.GetCol(selectedIndex.array(), startIndex, min(numPerIter + startIndex, Y.p - 1));
      } else {
        selectedX = X;
        selectedY = Y;
      }

      learningRate = CyclicalLearningRate(k, minLearningRate, maxLearningRate, period);


      loss = nn.Learn(selectedX, selectedY, learningRate);

      if(loss != loss) { // Le loss est NaN
        for(int l = 0; l < this.numLayers - 1; l++) {
          this.weights[l].Debug();
          this.bias[l].Debug();
        }
        System.exit(-1);
      }

      if(k%16 != 0 && k != numOfEpoch - 1) continue;

      float[] score = AccuracyScore(this, selectedX, selectedY, false);

      cl.p(label, "\t-\t", k+1, "/", numOfEpoch,
        "\t-\tTime Remaining", String.format("%.1f", (double)(millis() - startTime) / (k+1) * (numOfEpoch-k-1) / 1000),
        "\t-\tLearning Rate", String.format("%.5f", learningRate),
        "\t-\tLoss", String.format("%.5f", loss),
        "\t-\tAccuracy", String.format("%.3f", Average(score))
      );

      cl.pFloatList(score, "\t");


    }
  }

  public void MiniBatchLearn(Matrix[] data, int numOfEpoch, int batchSize, float lr) {
    println("Mini Batch Gradient Descent - " + numOfEpoch + " Epochs - " + batchSize + " Batch Size");
    for (int k = 0; k < numOfEpoch; k++) {
      println("Epoch " + (k+1) + "/" + numOfEpoch + "\t");

      // Mélange les données (Fisher–Yates shuffle)
      for (int i = 0; i < data[0].p-1; i++) {
        int j = floor(random(i, data[0].p));
        data[0].ComutCol(i, j);
        data[1].ComutCol(i, j);
      }

      int numberOfBatches = floor(data[0].p / batchSize);
      for (int i = 0; i < numberOfBatches; i++) {
        Matrix batch = data[0].GetCol(i*batchSize, i*batchSize + batchSize - 1);
        Matrix batchAns = data[1].GetCol(i*batchSize, i*batchSize + batchSize - 1);
        double l = this.Learn(batch, batchAns, lr);
        if (i % (numberOfBatches / 4) == 0)
          println("\t Epoch " + (k+1) + " / Batch " + (i+1) + " : " + l);
      }
    }
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
float CyclicalLearningRate(int iter, float min, float max, int period) {
  float cycle = floor(1 + iter / (2 * period));
  float x = abs(iter / period - 2 * cycle + 1);
  return min + (max - min) * max(0, x);
}
