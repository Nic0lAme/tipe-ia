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
      if(this.cnn != null) {
        wordOutput = this.cnn.Predict(entries);
        session.ds.CNNGetImageFromInputs(entries[0]).save("./AuxiliarFiles/CharactersPicker/Test" + 10000 * random(1) + ".jpg");
      } else {
        Matrix entry = new Matrix(entries[0].n * entries[0].p, entries.length);
        for(int k = 0; k < entries.length; k++)
          for(int i = 0; i < entries[k].n; i++)
            for(int j = 0; j < entries[k].p; j++)
              entry.values[(i * entries[k].p + j) * entry.p + k] = entries[k].values[i * entries[k].p + j];
        wordOutput = this.nn.Predict(entry);
        session.ds.GetImageFromInputs(entry, 0).save("./AuxiliarFiles/CharactersPicker/Test" + 10000 * random(1) + ".jpg");
        //wordOutput.Debug();
      }
      
      // Réccupérer les listes de probabilités
      float[][] allProb = new float[w.length][];
      for(int i = 0; i < w.length; i++) {
        allProb[i] = wordOutput.ColumnToArray(i);
      }
      
      //println("AllProb");
      //println(allProb[0]);
      
      float[][] effectiveProb = new float[w.length][];
      for(int i = 0; i < w.length; i++) {
        effectiveProb[i] = cs.GetProb(allProb[i]);
      }
      
      //println("EffectiveProb");
      //println(effectiveProb[0]);
      
      String word = wc.WordAutoCorrection(effectiveProb);
      
      text+=word;
      text+=" ";
    }
    
    return text;
  }
  
}
