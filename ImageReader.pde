class ImageReader {
  CNN cnn;
  NeuralNetwork nn;
  boolean saveWordImage = false;

  float ponctuationThreshold = 0;

  //c Prend en entrée un réseau CNN
  // Permet d'utiliser le réseau passé en argument pour lire des textes,
  // avec ou sans correction.
  ImageReader(CNN cnn) {
    this.cnn = cnn;
  }

  //b Prend en entrée un réseau simple à la place
  ImageReader(NeuralNetwork nn) {
    this.nn = nn;
  }

  //f La correction est activée par défaut
  public String Read(PImage img) {
    return Read(img, true);
  }

  //f Renvoie une chaine de caractères correspondant au texte sur l'_img_
  // _withCorrection_ indique si l'on souhaite utiliser la correction automatique ou non
  // Fonctionne selon les étapes suivantes :
  // -> Récupération des mots et des lettres individuellement avec ImageSeparator
  // -> Reconnaissance de la ponctuation
  // -> Reconnaissance des lettres
  // -> Correction avec dictionnaire
  public String Read(PImage img, boolean withCorrection) {

    // Etape 1 : Récupère les mots et les lettres comme images
    ImageSeparator is = new ImageSeparator(img);
    PImage[][] wordsImages = new PImage[0][];
    wordsImages = is.GetWordsImages();
    

    /*
    float[] etalonnedProp = new float[26];
    if(this.cnn != null) etalonnedProp = cs.GetEtalonnedProp(this.cnn);
    else Arrays.fill(etalonnedProp, 1);

    println(etalonnedProp);
    */

    // On stocke la taille moyenne des lettres pour trouver les caractères correspondant
    // à de la ponctuation. Par exemple, les points sont plus petits, et sont donc facilement
    // détectables.
    float numberOfLettersAverage = 0;
    String text = "";
    ArrayList<float[][]> wordsEffectiveProb = new ArrayList<float[][]>();
    ArrayList<Integer> boundingBoxSizesList = new ArrayList<>();
    
    int totalNumOfChar = 0;
    for(int i = 0; i < wordsImages.length; i++)
      for(int j = 0; j < wordsImages[i].length; j++)
        totalNumOfChar++;

    int[][] boundingBoxSizes = new int[wordsImages.length][];
    float averageBoundingBoxSize = 0;

    for(int i = 0; i < wordsImages.length; i++) {
      boundingBoxSizes[i] = new int[wordsImages[i].length];
      for(int j = 0; j < wordsImages[i].length; j++) {
        int[] boundingBox = im.GetBoundingBox(wordsImages[i][j]);
        //println(boundingBox);
        boundingBoxSizes[i][j] = (boundingBox[2] - boundingBox[0])*(boundingBox[3] - boundingBox[1]);
        boundingBoxSizesList.add(boundingBoxSizes[i][j]);
        averageBoundingBoxSize += (float)boundingBoxSizes[i][j] / totalNumOfChar;
        
        //if(boundingBoxSizes[i][j] != 0) println(boundingBoxSizes[i][j]);

        //wordsImages[i][j].save("./AuxiliarFiles/BoundingBoxTest/" + str(boundingBoxSizes[i][j]) + " " + str(random(1)) + ".jpg");
      }
    }
    println("Average bounding box :", averageBoundingBoxSize);
    SaveIntListAsCSV(boundingBoxSizesList.stream().mapToInt(Integer::intValue).toArray(), "./AuxiliarFiles/BoundingBoxSizeGraph.csv");

    // Reconnaissance des lettres et des mots par le réseau
    // Pour chaque lettre, on obtient ainsi une liste de probabilités
    // (ex : A -> 1%, B -> 90%, C -> 5%, ...)
    ArrayList<String> ponctuationsList = new ArrayList<>();
    int wordIndex = -1;
    for(PImage[] w : wordsImages) {
      wordIndex++;

      // Réccupérer la prédiction pour le mot
      Matrix[] entries = new Matrix[w.length];
      for(int i = 0; i < w.length; i++) {
        entries[i] = session.ImgPP(w[i]);
      }

      Matrix entry = new Matrix(0);
      Matrix wordOutput;
      if(this.cnn != null) {
        wordOutput = this.cnn.Predict(entries);
        //session.ds.CNNGetImageFromInputs(entries[0]).save("./AuxiliarFiles/CharactersPicker/Test" + 10000 * random(1) + ".jpg");
      } else {
        entry = new Matrix(entries[0].n * entries[0].p, entries.length);
        for(int k = 0; k < entries.length; k++)
          for(int i = 0; i < entries[k].n; i++)
            for(int j = 0; j < entries[k].p; j++)
              entry.values[(i * entries[k].p + j) * entry.p + k] = entries[k].values[i * entries[k].p + j];
        wordOutput = this.nn.Predict(entry);
        //session.ds.GetImageFromInputs(entry, 0).save("./AuxiliarFiles/CharactersPicker/Test" + 10000 * random(1) + ".jpg");
        //wordOutput.Debug();
      }

      // Récupère les listes de probabilités
      float[][] allProb = new float[w.length][];
      for(int i = 0; i < w.length; i++) {
        allProb[i] = wordOutput.ColumnToArray(i);
      }

      //println("AllProb");
      //println(allProb[0]);

      // Effective prob contient la liste des caractères corrigés par ressemblance
      // Par exemple, un A peut ressembler à un 4, les probabilités sont donc ajustées
      // en conséquence
      float[][] effectiveProb = new float[w.length][];
      for(int i = 0; i < w.length; i++) {
        effectiveProb[i] = cs.GetProb(allProb[i]);
      }

      // Si le paramètre est activé, sauvegarde des images des mots
      // Utile pour déboguer
      if(saveWordImage) {
        float randomName = random(1000);
        for(int i = 0; i < w.length; i++) {
          // Sauvegarde du mot dans un fichier à part
          String prob = str(i);
          float letterThreshold = 0.17;

          int count = 0;
          for(int l = 0; l < effectiveProb[i].length; l++) {
            if(effectiveProb[i][l] < letterThreshold) continue;
            prob += " - " + String.valueOf(wc.charList[l]) + " " + String.format("%.3f", effectiveProb[i][l]);
            count++;
          }

          numberOfLettersAverage += (float)count / w.length / wordsImages.length;

          //println(w.length, w[0].width, w[0].height);
          w[i].save(globalSketchPath + "/AuxiliarFiles/WordGetter/" + str(randomName) + "/Prob " + prob + ".jpg");

          if(this.cnn != null) {
            session.ds.CNNGetImageFromInputs(entries[i]).save("./AuxiliarFiles/WordGetter/" + str(randomName) + "/" + str(i) + ".jpg");
          } else {
            session.ds.GetImageFromInputs(entry, i).save("./AuxiliarFiles/WordGetter/" + str(randomName) + "/" + str(i) + ".jpg");
          }
        }
      }
      
      float meanWordHeight = 0;
      for(int i = 0; i < effectiveProb.length; i++)
        meanWordHeight += (float)im.MeanHeight(wordsImages[wordIndex][i]) / effectiveProb.length;

      // Liste des probabilités pour chaque mots
      // Utile pour la correction
      ArrayList<float[]> wordProb = new ArrayList<float[]>();
      for(int i = 0; i < effectiveProb.length; i++) {
        if(boundingBoxSizes[wordIndex][i] < this.ponctuationThreshold * averageBoundingBoxSize) { //ie c'est un signe de ponctuation, donc pas pris en compte pour le moment
          if(wordProb.size() > 0) {
            wordsEffectiveProb.add(wordProb.toArray(new float[0][]));
            float h = im.MeanHeight(wordsImages[wordIndex][i]);
            String c = (h < 4 * meanWordHeight / 5 ? "'" : (h < meanWordHeight ? "-" : ", "));
            ponctuationsList.add(c);
          }
          wordProb = new ArrayList<float[]>();
        } else {
          wordProb.add(effectiveProb[i]);
        }
      }
      if(wordProb.size() > 0) {
        wordsEffectiveProb.add(wordProb.toArray(new float[0][]));
        ponctuationsList.add(" ");
      }
    }

    // Corrige le texte à partir d'un dictionnaire et des probabilités calculées
    float[][][] wordsEffectiveProbArray = wordsEffectiveProb.toArray(new float[0][][]);
    for(int i = 0; i < wordsEffectiveProbArray.length; i++) {
      //println("EffectiveProb");
      //println(effectiveProb[0]);

      String word;
      if (withCorrection) word = wc.WordAutoCorrection(wordsEffectiveProbArray[i]);
      else word = wc.OLD_WordAutoCorrection(wordsEffectiveProbArray[i]);

      text+=word;
      text+=ponctuationsList.get(i);
    }

    println(wordsEffectiveProbArray.length);
    println(ponctuationsList.size());

    cl.pln("Number of letters average : " + str(numberOfLettersAverage));
    return text;
  }

}
