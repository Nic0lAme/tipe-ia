class NeuralNetwork {
  // Couches
  int numLayers; // Nombre de couches
  int[] layers;  // Nombre de neurones par couches
  
  // Paramètres du réseau de neurones
  Matrix[] weights; // Poids des liaisons (pour un indice i, liaisons entre couche i et couche i+1)
  Matrix[] bias; // Biais (pour un indice i, biais entre couche i et i+1)
  
  NeuralNetwork(int... sizes) {
    layers = new int[numLayers];
    weights = new Matrix[numLayers-1];
    bias = new Matrix[numLayers-1];
    for (int i = 0; i < numLayers; i++) layers[i] = sizes[i];
    Init();
  }
  
  private void Init() {
    for (int i = 0; i < numLayers-1; i++) {
      bias[i] = new Matrix(layers[i+1], 1).Random();
      weights[i] = new Matrix(layers[i+1], layers[i]).Random();
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
