class ImageSeparator {
  final PImage originalImage;
  final int w, h;

  final private int redMask = 0b111111110000000000000000;
  final private int greenMask = 0b1111111100000000;
  final private int blueMask = 0b11111111;

  final private int lineThreshold = 5;

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
  // Note : L'image doit être bien orientée (voir GetRotatedImage)
  public PImage[][] GetWordsImages() {
    ArrayList<PVector[][]> allCoords = GetAllCoords();
    ArrayList<PImage[]> allLetters = new ArrayList<PImage[]>();
    for (PVector[][] word : allCoords) {
      PImage[] letterImgs = new PImage[word.length];
      for (int i = 0; i < word.length; i++) {
        letterImgs[i] = GetImageLetter(word[i]);
      }
      allLetters.add(letterImgs);
    }
    return allLetters.toArray(new PImage[][]{});
  }

  //f Liste des lettres (pas séparées par mots)
  public PImage[] GetLettersImages() {
    ArrayList<PVector[][]> allCoords = GetAllCoords();
    ArrayList<PImage> letters = new ArrayList<PImage>();

    for (PVector[][] word : allCoords) {
      for (int i = 0; i < word.length; i++) letters.add(GetImageLetter(word[i]));
    }

    return letters.toArray(new PImage[]{});
  }

  public void SaveSeparationLines(String path) {
    PImage img = originalImage.copy();
    img.filter(GRAY);
    img.loadPixels();

    int[][] bwPixels = GetBWPixels(img);
    bwPixels = BinarizePixels(bwPixels);
    ArrayList<Integer> lineLevels = GetLineLevels(bwPixels);

    PGraphics pg = createGraphics(originalImage.width, originalImage.height);
    pg.beginDraw();
    pg.background(255);
    pg.image(originalImage, 0, 0);
    for (Integer l : lineLevels) {
      pg.stroke(255, 0, 0);
      pg.line(0, l, originalImage.width, l);
    }
    pg.endDraw();
    pg.save(path);
  }

  //f Renvoie une visualisation du découpage de l'image en lettres
  public void SaveSeparationPreview(String path, boolean withWords, boolean withLetters) {
    ArrayList<PVector[][]> allCoords = GetAllCoords();
    PGraphics pg = createGraphics(originalImage.width, originalImage.height);
    pg.beginDraw();
    pg.background(255);
    pg.image(originalImage, 0, 0);

    for (PVector[][] word : allCoords) {

      if (withLetters) {
        for (PVector[] coords : word) {
          PVector ul = coords[0], br = coords[1];
          pg.stroke(10, 50, 240, 255); pg.line(ul.x, ul.y, br.x, ul.y);
          pg.stroke(10, 50, 240, 255); pg.line(ul.x, br.y, br.x, br.y);
          pg.stroke(10, 50, 240, 255); pg.line(ul.x, ul.y, ul.x, br.y);
          pg.stroke(10, 50, 240, 255); pg.line(br.x, ul.y, br.x, br.y);
        }
      }

      if (withWords) {
        PVector wul = word[0][0], wbr = word[word.length-1][1];
        pg.stroke(240, 180, 20); pg.line(wul.x, wul.y, wbr.x, wul.y);
        pg.stroke(20, 240, 180); pg.line(wul.x, wbr.y, wbr.x, wbr.y);
        pg.stroke(180, 20, 240); pg.line(wul.x, wul.y, wul.x, wbr.y);
        pg.stroke(120, 120, 180); pg.line(wbr.x, wul.y, wbr.x, wbr.y);
      }
    }

    pg.endDraw();
    pg.save(path);
  }

  //f Renvoie la liste des coordonnées des lettres.
  // Voir GetWordsImages pour plus d'informations
  private ArrayList<PVector[][]> GetAllCoords() {
    PImage img = originalImage.copy();
    img.filter(GRAY);
    img.loadPixels();

    int[][] bwPixels = GetBWPixels(img);
    bwPixels = BinarizePixels(bwPixels);
    ArrayList<Integer> lineLevels = GetLineLevels(bwPixels);

    ArrayList<PVector[]> allWordsCoords = new ArrayList<PVector[]>();
    for (int i = 0; i < lineLevels.size()-1; i++) {
      ArrayList<Integer> colLevels = SplitWords(bwPixels, lineLevels, i);
      PVector ul = new PVector(0, lineLevels.get(i)), br = new PVector(0, lineLevels.get(i+1));
      for (int j = 0; j < colLevels.size()-1; j++) {
        ul.x = colLevels.get(j);
        br.x = colLevels.get(j+1);
        allWordsCoords.add(new PVector[]{ul.copy(), br.copy()});
      }
    }

    return CoordsFromWords(bwPixels, allWordsCoords);
  }

  //f Trouve le meilleur angle possible pour orienter le texte correctement.
  // L'amplitude de recherche est _amplitude_ (en degrés), et le nombre de pas est _nbPas_
  // C'est assez lent, et il y a de quoi optimiser si c'est dérangeant (et c'est facile à paralléliser)
  private PImage GetRotatedImageStep1(PImage ori, float amplitude, int nbPas) {
    PImage img = ori.copy();
    img.filter(GRAY);

    float maxVariance = 0;
    PImage bestImage = null;
    for (float k = 0; k < nbPas; k++) {
      float angle = (k*(2*amplitude)/(nbPas-1)) - amplitude;
      int[][] preRotatedPixels = RotatedPixels(img, angle);
      int[][] rotatedPixels = BinarizePixels(preRotatedPixels);
      int size = rotatedPixels.length;

      int[] means = GetLineMeans(rotatedPixels);

      float mean = 0, variance = 0;
      for (int i = 0; i < means.length; i++) mean += (float)means[i]/means.length;
      for (int i = 0; i < means.length; i++) variance += (float)Math.pow(means[i] - mean, 2)/means.length;

      if (variance > maxVariance) {
        maxVariance = variance;
        bestImage = PixelsToImage(preRotatedPixels);
      }
    }

    return bestImage;
  }

  //f Trouve le meilleur angle possible pour orienter le texte correctement,
  // avec 2 tours de GetRotatedImageStep1
  // L'amplitude maximale est _maxAmpl_, et la précision est _nbPasLast_ pour
  // le dernier tour, et _nbPas_ pour le reste. Le nombre de tour est _nbTour_
  public PImage GetRotatedImage(int nbTour, float maxAmpl, int nbPas, int nbPasLast) {
    PImage img = originalImage.copy();
    float nextAmpl = maxAmpl;

    for (int i = 0; i < nbTour-1; i++) {
      img = GetRotatedImageStep1(img, nextAmpl, nbPas);
      nextAmpl = (nextAmpl/nbPas) + 0.314159; // un peu de rab
    }
    return GetRotatedImageStep1(img, nextAmpl, nbPasLast);
  }

  //f Renvoie l'image construite avec les pixels _pxls_
  private PImage PixelsToImage(int[][] pxls) {
    PImage result = createImage(pxls[0].length, pxls.length, RGB);
    result.loadPixels();
    for (int i = 0; i < pxls[0].length; i++) {
      for (int j = 0; j < pxls.length; j++) {
        result.pixels[j*pxls[0].length + i] = color(pxls[i][j]);
      }
    }
    result.updatePixels();
    return result;
  }

  //f Renvoie les pixels de l'image _img_ tournée de _angle
  public int[][] RotatedPixels(PImage img, float angle) {
    int size = floor(sqrt((float)Math.pow(img.width, 2) + (float)Math.pow(img.height, 2)));
    PGraphics pg = createGraphics(size, size);
    pg.beginDraw();
    pg.background(255);
    pg.push();
    pg.translate(pg.width/2, pg.height/2);
    pg.rotate(radians(angle));
    pg.imageMode(CENTER);
    pg.image(img, 0, 0);
    pg.pop();
    pg.endDraw();

    int[][] rotatedPixels = new int[pg.width][pg.height];
    for (int i = 0; i < pg.height; i++) {
      for (int j = 0; j < pg.width; j++) rotatedPixels[i][j] = ToGray(pg.get(i, j));
    }

    return rotatedPixels;
  }

  //f Renvoie le niveau de gris correspondant à la couleur _c_
  private int ToGray(int c) {
    int red = (c & redMask) >> 16;
    int green = (c & greenMask) >> 8;
    int blue = c & blueMask;
    return (int)(red + green + blue)/3;
  }

  //f Renvoie les pixels de l'image en niveaux de gris
  private int[][] GetBWPixels(PImage img) {
    int[][] bwPixels = new int[img.height][img.width];
    for (int i = 0; i < img.height; i++) {
      for (int j = 0; j < img.width; j++) {
        int c = img.pixels[i*img.width + j];
        bwPixels[i][j] = ToGray(c);
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
    float bestVal = -1;
    for (int threshold = 0; threshold < 256; threshold++) {
      float w0 = 0, w1 = 0, mu0 = 0, mu1 = 0;
      for (int i = 0; i < threshold; i++) w0 += intensities[i];
      for (int i = threshold; i < 256; i++) w1 += intensities[i];
      w0 /= pixelNumber;
      w1 /= pixelNumber;

      for (int i = 0; i < threshold; i++) mu0 += i*intensities[i];
      for (int i = threshold; i < 256; i++) mu1 += i*intensities[i];
      mu0 /= w0;
      mu1 /= w1;

      float val = w0 * w1 * pow((mu0 - mu1), 2);
      if (val > bestVal) {
        bestVal = val;
        bestThreshold = threshold;
      }
    }

    return bestThreshold;
  }

  //f Transforme les pixels _pxls_ en 2 catégories : pixels noirs et blancs
  private int[][] BinarizePixels(int[][] pxls, int frac) {
    int[][] result = new int[pxls.length][pxls[0].length];
    int threshold = OtsuThreshold(pxls) / frac;
    for (int i = 0; i < pxls.length; i++) {
      for (int j = 0; j < pxls[0].length; j++) {
        if (pxls[i][j] > threshold) result[i][j] = 255;
        else result[i][j] = 0;
      }
    }
    return result;
  }

  private int[][] BinarizePixels(int[][] pxls) {
    return BinarizePixels(pxls, 1);
  }

  //f Renvoie une moyenne pondérée des lignes de _bwPiwels_ (2 couleurs)
  // En fait c'est la variance
  private int[] GetLineMeans(int[][] bwPixels) {
    // int[] means = new int[bwPixels.length];
    // for (int i = 0; i < bwPixels.length; i++) {
    //   int blacks = 0;
    //   for (int j = 0; j < bwPixels[0].length; j++) {
    //     if (bwPixels[i][j] == 0) blacks++;
    //   }
    //   float m = 5*(float)blacks/bwPixels[0].length; // :)
    //   means[i] = constrain(floor(map(m, 0, 1, 255, 0)), 0, 255);
    // }
    // return means;

    int[] means = new int[bwPixels.length];
    for (int i = 0; i < bwPixels.length; i++) {
      float moy = 0;
      for (int j = 0; j < bwPixels[i].length; j++) moy += bwPixels[i][j];
      moy /= bwPixels[i].length;

      float variance = 0;
      for (int j = 0; j < bwPixels[i].length; j++) variance += Math.pow(bwPixels[i][j] - moy, 2);
      means[i] = 255 - int(variance/bwPixels[i].length);
    }
    return means;
  }

  //f Récupère les ordonnées des lignes de séparation à partir des pixels
  // de l'image en 2 couleurs (0 et 255). Le texte est supposé être en noir (0)
  // et le reste en blanc (255)
  private ArrayList<Integer> GetLineLevels(int[][] bwPixels) {
    ArrayList<Integer> lineSep = new ArrayList<Integer>();

    // Moyenne (pondérée) des lignes
    int[] preMeans = GetLineMeans(bwPixels);

    lineSep.addAll(ProcessMean(preMeans, floor(0.01*preMeans.length), 20));
    return lineSep;
  }

  // Note: pas doit être impair !
  private ArrayList<Integer> ProcessMean(int[] preMeans, int pas, int numCat) {
    ArrayList<Integer> lineSep = new ArrayList<Integer>();
    int s = preMeans.length;

    // Moyenne glissante pour lisser
    int[] means = new int[s];
    for (int i = 0; i < s; i++) {
      int somme = 0, compteur = 0;
      for (int k = -pas/2; k <= pas/2; k++) {
        if (constrain(i+k, 0, s-1) == i+k) {
          somme += preMeans[i+k];
          compteur++;
        }
      }
      means[i] = somme/compteur;
    }

    // Échantillonnage des niveaux de gris
    int bSize = 255/numCat;
    for (int i = 0; i < s; i++) {
      int cat = means[i] / bSize;
      means[i] = cat * bSize;
    }

    // Récupère les maximums locaux de couleurs, qui sont les interlignes
    lineSep.add(0);
    int phase = 0;
    Integer lastFirst0 = null;
    if (means[1] > means[0]) phase = 1;
    else if (means[1] < means[0]) phase = -1;

    for (int i = 0; i < s-1; i++) {
      int state = 0;
      if (means[i+1] > means[i]) state = 1;
      else if (means[i+1] < means[i]) state = -1;

      if (phase == 1 && state == -1) {
        if (i - lineSep.get(lineSep.size()-1) > lineThreshold) lineSep.add(i);
      }
      if (phase == 0 && state == -1 && lastFirst0 != null) {
        int c = (i+lastFirst0)/2;
        if (c - lineSep.get(lineSep.size()-1) > lineThreshold) lineSep.add(c);
        lastFirst0 = null;
      }

      if (phase == 1 && state == 0) lastFirst0 = i;
      phase = state;
    }

    lineSep.add(s-1);
    return lineSep;
  }

  // AMÉLIORABLE C'EST BIEN SI C'EST POSSIBLE QUE
  //f Récupère toutes les coordonnées des colonnes des mots correspondant à
  // l'indice _lineIndex_ de la liste des lignes de séparations _lineSep_
  private ArrayList<Integer> SplitWords(int[][] bwPixels, ArrayList<Integer> lineSep, int lineIndex) {
    int up = lineSep.get(lineIndex);
    int down = lineSep.get(lineIndex+1);
    int size = down - up + 1;

    int[] means = new int[bwPixels[0].length];
    for (int j = 0; j < bwPixels[0].length; j++) {
      int blacks = 0;
      for (int i = up; i < down; i++) {
        if (bwPixels[i][j] == 0) blacks++;
      }
      float m = 5*(float)blacks/size;
      means[j] = constrain(floor(map(m, 0, 1, 255, 0)), 0, 255);
    }

    ArrayList<Integer> result = ProcessMean(means, 25, 2);
    ArrayList<Integer> corrected = new ArrayList<Integer>();
    for (Integer k : result) {
      if (!HasBlackAround(bwPixels, k, up, down, 3)) corrected.add(k);
    }

    return corrected;
  }

  private boolean HasBlackAround(int[][] bwPixels, int k, int up, int down, int s) {
    int start = max(0, k-s);
    int end = min(k+s, bwPixels[0].length-1);
    for (int j = start; j < end; j++) {
      for (int i = up; i < down; i++) {
        if (bwPixels[i][j] == 0) return true;
      }
    }
    return false;
  }

  private ArrayList<PVector[][]> CoordsFromWords(int[][] bwPixels, ArrayList<PVector[]> allWordsCoords) {
    ArrayList<PVector[][]> allCoords = new ArrayList<PVector[][]>();

    for (PVector[] v : allWordsCoords) {
      PVector ul = v[0], br = v[1];
      allCoords.add(GetLettersInWord(bwPixels, ul, br));
    }

    return allCoords;
  }

  private PVector[][] GetLettersInWord(int[][] bwPixels, PVector wordUl, PVector wordBr) {
    ArrayList<PVector[]> result = new ArrayList<PVector[]>();

    int up = int(wordUl.y);
    int down = int(wordBr.y);
    PVector ul = null, br = null;

    for (int j = int(wordUl.x); j < int(wordBr.x); j++) {
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
    return result.toArray(new PVector[][]{});
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
// ArrayList<PImage> imgs = is.GetWordsImages();
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
