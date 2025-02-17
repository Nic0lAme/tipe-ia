class NeuralNetwork {
  // Couches
  int numLayers; // Nombre de couches
  int[] layers;  // Nombre de neurones par couches
  final int entrySize, outputSize;
  
  // Paramètres du réseau de neurones
  Matrix[] weights; // Poids des liaisons (pour un indice i, liaisons entre couche i et couche i+1)
  Matrix[] bias; // Biais (pour un indice i, biais entre couche i et i+1)
  FunctionMap activationFunction = (x) -> sigmoid(x);
  
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
      bias[i] = new Matrix(layers[i+1], 1).Random();
      weights[i] = new Matrix(layers[i+1], layers[i]).Random();
    }
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
    result.Add(bias[from]);
    return result.Map((x) -> sigmoid(x));
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
