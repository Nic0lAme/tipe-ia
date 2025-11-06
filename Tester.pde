class Tester {
  private final NeuralNetwork nn;
  private final CNN cnn;
  private final boolean isNN;

  private final float textSize = 500;
  private final float fontSize = 50;
  private final float maxCharPerLine = 75;
  private final int w = round((fontSize * maxCharPerLine) / 1.2);
  private final int h = round(fontSize * 2 * (textSize / maxCharPerLine + 2));
  private final float marge = 3 * fontSize;

  private PImage lastGeneratedImage;
  private String lastGeneratedText;

  public Tester(NeuralNetwork nn) {
    this.nn = nn;
    this.cnn = null;
    isNN = true;
  }

  public Tester(CNN cnn) {
    this. nn = null;
    this.cnn = cnn;
    isNN = false;
  }

  public int RunOneTest(boolean withCorrection) {
    // Génère un texte
    GenerateText();

    int initTime = millis();

    // Déchiffre le texte
    ImageReader ir;
    if (isNN) ir = new ImageReader(nn);
    else ir = new ImageReader(cnn);

    String result = ir.Read(lastGeneratedImage, withCorrection);

    int endTime = millis();
    //println("Time :", endTime - initTime);

    // Évalue la performance
    int distance = wc.LevenshteinDistance(lastGeneratedText, result);
    return new Results(distance, endTime - initTime);
  }

  public void RunNTest(int n, boolean withCorrection) {
    if(n==0) return {cl.pln(this, "RunNTest", "n == 0"); Exception e = new Exception(); e.printStackTrace(); return -1;}
    float totalDistance = 0; float totalTime = 0;

    for(int i = 0; i < n; i++) {
      float effectiveNumOfChar = GenerateText();

      int initTime = millis();

      ImageReader ir;
      if (isNN) ir = new ImageReader(nn);
      else ir = new ImageReader(cnn);

      String result = ir.Read(lastGeneratedImage, withCorrection);

      totalTime += millis() - initTime;

      totalDistance += 1 - wc.LevenshteinDistance(lastGeneratedText, result) / effectiveNumOfChar;
    }

    return new Results(totalDistance / n, totalTime / n);
  }

  public void GenerateText() {
    PFont font = cs.GetRandomTrainingFont(fontSize);
    PGraphics pg = createGraphics(w, h);
    pg.beginDraw();
    pg.background(255);
    pg.fill(0);
    pg.textFont(font);

    ArrayList<int[]> wordList = new ArrayList<>();
    int numOfCharInList = 0;
    while(numOfCharInList < textSize) {
      int[] newWord = wc.words[int(random(wc.words.length))];
      wordList.add(newWord);
      numOfCharInList += newWord.length;
    }

    int wordIndex = 0;
    int lineIndex = 0;
    while(wordIndex < wordList.size()) {
      int charCounter = 0;

      String line = "";
      while(charCounter < maxCharPerLine && wordIndex < wordList.size()) {
        int[] word = wordList.get(wordIndex);
        charCounter += word.length;

        line += wc.IntArrayToString(word);
        line += " ";

        wordIndex++;
      }

      pg.text(line, marge, marge + lineIndex * 2 * fontSize);
      lineIndex++;
    }

    // pg.save("./test.png");
    String text = "";
    for (int i = 0; i < wordList.size(); i++) {
      if (i != 0) text += " ";
      text += wc.IntArrayToString(wordList.get(i));
    }
    lastGeneratedImage = pg.get();
    lastGeneratedText = text;

    return numOfCharInList;
  }
}


class Results {

  float distance;
  float time;

  Results(float d, float t) {
    this.distance = d;
    this.time = t;
  }

  @Override
  public String toString() {
    return "Distance : " + String.format("%7.2f", this.distance) + " | Time : " + String.format("%7.2f", this.time) ;
  }
}