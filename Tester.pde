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

  private final boolean withCorrection = true;

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

  public void RunOneTest() {
    // Génère un texte
    GenerateText();

    // Déchiffre le texte
    ImageReader ir;
    if (isNN) ir = new ImageReader(nn);
    else ir = new ImageReader(cnn);

    String result = ir.Read(lastGeneratedImage, withCorrection);

    // Évalue la performance
    int distance = wc.LevenshteinDistance(lastGeneratedText, result);
    println(distance);
  }

  public PImage GenerateText() {
    PFont font = createFont("Georgia", fontSize);
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
      text += IntArrayToString(wordList.get(i));
    }
    lastGeneratedImage = pg.get();
    lastGeneratedText = text;
  }
}
