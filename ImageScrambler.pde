class ImageManager {
  
  PImage origin;
  boolean isGray = false;
  boolean isBW = false;
  float BWthreshold = 0;
  
  color meanColor;
  
  ImageManager(PImage _o) {
    origin = _o;
    this.origin.filter(OPAQUE); // Evite d'avoir des trucs relous
    this.meanColor = TakeAvgColor();
  }
  
  color TakeAvgColor() {
    float sz = 2 * (this.origin.width + this.origin.height) - 4;
    
    float r = 0;
    float g = 0;
    float b = 0;
    
    color c;
    
    for (int i = 0; i < this.origin.width; i++) {
      c = this.origin.get(i,0);
      r += red(c) / sz;
      g += green(c) / sz;
      b += blue(c) / sz;
      
      c = this.origin.get(i,this.origin.height - 1);
      r += red(c) / sz;
      g += green(c) / sz;
      b += blue(c) / sz;
      
    }
      
    for (int j = 1; j < this.origin.height - 1; j++) {
      c = this.origin.get(0, j);
      r += red(c) / sz;
      g += green(c) / sz;
      b += blue(c) / sz;
      
      c = this.origin.get(this.origin.width - 1, j);
      r += red(c) / sz;
      g += green(c) / sz;
      b += blue(c) / sz;
    }
    
    return color(r,g,b);
  }
  
  void Resize(float s) {
    int x = floor(s * this.origin.width);
    int y = floor(s * this.origin.height);
    
    Resize(x,y);
  }
  
  void Resize(int x, int y) {
    this.origin.resize(x, y);
  }
  
  void Gray() {
    this.origin.filter(GRAY);
    this.isGray = true;
    
    this.meanColor = this.TakeAvgColor();
  }
  
  void BlackAndWhite(float threshold) {
    this.origin.filter(THRESHOLD, threshold);
    this.isBW = true;
    this.BWthreshold = threshold;
    
    this.meanColor = this.TakeAvgColor();
  }
  
  PImage ScrambleImage(float move, float blur, float density) {
    
    background(this.meanColor);
    
    float zRot = 0.7;
    float xyRot = 0.2;
    float d = 1.418962;
    float delta = 0.02;
    float perlin = 10;
    float perlinScale = 1;
    float scaleScale = 0.7;
    
    PImage scrambledImage = this.origin.copy();
    int x = scrambledImage.width;
    int y = scrambledImage.height;
    float size = log(x*y);
    
    scrambledImage.filter(BLUR, 0.3 * random(blur * size));
    
    noiseSeed((long)random(0,100));
    for (int i = 0; i < x; i++) {
      for (int j = 0; j < y; j++) {
        float pI = perlin * noise((float)i / x * perlinScale, (float)j / y * perlinScale) - perlin / 2;
        color init = scrambledImage.get(i,j);
        scrambledImage.set(i, j, color(100 * pI + red(init),pI + green(init), pI+blue(init)));
        
        if (random(1) > density) continue;
        
        scrambledImage.set(i, j, floor(random(1 - delta, 1 + delta) * scrambledImage.get(i,j)));
      }
    }
    
    if (isBW) scrambledImage.filter(THRESHOLD, this.BWthreshold);
    if (isGray) scrambledImage.filter(GRAY);
    
    
    
    translate(floor(x/2) + d * random(-size * move, size * move), floor(y/2) + d * random(-size * move, size * move));
    
    rotateX(xyRot*(random(PI * move) - PI * move/2));
    rotateY(xyRot*(random(PI * move) - PI * move/2));
    rotateZ(zRot *(random(PI * move) - PI * move/2));
    
    scale(random(1, 1 + scaleScale * move));
    
    translate(-floor(x/2) + d * random(-size * move, size * move), -floor(y/2) + d * random(-size * move, size * move));
    
    
    image(scrambledImage, 0, 0);
    
   return scrambledImage;
  }
}

/*
void setup() {
  size(200,200,P3D);
  background(0);
  //noLoop();
  frameRate(10);
}

void draw() {
  background(0);
  ImageManager img = new ImageManager(loadImage("Text1TestTIPE.jpg"));
  img.Resize(200,200);
  img.Gray();
  img.ScrambleImage(0.2,0.1,0.05);
}
*/
