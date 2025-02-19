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

    for (int i = 0; i < weights.length; i++) weights[i].LoadString(input[i+1]);
    for (int i = 0; i < bias.length; i++) bias[i].LoadString(input[1+weights.length+i]);

    return this;
  }

  // Sauvegarde les paramètres du réseau de neurones
  public void Export(String name) {
    String[] output = new String[1 + weights.length + bias.length];

    output[0] = "";
    for (int i = 0; i < layers.length; i++) {
      output[0] += str(layers[i]) + (i != layers.length - 1 ? "," : "");
    }

    for (int i = 0; i < weights.length; i++) output[1+i] = weights[i].SaveToString();
    for (int i = 0; i < bias.length; i++) output[1+weights.length+i] = bias[i].SaveToString();

    saveStrings(name, output);
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
      result.Map((x) -> exp((float)x));
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
    for(int l = this.numLayers - 2; l >= 0; l--) {
      //dJ/dWl = dJ/dZl * dZl/dWl
      weightGrad[l] = gradient.Mult(activations[l].T()).Scale(1/ (double)expectedOutput.p);
      //weightGrad[l].DebugShape();

      //dJ/dbl = dJ/dZl * dZl/dbl
      biasGrad[l] = gradient.AvgLine();
      //biasGrad[l].DebugShape();

      a = activations[l].C();
      gradient = (weights[l].T().Mult(gradient)).HProduct(a.C().Add(a.C().HProduct(a), -1));
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
        J -= Y.Get(i, c) * log((float)S.Get(i, c)) / Y.p;
      }
    }

    return J;
  }
  
  public void LearningPhase(Matrix X, Matrix Y, int numOfEpoch, float minLearningRate, float maxLearningRate, int numOfCycle) {
    float learningRate;
    for(int k = 0; k < numOfEpoch; k++) {
      learningRate = CyclicalLearningRate(k, minLearningRate, maxLearningRate, numOfEpoch / numOfCycle);
      println(k+1,
        "\t-\tTime Remaining", String.format("%.3f", (double)millis() / k * (numOfEpoch-k) / 1000),
        "\t-\tLearning Rate", String.format("%.5f", learningRate),
        "\t-\tLoss", nn.Learn(X, Y, learningRate)
      );
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
  return 1/(1+exp(-(float)x));
}

// En gros ça fait un blinker de period min suivi de period max
float CyclicalLearningRate(int iter, float min, float max, int period) {
  float cycle = floor(1 + iter / (2 * period));
  float x = abs(iter / period - 2 * cycle + 1);
  return min + (max - min) * max(0, x);
}
