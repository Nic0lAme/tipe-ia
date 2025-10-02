class ImageReader {
  CNN cnn;
  NeuralNetwork nn;
  boolean saveWordImage = true;

  float ponctuationThreshold = 0.25;

  ImageReader(CNN cnn) {
    this.cnn = cnn;
  }

  ImageReader(NeuralNetwork nn) {
    this.nn = nn;
  }

  public String Read(PImage img) {
    return Read(img, true);
  }

  public String Read(PImage img, boolean withCorrection) {
    ImageSeparator is = new ImageSeparator(img);
    PImage[][] wordsImages = new PImage[0][];
    wordsImages = is.GetWordsImages();

    /*
    float[] etalonnedProp = new float[26];
    if(this.cnn != null) etalonnedProp = cs.GetEtalonnedProp(this.cnn);
    else Arrays.fill(etalonnedProp, 1);

    println(etalonnedProp);
    */

    float numberOfLettersAverage = 0;

    String text = "";
    ArrayList<float[][]> wordsEffectiveProb = new ArrayList<float[][]>();

    ArrayList<Integer> boundingBoxSizesList = new ArrayList<>();

    int[][] boundingBoxSizes = new int[wordsImages.length][];
    float averageBoundingBoxSize = 0;
    for(int i = 0; i < wordsImages.length; i++) {
      boundingBoxSizes[i] = new int[wordsImages[i].length];
      for(int j = 0; j < wordsImages[i].length; j++) {
        int[] boundingBox = im.GetBoundingBox(wordsImages[i][j]);
        boundingBoxSizes[i][j] = (boundingBox[2] - boundingBox[0])*(boundingBox[3] - boundingBox[1]);
        boundingBoxSizesList.add(boundingBoxSizes[i][j]);
        averageBoundingBoxSize += (float)boundingBoxSizes[i][j] / wordsImages[i].length / wordsImages.length;

        //wordsImages[i][j].save("./AuxiliarFiles/BoundingBoxTest/" + str(boundingBoxSizes[i][j]) + " " + str(random(1)) + ".jpg");
      }
    }

    println("Average bounding box :", averageBoundingBoxSize);

    SaveIntListAsCSV(boundingBoxSizesList.stream().mapToInt(Integer::intValue).toArray(), "./AuxiliarFiles/BoundingBoxSizeGraph.csv");

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

      if(saveWordImage) {
        float randomName = random(1000);
        for(int i = 0; i < w.length; i++) {
          //SAUVEGARDE DU MOT DANS UN FICHIER A PART
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

      ArrayList<float[]> wordProb = new ArrayList<float[]>();
      for(int i = 0; i < effectiveProb.length; i++) {
        if(boundingBoxSizes[wordIndex][i] < this.ponctuationThreshold * averageBoundingBoxSize) { //ie c'est un signe de ponctuation, donc pas pris en compte pour le moment
          if(wordProb.size() > 0) {
            wordsEffectiveProb.add(wordProb.toArray(new float[0][]));
            float h = im.MeanHeight(wordsImages[wordIndex][i]);
            String c = (h < 2 * wordsImages[wordIndex][i].height / 5 ? "'" : (h < 3 * wordsImages[wordIndex][i].height / 5 ? "-" : ", "));
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
