class ScrambleVisual extends PApplet {
  final float move = 0.12;
  final float blur = 0.02;
  final float density = 0.1;
  final float perlin = 0.5;
  final float deformation = 0.08;

  PImage baseImg;
  int w, h;
  int numOfCol, numOfLine;
  int mainMultiplier = 1;
  int totalMultiplier = 4;
  String name;

  PImage[] scrambledImages;

  ScrambleVisual(PImage img, int w, int h, int col, int line, String name) {
    super();

    this.baseImg = img;
    this.w = w;
    this.h = h;
    this.numOfCol = col;
    this.numOfLine = line;
    this.name = name;

    PApplet.runSketch(new String[] {this.getClass().getSimpleName() + " | " + this.name}, this);
  }

  void settings() {
    size(this.w * this.numOfCol * this.totalMultiplier, this.h * (this.numOfLine + 1) * this.totalMultiplier + this.mainMultiplier * this.baseImg.height);
    noSmooth();
  }

  void setup() {
    this.scrambledImages = new PImage[this.numOfCol * this.numOfLine];
    for(int k = 0; k < this.numOfCol * this.numOfLine; k++) {
      this.scrambledImages[k] = im.Gray(
        im.Resize(
          im.ScrambleImage(this.baseImg, this.move, this.blur, this.density, this.perlin, this.deformation),
          this.w - 2,
          this.h - 2
          )
        );
    }  
  }

  void draw() {
    background(255);

    fill(0);
    noStroke();
    rect(this.width / 2 - this.baseImg.width * (this.mainMultiplier + 0.5) / 2, this.baseImg.height * 0.25, this.baseImg.width * (this.mainMultiplier+0.5), this.baseImg.height * (this.mainMultiplier+0.5));
    image(this.baseImg, this.width / 2 - this.baseImg.width * this.mainMultiplier / 2, this.baseImg.height * this.mainMultiplier / 2, this.baseImg.width * this.mainMultiplier, this.baseImg.height * this.mainMultiplier);

    rect(0, (this.mainMultiplier + 1) * this.baseImg.height, this.width, this.height);
    for(int i = 0; i < this.numOfCol; i++)
      for(int j = 0; j < this.numOfLine;j++)
        image(this.scrambledImages[i * this.numOfLine + j], i * this.w * this.totalMultiplier + 1, (j + 1) * this.h * this.totalMultiplier + this.baseImg.height * this.mainMultiplier, this.w * this.totalMultiplier, this.h * this.totalMultiplier);

    if(this.frameCount == 1) {
      this.saveFrame(globalSketchPath + "/Visuals/" + this.name + ".jpg");
    }
  }
}

class WholeTextTestVisual extends PApplet {
  int numOfChar;
  String fontName;
  int fontSize;
  int w; int h;
  int marge;

  int maxCharPerLine;

  PFont font;

  WholeTextTestVisual(int numOfChar, String fontName, int fontSize) {
    super();

    this.numOfChar = numOfChar;

    this.fontName = fontName;
    this.fontSize = fontSize;

    this.marge = 3 * this.fontSize;
    this.w = 800;

    this.maxCharPerLine = round(this.w / this.fontSize * 1.2);
    this.h = this.fontSize * 2 * (this.numOfChar / maxCharPerLine + 2);

    PApplet.runSketch(new String[] {this.getClass().getSimpleName() + " | " + this.fontName + " | " + str(this.numOfChar)}, this);
  }

  void settings() {
    size(this.w + 2 * this.marge, this.h + 2 * this.marge);
  }

  void setup() {
    this.font = createFont(this.fontName, this.fontSize);
  }

  void draw() {
    background(255);

    ArrayList<int[]> wordList = new ArrayList<>();
    int numOfCharInList = 0;
    while(numOfCharInList < this.numOfChar) {
      int[] newWord = wc.words[int(random(wc.words.length))];
      wordList.add(newWord);
      numOfCharInList += newWord.length;
    }

    int wordIndex = 0;
    int lineIndex = 0;
    while(wordIndex < wordList.size()) {
      int charCounter = 0;

      String line = "";
      while(charCounter < this.maxCharPerLine && wordIndex < wordList.size()) {
        int[] word = wordList.get(wordIndex);
        charCounter += word.length;

        line += wc.IntArrayToString(word);
        line += " ";

        wordIndex++;
      }

      textFont(this.font);
      fill(0);
      text(line, this.marge, this.marge + lineIndex * 2 * this.fontSize);

      lineIndex++;
    }

    ImageSeparator is = new ImageSeparator(this.get());
    is.SaveSeparationPreview("./AuxiliarFiles/TEST1.jpg", true, true);
    String text = ir.Read(this.get());
    println(text);

    delay(30000);
  }
}
