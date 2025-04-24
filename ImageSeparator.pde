class ImageSeparator {
  final PImage originalImage;
  final int w, h;

  final private int redMask = 0b111111110000000000000000;
  final private int greenMask = 0b1111111100000000;
  final private int blueMask = 0b11111111;

  public ImageSeparator(PImage img) {
    this.originalImage = img;
    w = originalImage.width;
    h = originalImage.height;
  }

  //f Renvoie une liste d'images contenant les lettres de l'image chargée
  // On suppose que le texte est écrit dans la couleur la plus foncée
  // et qu'il est contrasté par rapport à la couleur de fond. Il ne doit
  // y avoir que du texte sur l'image, et écrit en ligne. Ne marche pas pour
  // les textes écrits en italique.
  public ArrayList<PImage> GetAllLettersImages() {
    ArrayList<PVector[]> allCoords = GetAllCoords();
    ArrayList<PImage> allLetters = new ArrayList<PImage>();
    for (PVector[] coords : allCoords) allLetters.add(GetImageLetter(coords));
    return allLetters;
  }

  //f Renvoie une visualisation du découpage de l'image en lettres
  public void SaveSeparationPreview(String path) {
    ArrayList<PVector[]> allCoords = GetAllCoords();
    PGraphics pg = createGraphics(originalImage.width, originalImage.height);
    pg.beginDraw();
    pg.background(255);
    pg.image(originalImage, 0, 0);

    for (PVector[] coords : allCoords) {
      PVector ul = coords[0], br = coords[1];
      pg.stroke(0, 255, 0, 200); pg.line(ul.x, ul.y, br.x, ul.y);
      pg.stroke(255, 0, 0, 200); pg.line(ul.x, br.y, br.x, br.y);
      pg.stroke(0, 0, 255, 200); pg.line(ul.x, ul.y, ul.x, br.y);
      pg.stroke(0,   0, 0, 200); pg.line(br.x, ul.y, br.x, br.y);
    }

    pg.endDraw();
    pg.save(path);
  }

  //f Renvoie la liste des coordonnées des lettres.
  // Voir GetAllLettersImages pour plus d'informations
  private ArrayList<PVector[]> GetAllCoords() {
    PImage img = originalImage.copy();
    img.filter(GRAY);
    img.loadPixels();

    int[][] bwPixels = GetBWPixels(img);
    BinarizePixels(bwPixels);
    ArrayList<Integer> lineLevels = GetLineLevels(bwPixels);

    ArrayList<PVector[]> allCoords = new ArrayList<PVector[]>();
    for (int i = 0; i < lineLevels.size()-1; i++) {
      allCoords.addAll(GetLettersCoords(bwPixels, lineLevels, i));
    }

    return allCoords;
  }

  //f Renvoie les pixels de l'image en niveaux de gris
  private int[][] GetBWPixels(PImage img) {
    int[][] bwPixels = new int[h][w];
    for (int i = 0; i < h; i++) {
      for (int j = 0; j < w; j++) {
        int c = img.pixels[i*w + j];
        int red = (c & redMask) >> 16;
        int green = (c & greenMask) >> 8;
        int blue = c & blueMask;
        int col = (int)(red + green + blue)/3;
        bwPixels[i][j] = col;
      }
    }
    return bwPixels;
  }

  //s Algorithme d'Otsu sur un array 1D
  private int OtsuThreshold(int[] pxls) {
    int[][] pix2D = new int[1][pxls.length];
    for (int i = 0; i < pxls.length; i++) pix2D[0][i] = pxls[i];
    return OtsuThreshold(pix2D);
  }

  //f Trouve le meilleur seuil pour séparer les pixels en 2 catégories
  // à l'aide de l'algorithme d'Otsu : https://en.wikipedia.org/wiki/Otsu%27s_method
  private int OtsuThreshold(int[][] pixelArrays) {
    int imgHeight = pixelArrays.length;
    int imgWidth = pixelArrays[0].length;
    int pixelNumber = imgWidth*imgHeight;
    int[] intensities = new int[256];

    for (int i = 0; i < imgHeight; i++) {
      for (int j = 0; j < imgWidth; j++) {
        intensities[pixelArrays[i][j]]++;
      }
    }

    int bestThreshold = -1;
    double bestVal = -1;
    for (int threshold = 0; threshold < 256; threshold++) {
      double w0 = 0, w1 = 0, mu0 = 0, mu1 = 0;
      for (int i = 0; i < threshold; i++) w0 += intensities[i];
      for (int i = threshold; i < 256; i++) w1 += intensities[i];
      w0 /= pixelNumber;
      w1 /= pixelNumber;

      for (int i = 0; i < threshold; i++) mu0 += i*intensities[i];
      for (int i = threshold; i < 256; i++) mu1 += i*intensities[i];
      mu0 /= w0;
      mu1 /= w1;

      double val = w0 * w1 * Math.pow((mu0 - mu1), 2);
      if (val > bestVal) {
        bestVal = val;
        bestThreshold = threshold;
      }
    }

    return bestThreshold;
  }

  //f Transforme les pixels _pxls_ en 2 catégories : pixels noirs et blancs
  private void BinarizePixels(int[][] pxls) {
    int threshold = OtsuThreshold(pxls);
    for (int i = 0; i < h; i++) {
      for (int j = 0; j < w; j++) {
        if (pxls[i][j] > threshold) pxls[i][j] = 255;
        else pxls[i][j] = 0;
      }
    }
  }

  //f Récupère les ordonnées des lignes de séparation à partir des pixels
  // de l'image en 2 couleurs (0 et 255). Le texte est supposé être en noir (0)
  // et le reste en blanc (255)
  private ArrayList<Integer> GetLineLevels(int[][] bwPixels) {
    ArrayList<Integer> lineSep = new ArrayList<Integer>();
    lineSep.add(0);

    // Moyenne (pondérée) des lignes
    int[] preMeans = new int[h];
    for (int i = 0; i < h; i++) {
      int blacks = 0;
      for (int j = 0; j < w; j++) {
        if (bwPixels[i][j] == 0) blacks++;
      }
      float m = 5*(float)blacks/w;
      preMeans[i] = constrain(floor(map(m, 0, 1, 255, 0)), 0, 255);
    }

    // Moyenne glissante pour lisser
    int[] means = new int[h];
    int pas = 11; // PARAM (impair)
    for (int i = 0; i < h; i++) {
      int somme = 0, compteur = 0;
      for (int k = -pas/2; k <= pas/2; k++) {
        if (constrain(i+k, 0, h-1) == i+k) {
          somme += preMeans[i+k];
          compteur++;
        }
      }
      means[i] = somme/compteur;
    }

    // Échantillonnage des niveaux de gris
    int numCat = 20; // PARAM
    int bSize = 255/numCat;
    for (int i = 0; i < h; i++) {
      int cat = means[i] / bSize;
      means[i] = cat * bSize;
    }

    // Récupère les maximums locaux de couleurs, qui sont les interlignes
    int phase = 0;
    Integer lastFirst0 = null;
    if (means[1] > means[0]) phase = 1;
    else if (means[1] < means[0]) phase = -1;

    for (int i = 0; i < h-1; i++) {
      int state = 0;
      if (means[i+1] > means[i]) state = 1;
      else if (means[i+1] < means[i]) state = -1;

      if (phase == 1 && state == -1) lineSep.add(i);
      if (phase == 0 && state == -1 && lastFirst0 != null) {
        lineSep.add((i+lastFirst0)/2);
        lastFirst0 = null;
      }

      if (phase == 1 && state == 0) lastFirst0 = i;
      phase = state;
    }

    lineSep.add(h-1);
    return lineSep;
  }

  //f Récupère toutes les coordonnées des lettres correspondant à
  // l'indice _lineIndex_ de la liste des lignes de séparations _lineSep_
  private ArrayList<PVector[]> GetLettersCoords(int[][] bwPixels, ArrayList<Integer> lineSep, int lineIndex) {
    ArrayList<PVector[]> result = new ArrayList<PVector[]>();
    int up = lineSep.get(lineIndex);
    int down = lineSep.get(lineIndex+1);
    PVector ul = null, br = null;

    for (int j = 0; j < w; j++) {
      if (DetectLetterColumn(bwPixels, j, up, down)) {
        if (ul == null) ul = new PVector(j, up);
      }
      else {
        if (ul != null) {
          br = new PVector(j, down);
          result.add(new PVector[]{ul, br});
          ul = br = null;
        }
      }
    }
    return result;
  }

  //f Sur une colonne _col_ de la liste des pixels _bwPiwels_ en 2 couleurs,
  // indique si il y a un (ou éventuellement plus) pixel noir compris entre
  // _up_ et _down_
  private boolean DetectLetterColumn(int[][] bwPixels, int col, int up, int down) {
    int compteur = 0;
    for (int i = up; i < down+1; i++) {
      if (bwPixels[i][col] == 0) {
        compteur++;
        if (compteur >= 1) return true; // PARAM
      }
    }
    return false;
  }

  //f Découpe la lettre aux coordonnées _coords_ dans l'image originale
  private PImage GetImageLetter(PVector[] coords) {
    PVector ul = coords[0], br = coords[1];
    int imgW = int(br.x - ul.x);
    int imgH = int(br.y - ul.y);
    return originalImage.get(int(ul.x), int(ul.y), imgW, imgH);
  }
}


// Exemple :

// PImage message = loadImage("img.jpg");
// ImageSeparator is = new ImageSeparator(message);
// ArrayList<PImage> imgs = is.GetAllLettersImages();
// int compteur = 0;
// for (PImage img : imgs) {
//   compteur++;
//   PGraphics pg = createGraphics(img.width, img.height);
//   pg.beginDraw();
//   pg.background(255);
//   pg.image(img, 0, 0);
//   pg.endDraw();
//
//   pg.save("Tests/Image" + compteur + ".png");
// }
