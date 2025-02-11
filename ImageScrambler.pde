class ImageManager {
  
  PImage origin;
  
  ImageManager(PImage _o) {
    origin = _o;
    this.filter(OPAQUE); // Evite d'avoir des trucs relous
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
  }
  
  void BlackAndWhite(float threshold) {
    this.origin.filter(THRESHOLD, threshold);
  }
  
  PImage ScrambleImage(float move, float blur) {
    PImage scrambledImage = this.origin.copy();
    int x = scrambledImage.width;
    int y = scrambledImage.height;
    float size = sqrt(x*y);
    
    scrambledImage.filter(BLUR, blur * size);
    
    image(scrambledImage, 0, 0);
    translate(floor(x/2), floor(y/2));
    rotate(random(PI * move) - PI * move/2);
    translate(-floor(x/2), -floor(y/2));
    
    return scrambledImage;
  }
}
