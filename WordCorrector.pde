class WordCorrector {
  char[] charList = new char[]{'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z'};
  double[] letterSpreading = new double[]{0.1, 0.05};
  double fiability = 1; // 0 -> c'est vraiment très mauvais / 1 -> c'est vraiment excellent
  
  int[][] words;
  
  //c
  WordCorrector() {}
  
  //f Importe l'ensemble des mots du fichier _scrabble.txt_ dans la variable _this.words_
  public void ImportWords() {
    String[] wordsList = loadStrings("./AuxiliarFiles/scrabble.txt");
    
    this.words = new int[wordsList.length][];
    
    for(int k = 0; k < wordsList.length; k++) {
      String w = wordsList[k].strip();
      int[] wordRepresentation = new int[w.length()];
      
      for(int c = 0; c < w.length(); c++) {
        char character = w.charAt(c);
        wordRepresentation[c] = character - 'A';
      }
      
      this.words[k] = wordRepresentation;
    }
  }
  
  //f Donne le mot le plus probable pour une entrée _letterProb_
  // _letterProb_ contient pour chaque emplacement les probabilités de chaque caractère
  // Simule toutes les manipulations possibles de manière probabiliste
  // Algorithme assez (très) naïf, donc à voir dans la pratique
  public String WordAutoCorrection(double[][] letterProb) {
    double[][] processedProb = new double[letterProb.length][this.charList.length];
    
    for(int letter = 0; letter < letterProb.length; letter++) {
      // Permet de normer les probabilités (somme vaut un)
      double sum = 1 - this.fiability;
      for(int k = 0; k < this.charList.length; k++) {
        sum += letterProb[letter][k];
      }
      
      for(int k = 0; k < this.charList.length; k++) {
        processedProb[letter][k] = (letterProb[letter][k] + (1 - this.fiability) / this.charList.length) / sum;
      }
    }
    
    /*
    // Simule l'insertion / la délétion de lettre
    for(int letter = 0; letter < letterProb.length + this.letterSpreading.length; letter++) {
      for(int k = 0; k < this.charList.length; k++) {
        for(int delta = 1; delta <= this.letterSpreading.length; delta++) {
          if(k - delta >= 0) processedProb[letter][k] += this.letterSpreading[delta] * processedProb[letter][k - delta];
          if(k + delta < processedProb.length) processedProb[letter][k] += this.letterSpreading[delta] * processedProb[letter][k + delta];
        }
      }
    }
    */
    
    int[] bestWord = words[0];
    double bestProb = 0;
    
    for(int[] word : this.words) {
      if(word.length != processedProb.length) continue;
      
      double prob = 1;
      for(int letter = 0; letter < word.length; letter++) {
        prob *= processedProb[letter][word[letter]];
      }
      
      if(prob > bestProb) {
        bestProb = prob;
        bestWord = word;
      }
    }
    
    String ret = "";
    for(int l : bestWord) ret += charList[l];
    
    return ret;
  }
}
