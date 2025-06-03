class ScrambleVisual extends PApplet {
  final float move = 0.12;
  final float blur = 0.02;
  final float density = 0.1;
  final float perlin = 0.5;
  final float deformation = 0.08;
  
  PImage baseImg;
  int w, h;
  int numOfCol, numOfLine;
  int mainMultiplier = 2;
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
    size(this.w * this.numOfCol, this.h * (this.numOfLine + mainMultiplier + 1));
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
    rect(this.width / 2 - this.w * (this.mainMultiplier + 0.5) / 2, this.h * 0.25, this.w * (this.mainMultiplier+0.5), this.h * (this.mainMultiplier+0.5));
    image(this.baseImg, this.width / 2 - this.w * this.mainMultiplier / 2, this.h / 2, this.w * this.mainMultiplier, this.h * this.mainMultiplier);
    
    rect(0, (this.mainMultiplier + 1) * this.h, this.width, this.height);
    for(int i = 0; i < this.numOfCol; i++)
      for(int j = 0; j < this.numOfLine;j++)
        image(this.scrambledImages[i * this.numOfLine + j], i * this.w + 1, (j + this.mainMultiplier + 1) * this.h + 1);
        
    if(this.frameCount == 1) {
      this.saveFrame(globalSketchPath + "/Visuals/" + this.name + ".jpg");
    }
  }
}
