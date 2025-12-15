
///////////////////////////////////////////////////

// DraftingArea

/*
Zone de test d'images élémentaires pour tester le brouillage d'image.
Permet de visualiser des couples d'images (image originale / image brouillée) et de naviguer entre elles.
*/

///////////////////////////////////////////////////


// Extension du PApplet de Processing => création d'une nouvelle fenêtre indépendante
class DraftingArea extends PApplet {

  private ArrayList<PImage[]> history = new ArrayList<PImage[]>();
  private int mult = 20;
  private int w = 28;
  private int h = 28;

  private int currentIndex = -1;

  LetterDataset ld = new LetterDataset(5*w, 5*h);

  //c Constructeur et création de la fenêtre
  public DraftingArea() {
    super();
    PApplet.runSketch(new String[]{this.getClass().getName()}, this);
  }

  //f Configuration de la fenêtre (taille)
  public void settings() {
    size(w*mult * 2 + mult, h*mult, P3D);
  }

  //f Initialisation de la fenêtre (titre)
  public void setup() {
    windowTitle("DraftingArea");
  }

  //f Boucle de dessin
  public void draw() {
    if (currentIndex == -1) UpdateImages();
    imageMode(CENTER);
    image(history.get(currentIndex)[0], w*mult/2, height/2, mult * w, mult * h);
    image(history.get(currentIndex)[1], width - w*mult/2, height/2, mult * w, mult * h);
    // text()
  }

  //f Met à jour les images affichées en générant un nouveau couple d'images (originale / brouillée)
  private void UpdateImages() {
    PImage imgs[] = ld.GetRandomCouple(mult*w, mult*h, 0.12, 0.02, 0.2, 0.2, 0.05);
    history.add(imgs);
    currentIndex = history.size()-1;
  }

  //f Permet de naviguer entre les images avec les flèches gauche/droite et de générer une nouvelle image avec la barre espace
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
