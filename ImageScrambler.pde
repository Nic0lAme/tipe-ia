class ImageManager {
  
  PImage origin;
  boolean isGray = false;
  boolean isBW = false;
  float BWthreshold = 0;
  
  color meanColor;
  
  int index = 0;
  
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
  
  ImageManager Resize(float s) {
    int x = floor(s * this.origin.width);
    int y = floor(s * this.origin.height);
    
    return Resize(x,y);
  }
  
  ImageManager Resize(int x, int y) {
    this.origin.resize(x, y);
    
    return this;
  }
  
  ImageManager Gray() {
    this.origin.filter(GRAY);
    this.isGray = true;
    
    this.meanColor = this.TakeAvgColor();
    
    return this;
  }
  
  ImageManager BlackAndWhite(float threshold) {
    this.origin.filter(THRESHOLD, threshold);
    this.isBW = true;
    this.BWthreshold = threshold;
    
    this.meanColor = this.TakeAvgColor();
    
    return this;
  }
  
  PImage ScrambleImage(boolean save, float move, float blur, float density) {
    
    PGraphics pg = createGraphics(this.origin.width, this.origin.height, P3D);
    
    pg.beginDraw();
    pg.background(this.meanColor);
    
    float zRot = 0.7;
    float xyRot = 0.2;
    float d = 1.3;
    float delta = 0.02;
    float perlin = 6;
    float perlinScale = 1;
    float scaleScale = 0.5;
    
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
    
    
    
    pg.translate(floor(x/2) + d * random(-size * move, size * move), floor(y/2) + d * random(-size * move, size * move));
    
    pg.rotateX(xyRot*(random(PI * move) - PI * move/2));
    pg.rotateY(xyRot*(random(PI * move) - PI * move/2));
    pg.rotateZ(zRot *(random(PI * move) - PI * move/2));
    
    pg.scale(random(1, 1 + scaleScale * move));
    
    pg.translate(-floor(x/2) + d * random(-size * move, size * move), -floor(y/2) + d * random(-size * move, size * move));
    
    
    pg.image(scrambledImage, 0, 0);
    
    if(save) pg.save("./outputedFrame/" + str(millis()) + str(this.index) + str(second()) + str(minute()) + str(hour()) + str(day()) + str(month()) + str(year()) + ".jpg" );
    
    pg.loadPixels();
    scrambledImage = pg.get(0, 0, scrambledImage.width, scrambledImage.height);
    pg.endDraw();
    
    this.index += 1;
    return scrambledImage;
  }
}

/*
void setup() {
  size(200,200,P3D);
  ImageManager img = new ImageManager(loadImage("@ - NicolasMA.jpg"));
  img.Resize(19,21);
  
  background(0);
  //noLoop();
  noLoop();
  
  
  img.Gray();
  for(int i = 0; i < 5000; i++)
    img.ScrambleImage(false, 0.2,0.1,0.05);
}
*/
