class ImageReader {
  CNN cnn;
  NeuralNetwork nn;
  
  ImageReader(CNN cnn) {
    this.cnn = cnn;
  }
  
  ImageReader(NeuralNetwork nn) {
    this.nn = nn;
  }
  
  public String Read(PImage img) {
    ImageSeparator is = new ImageSeparator(img);
    PImage[][] wordsImages = new PImage[0][];
    wordsImages = is.GetWordsImages();
    
    String text = "";
    for(PImage[] w : wordsImages) {
      // Réccupérer la prédiction pour le mot
      Matrix[] entries = new Matrix[w.length];
      for(int i = 0; i < w.length; i++) {
        entries[i] = session.ImgPP(w[i]);
      }
      
      Matrix wordOutput;
      if(this.cnn == this.cnn) {
        Matrix entry = new Matrix(entries[0].n * entries[0].p, entries.length);
        for(int k = 0; k < entries.length; k++) entry.ColumnFromArray(k, entries[k].values);
        wordOutput = this.nn.Predict(entry);
      } else {
        wordOutput = this.cnn.Predict(entries);
      }
      
      // Réccupérer les listes de probabilités
      float[][] allProb = new float[w.length][];
      for(int i = 0; i < w.length; i++) {
        allProb[i] = wordOutput.ColumnToArray(i);
      }
      
      float[][] effectiveProb = new float[w.length][];
      for(int i = 0; i < w.length; i++) {
        effectiveProb[i] = cs.GetProb(allProb[i]);
      }
      
      String word = wc.WordAutoCorrection(effectiveProb);
      
      text+=word;
      text+=" ";
    }
    
    return text;
  }
  
}
