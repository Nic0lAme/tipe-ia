class NeuralNetwork {
  // Couches
  int numLayers; // Nombre de couches
  int[] layers;  // Nombre de neurones par couches
  final int entrySize, outputSize;
  
  // Paramètres du réseau de neurones
  Matrix[] weights; // Poids des liaisons (pour un indice i, liaisons entre couche i et couche i+1)
  Matrix[] bias; // Biais (pour un indice i, biais entre couche i et i+1)
  
  NeuralNetwork(int... sizes) {
    numLayers = sizes.length;
    layers = new int[numLayers];
    for (int i = 0; i < numLayers; i++) layers[i] = sizes[i];
    
    entrySize = layers[0];
    outputSize = layers[numLayers-1];
    weights = new Matrix[numLayers-1];
    bias = new Matrix[numLayers-1];
    Init();
  }
  
  private void Init() {
    for (int i = 0; i < numLayers-1; i++) {
      bias[i] = new Matrix(layers[i+1], 1).Random(-1, 1);
      weights[i] = new Matrix(layers[i+1], layers[i]).Random(-1, 1);
    }
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
      weightGrad[l] = gradient.Mult(activations[l].T());
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
