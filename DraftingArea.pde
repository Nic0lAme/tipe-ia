class DraftingArea extends PApplet {

  private ArrayList<PImage[]> history = new ArrayList<PImage[]>();
  private int mult = 20;
  private int w = 19;
  private int h = 21;

  private int currentIndex = -1;

  LetterDataset ld = new LetterDataset(5*w, 5*h);

  public DraftingArea() {
    super();
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  public void settings() {
    size(w*mult * 2 + mult, h*mult, P3D);
  }

  public void setup() {
    windowTitle("DraftingArea");
  }

  public void draw() {
    if (currentIndex == -1) UpdateImages();
    imageMode(CENTER);
    image(history.get(currentIndex)[0], w*mult/2, height/2, mult * w, mult * h);
    image(history.get(currentIndex)[1], width - w*mult/2, height/2, mult * w, mult * h);
    // text()
  }

  private void UpdateImages() {
    PImage imgs[] = ld.GetRandomCouple(mult*w, mult*h, 0.12, 0.02, 0.2, 0.2, 0.05);
    history.add(imgs);
    currentIndex = history.size()-1;
  }

  public void keyPressed() {
    if (key == ' ') {
      UpdateImages();
    }
    else if (keyCode == LEFT) {
      currentIndex = constrain(currentIndex-1, 0, history.size()-1);
    }
    else if (keyCode == RIGHT) {
      currentIndex = constrain(currentIndex+1, 0, history.size()-1);
    }
  }
}
