# DOCUMENTATION

<details>
<summary>

**GraphApplet**

</summary>

- 
>
- _public GraphApplet()_


- ***

	<details>
	<summary>AddValue</summary>

	- >Ajoute le point _y_ au graphique  
	- _public void AddValue(double y)_

	</details>

- ***

	<details>
	<summary>AddValue</summary>

	- >Ajoute le point _x_,_y_ au graphique  
	- _public void AddValue(double x, double y)_

	</details>

- ***

	<details>
	<summary>CenterFrame</summary>

	- >Centre la frame _frame_ dans l'écran  
	- _private void CenterFrame(JFrame frame)_

	</details>

- ***

	<details>
	<summary>ClearGraph</summary>

	- >Nettoie le graphique  
	- _public void ClearGraph() _

	</details>

- ***

	<details>
	<summary>ExportNN</summary>

	- >Permet d'exporter le réseau de neurone actif  
	A FAIRE : Devra au final exporter toute la session  
	- _private void ExportNN()_

	</details>

- ***

	<details>
	<summary>ImportNN</summary>

	- >Importe un réseau de neurone  
	A FAIRE : devra au final importer une session entière  
	- _private void ImportNN()_

	</details>

- ***

	<details>
	<summary>Init</summary>

	- >Initialise la fenêtre, en utlisant le graphique _graph_  
	- _private void Init(LearnGraph graph)_

	</details>

- ***

	<details>
	<summary>NewNN</summary>

	- >Permet de créer un nouveau réseau de neurones  
	A FAIRE : devra au final permettre de créer une nouvelle session  
	- _private void NewNN()_

	</details>

- ***

	<details>
	<summary>ToggleAvg</summary>

	- >Permet de montrer/cacher la valeur moyenne sur le graphique  
	- _private void ToggleAvg()_

	</details>

- ***

	<details>
	<summary>ToggleData</summary>

	- >Permet de montrer/cacher les valeurs des loss  
	- _private void ToggleData()_

	</details>

- ***

	<details>
	<summary>TogglePause</summary>

	- >Permet de mettre en pause les epochs  
	- _private void TogglePause()_

	</details>

- ***

	<details>
	<summary>TogglePin</summary>

	- >Active/désactive l'épinglage de la fenêtre  
	- _private void TogglePin()_

	</details>

- ***

	<details>
	<summary>ToggleTest</summary>

	- >Permet de lancer un test du réseau de neurones actif  
	- _private void ToggleTest()_

	</details>

- ***

	<details>
	<summary>ToggleTrain</summary>

	- >Permet de lancer un entrainement du réseau de neurones actif  
	- _private void ToggleTrain()_

	</details>

- ***

	<details>
	<summary>WriteToConsole</summary>

	- >Ajoute l'entrée _text_ à la console  
	- _public void WriteToConsole(String text)_

	</details>

</details><details>
<summary>

**Matrix**

</summary>

- Crée une matrice de taille _n_ \* _p_ (# de lignes \* # de colonnes)
>
- _Matrix(int n, int p)_

- _Matrix(int n)_ _(Crée des matrices carrées de taille _n_)_

- ***

	<details>
	<summary>Add</summary>

	- >Ajoute _m_ à la matrice _this_  
	Modifie la matrice _this_  
	Fait l'opération this + m \* scal  
	Si _broadcast_, la matrice _m_ peut être une matrice colonne, et sera étalé sur l'ensemble de _this_  
	- _Matrix Add(Matrix m, double scal, boolean broadcast)_
	- _Matrix Add(Matrix m)_
		- broadcast à false & scal = 1
	- _Matrix Add(Matrix m, double scal)_
		- broadcast à false

	</details>

- ***

	<details>
	<summary>AvgLine</summary>

	- >Renvoie la matrice colonne ayant pour valeur les valeurs moyennes des lignes de _this_  
	- _Matrix AvgLine()_

	</details>

- ***

	<details>
	<summary>AvgMatrix</summary>

	- >Retourne la matrice résultant de la moyenne des matrices de _mats_  
	On utilise comme poids les _coeffs_  
	- _public Matrix AvgMatrix(Matrix[] mats, double[] coeffs)_
	- _public Matrix AvgMatrix(Matrix[] mats)_
		- Chaque matrice a le même poids

	</details>

- ***

	<details>
	<summary>C</summary>

	- >Crée une copie de la matrice - utile pour faire les opérations Add en gardant le résultat sur une autre matrice  
	- _Matrix C()_

	</details>

- ***

	<details>
	<summary>ColumnFromArray</summary>

	- >Met les valeurs du tableau _col_ dans la _j-ième_ colonne de _this_  
	- _Matrix ColumnFromArray(int j, double[] col)_

	</details>

- ***

	<details>
	<summary>ColumnToArray</summary>

	- >Crée un tableau à partir de la _j_-ième colonne de _this_  
	- _double[] ColumnToArray(int j)_

	</details>

- ***

	<details>
	<summary>Comatrix</summary>

	- >Retourne la comatrice de _this_  
	- _Matrix Comatrix()_

	</details>

- ***

	<details>
	<summary>ComutCol</summary>

	- >Comuter les colonnes _j1_ et _j2_  
	- _Matrix ComutCol(int j1, int j2)_

	</details>

- ***

	<details>
	<summary>Contains</summary>

	- >Vérifie si _val_ est dans la matrice _this_  
	- _boolean Contains(double val)_

	</details>

- ***

	<details>
	<summary>Debug</summary>

	- >Afficher la matrice _this_ dans la console  
	- _void Debug()_

	</details>

- ***

	<details>
	<summary>DebugCol</summary>

	- >Affiche la colonne _j_ de _this_ matrice dans la console  
	- _void DebugCol(int j)_

	</details>

- ***

	<details>
	<summary>DebugShape</summary>

	- >Affiche les dimensions de _this_ matrice dans la console  
	- _void DebugShape()_

	</details>

- ***

	<details>
	<summary>Delete</summary>

	- >Supprime la matrice _this_  
	- _void Delete()_

	</details>

- ***

	<details>
	<summary>Det</summary>

	- >Retourne le déterminant de la matrice _this_  
	Calcul récursif de complexité _n_²  
	- _double Det()_

	</details>

- ***

	<details>
	<summary>Dilat</summary>

	- >Multiplie la _j_-ième colonne de _this_ par _scal_  
	- _Matrix Dilat(int j, double scal)_

	</details>

- ***

	<details>
	<summary>Fill</summary>

	- >Remplie la matrice _this_ du double _val_  
	- _Matrix Fill(double val)_

	</details>

- ***

	<details>
	<summary>FromArray</summary>

	- >Copie les valeurs du tableau 2D _val_ dans la matice _this_  
	- _Matrix FromArray(double[][] val)_

	</details>

- ***

	<details>
	<summary>Get</summary>

	- >Réccupère la valeur de _this_ à la ligne _i_ et la colonne _j_  
	- _double Get(int i, int j)_

	</details>

- ***

	<details>
	<summary>GetCol</summary>

	- >Crée une nouvelle matrice à partir de _this_, prenant les colonnes d'indice dans _jList_, restreint entre _startCol_ et _endCol_  
	- _Matrix GetCol(int[] jList, int startCol, int endCol)_
	- _Matrix GetCol(int j)_
		- Ne prend que la colonne j
	- _Matrix GetCol(int a, int b)_
		- Prend les colonnes de [_a_;_b_]
	- _Matrix GetCol(int[] jList)_
		- Pas de limite de colonnes
	- _Matrix GetCol(int[] jList, int numCol)_
		- startCol = 0

	</details>

- ***

	<details>
	<summary>HProduct</summary>

	- >Renvoie une nouvelle matrice, correspondant au produit de Hadamard entre _this_ et _m_  
	- _Matrix HProduct(Matrix m)_

	</details>

- ***

	<details>
	<summary>HasNAN</summary>

	- >Vérifie si la matrice _this_ contient _NaN_  
	- _boolean HasNAN()_

	</details>

- ***

	<details>
	<summary>Identity</summary>

	- >Si la matrice _this_ est carré, fait d'elle la matrice identité  
	- _Matrix Identity()_

	</details>

- ***

	<details>
	<summary>Init</summary>

	- >Initialise la matrice (remet ses valeurs à 0)  
	- _void Init()_

	</details>

- ***

	<details>
	<summary>LoadString</summary>

	- >Charge dans la matrice _this_ les _lignes_  
	- _void LoadString(String[] lignes)_

	</details>

- ***

	<details>
	<summary>Map</summary>

	- >Map la fonction _func_ à la matrice _this_  
	La fonction doit être définie en utilisant la notation lambda : (x) -> notation  
	- _Matrix Map(FunctionMap func)_

	</details>

- ***

	<details>
	<summary>MinMatrix</summary>

	- >Retourne une nouvelle matrice, correspondant à la matrice _this_ dont on a enlevé la ligne _i_ et la colonne _j_  
	- _Matrix MinMatrix(int i, int j)_

	</details>

- ***

	<details>
	<summary>Mult</summary>

	- >Crée une nouvelle matrice, correspondant au produit de _this_ par _m_  
	- _Matrix Mult(Matrix m)_

	</details>

- ***

	<details>
	<summary>NormColumn</summary>

	- >Normalise la matrice _this_  
	La somme de chaque colonne est ramené à 1  
	- _Matrix NormColumn()_

	</details>

- ***

	<details>
	<summary>OLD_Inversed</summary>

	- >(OBSOLETE) Retourne la matrice inverse de _this_ (si elle existe)  
	- _Matrix OLD_Inversed()_

	</details>

- ***

	<details>
	<summary>Random</summary>

	- >Chaque valeur de la matrice est tiré aléatoirement et uniformément entre _min_ et _max_  
	- _Matrix Random(double min, double max)_
	- _Matrix Random()_
		- Retourne une matrice aléatoire à valeurs dans [0;1]

	</details>

- ***

	<details>
	<summary>SaveToString</summary>

	- >Sauvegarde les valeurs de _this_ matrice dans une _String[]_  
	Si _doLog_, affiche le temps restant dans la console  
	- _String[] SaveToString(boolean doLog)_
	- _String[] SaveToString()_
		- Ne retourne pas de log

	</details>

- ***

	<details>
	<summary>Scale</summary>

	- >Multiplie l'ensemble de la matrice _this_ par le facteur _scal_  
	- _Matrix Scale(double scal)_

	</details>

- ***

	<details>
	<summary>Set</summary>

	- >Change la valeur de _this_ à la ligne _i_, la colonne _j_, en lui donnant la valeur _val_  
	- _Matrix Set(int i, int j, double val)_

	</details>

- ***

	<details>
	<summary>ShuffleCol</summary>

	- >Mélange de la même manière les matrices _mats_ (Fisher–Yates shuffle)  
	- _Matrix[] ShuffleCol(Matrix[] mats)_
	- _Matrix ShuffleCol(Matrix mat)_

	</details>

- ***

	<details>
	<summary>SumCol</summary>

	- >Somme les coefficients de la colonne _j_ de _this_  
	- _double SumCol(int j)_

	</details>

- ***

	<details>
	<summary>T</summary>

	- >Crée une nouvelle matrice, transposée de _this_  
	- _Matrix T()_

	</details>

</details><details>
<summary>

**Session**

</summary>

- Crée une session ayant pour nom _name_ et pour hyperparamètres _hp_
>
- _Session(String name, HyperParameters hp)_


- ***

	<details>
	<summary>DirectTest</summary>

	- >Permet de tester en direct les performances du réseau  
	- _void DirectTest()_

	</details>

- ***

	<details>
	<summary>TestImages</summary>

	- >Teste _this.nn_ sur les sets de tests  
	- _void TestImages()_

	</details>

- ***

	<details>
	<summary>TrainForImages</summary>

	- >Entraine le réseau _this.nn_  
	_phaseNumber_ est le nombre de phase de test (création de nouveaux dataset)  
	_epochPerSet_ est le nombre d'epoch à chaque phase  
	_startMinLR_, _endMinLR_, _startMaxLR_ et _endMaxLR_ permettent de définir l'évolution du learning rate  
	_period_ désigne la période de changement du learning rate entre haut et bas  
	_batchSize_ représente la taille des batchs (taille des découpes d'échantillons à chaque epoch)  
	_startDef_ et _endDef_ correspondent à l'évolution du taux de déformation  
	_rep_ est le nombre de répétition de chaque échantillon  
	_prop_ est la proportion minimale de _rep_ pour chaque échantillon, modulé par la performance du réseau sur le charactère associé  
	- _void TrainForImages(int phaseNumber, int epochPerSet, double startMinLR, double endMinLR, double startMaxLR, double endMaxLR, int period, int batchSize, float startDef, float endDef, int rep, float minProp)_

	</details>

</details><details>
<summary>

**ImageManager**

</summary>



- ***

	<details>
	<summary>AutoCrop</summary>

	- >Rogne l'image (nouvelle image) en détectant les contours de l'objet le plus grand dans _img_, ayant un _cap_ et une marge de _marge_ * size pixels  
	- _PImage AutoCrop(PImage img, float cap, float marge)_

	</details>

- ***

	<details>
	<summary>AverageColor</summary>

	- >Retourne la couleur moyenne de l'image _img_  
	- _color AverageColor(PImage img)_

	</details>

- ***

	<details>
	<summary>BlackAndWhite</summary>

	- >Modifie l'image _img_ en noir et blanc - noir si niveau < 255 * _threshold_  
	- _PImage BlackAndWhite(PImage img, float threshold)_

	</details>

- ***

	<details>
	<summary>CompilRect</summary>

	- >Renvoie un rect englobant tous les _rects_  
	- _int[] CompilRect(int[][] rects)_
	- _int[] CompilRect(ArrayList<int[]> rects)_
		- Idem avec ArrayList<int[]>

	</details>

- ***

	<details>
	<summary>ContourDetection</summary>

	- >Renvoie une ArrayList des contours des objets de _img_, ayant un contour de taille au minimum _minSize_  
	Radial Sweep Algorithm  
	https://www.imageprocessingplace.com/downloads_V3/root_downloads/tutorials/contour_tracing_Abeer_George_Ghuneim/ray.html  
	- _ArrayList<ArrayList<PVector>> ContourDetection(PImage img, int minSize)_
	- _ArrayList<ArrayList<PVector>> ContourDetection(PImage img)_

	</details>

- ***

	<details>
	<summary>Contrast</summary>

	- >Retourne une nouvelle image de _img_ auquelle on a effectué un filtre d'intensité _intensity_, utilisant la correction _contrastF_  
	- _PImage Contrast(PImage img, float intensity, FunctionMap contrastF)_
	- _PImage Contrast(PImage img, float intensity)_
		- Contraste linéaire

	</details>

- ***

	<details>
	<summary>ElasticDeformation</summary>

	- >Retourne une nouvelle image de _img_, auquel on effectue une déformation élastique d'intensité _intensity_, et d'échelle de bruit _noiseScale_  
	- _PImage ElasticDeformation(PImage img, float intensity, float noiseScale)_

	</details>

- ***

	<details>
	<summary>Filter</summary>

	- >Retourne le pixel (_x_, _y_) de l'image _img_ auquelle on applique la convolution de filtre _filter_  
	- _color Filter(PImage img, Matrix filter, int x, int y)_

	</details>

- ***

	<details>
	<summary>FullConvolution</summary>

	- >Retourne une nouvelle image _img_ sur laqeulle on a effectué la convolution _filter_  
	- _PImage FullConvolution(PImage img, Matrix filter)_
	- _Matrix FullConvolution(Matrix images, Matrix filter, int w, int h)_
		- Effectue la convolution sur l'ensemble des images correspondant à la matrice _images_, en considérant des images de taille _w_ * _h_

	</details>

- ***

	<details>
	<summary>Gray</summary>

	- >Modifie l'image _img_ en niveau de gris  
	- _PImage Gray(PImage img)_

	</details>

- ***

	<details>
	<summary>ImageFromContour</summary>

	- >Retourne une nouvelle image de _img_, découpant le contour _contour_, avec une marge de _marge_ * size pixels, ayant un ratio w/h cible _ratio_  
	- _PImage ImageFromContour(PImage img, ArrayList<PVector> contour, float marge, float ratio)_

	</details>

- ***

	<details>
	<summary>IsClockwise</summary>

	- >Détecte si un contour PVector[] est clockwise  
	Un contour clockwise est un contour extérieur  
	Il s'agit évidemment de magie noire, toujours pas regardé d'où ça vient ce truc  
	https://stackoverflow.com/questions/1165647/how-to-determine-if-a-list-of-polygon-points-are-in-clockwise-order  
	- _boolean IsClockwise(PVector[] contour) {  // Si un contour est clockwise, alors il s'agit d'un contour extérie_
	- _boolean IsClockwise(ArrayList<PVector> contour)_
		- Idem avec une _ArrayList<PVector>_

	</details>

- ***

	<details>
	<summary>OLD_AutoCrop</summary>

	- >Ancien autocrop, se basant uniquement sur la recherche de pixel non blanc - utilisé en secours par **AutoCrop**  
	- _PImage OLD_AutoCrop(PImage img, float cap, float tolerance) { // Consider the object as black (or darker par_

	</details>

- ***

	<details>
	<summary>RectFromContour</summary>

	- >Renvoie de contour du _PVector[] contour_  
	- _int[] RectFromContour(PVector[] contour)_
	- _int[] RectFromContour(ArrayList<PVector> contour)_
		- Idem avec une _ArrayList<PVector> contour_

	</details>

- ***

	<details>
	<summary>RectGroups</summary>

	- >Renvoie une liste des groupes de rectangle proche parmi les _rect_, ayant une marge horizontale _hMarge_ et verticale _vMarge_  
	- _ArrayList<ArrayList<int[]>> RectGroups(int[][] rect, float hMarge, float vMarge)_
	- _ArrayList<ArrayList<int[]>> RectGroups(ArrayList<int[]> rect, float hMarge, float vMarge)_
		- Idem avec une ArrayList<int[]>

	</details>

- ***

	<details>
	<summary>Resize</summary>

	- >Redimenssionne l'image _img_ à la taille _x_ * _y_  
	- _PImage Resize(PImage img, int x, int y)_
	- _PImage Resize(PImage img, float s)_
		- Garde le même ratio, multiplié d'un facteur _s_

	</details>

- ***

	<details>
	<summary>ScrambleImage</summary>

	- >Modifie de manière l'iamge _img_, en :  
	-> la bougeant (rotation, translation, scale) d'un facteur _move_  
	-> floutant d'un facteur _blur_  
	-> ayant une proportion de pixel corrompu _density_  
	-> ayant une ombre d'intensité _perlin_  
	-> ayant une déformation de facteur _deformation_.  
	L'image est enregistré dans ./ScrambledImage enregistré si _save_  
	- _PImage ScrambleImage(PImage img, boolean save, float move, float blur, float density, float perlin, float deformation)_
	- _PImage ScrambleImage(PImage img, float move, float blur, float density, float perlin, float deformation)_
		- N'est pas sauvegardé

	</details>

</details><details>
<summary>

**NeuralNetwork**

</summary>

- _sizes_ correspond aux tailles des niveaux
>
- _NeuralNetwork(int... sizes)_

- _NeuralNetwork()_ _(Pour *Import*)_

- ***

	<details>
	<summary>BackPropagation</summary>

	- >Effectue la rétropropagation du réseau de neurones  
	On prend en entrée les valeurs d'_activations_ des layers  
	On donne les valeurs attendues dans _expectedOutput_  
	- _public Matrix[][] BackPropagation(Matrix[] activations, Matrix expectedOutput)_

	</details>

- ***

	<details>
	<summary>CalcLayer</summary>

	- >Calcule la sortie correspondant à l'entrée _in_, de la couche _from_ à la couche _from+1_  
	- _private Matrix CalcLayer(int from, Matrix in)_

	</details>

- ***

	<details>
	<summary>ComputeLoss</summary>

	- >Permet le calcul du loss  
	_S_ est la sortie du système  
	_Y_ est la sortie attendue  
	- _public double ComputeLoss(Matrix S, Matrix Y)_

	</details>

- ***

	<details>
	<summary>Export</summary>

	- >Sauvegarde les paramètres du réseau de neurones dans _name_  
	- _public void Export(String name)_

	</details>

- ***

	<details>
	<summary>ForwardPropagation</summary>

	- >Prend la matrice _entry_ en entrée, et renvoie un tableau des valeurs de chaque couche  
	_entry.p_ correspond au nombre d'entrées données simultanément  
	- _public Matrix[] ForwardPropagation(Matrix entry)_

	</details>

- ***

	<details>
	<summary>Import</summary>

	- >Importe un réseau de neurones depuis le fichier _name_  
	- _public NeuralNetwork Import(String name)_

	</details>

- ***

	<details>
	<summary>Learn</summary>

	- >Effectue une étape d'apprentissage, ayant pour entrée _X_ et pour sortie _Y_  
	Le taux d'apprentissage est _learning\_rate_  
	- _public double Learn(Matrix X, Matrix Y, double learning_rate)_

	</details>

- ***

	<details>
	<summary>Predict</summary>

	- >Donne la sortie du réseau de neurones _this_ pour l'entrée _entry_  
	- _public Matrix Predict(Matrix entry)_

	</details>

</details><details>
<summary>

**Bayes**

</summary>

- 
>
- _Bayes(String n)_


- ***

	<details>
	<summary>CNDF</summary>

	- >Piqué sur un site mais on n'a pas enregistré lequel  
	Calcul de la *fonction de répartition cumulative de la distribution normale standard*  
	- _double CNDF(double x)_

	</details>

- ***

	<details>
	<summary>Evaluate</summary>

	- >Permet d'évaluer la force d'une combinaison d'hyperparamètres  
	- _public double Evaluate(HyperParameters hp, Matrix[] trainSet, Matrix[] testSet, int time)_

	</details>

- ***

	<details>
	<summary>Export</summary>

	- >Exporte le Bayes _this_ dans le fichier _name_  
	- _public void Export(String name)_

	</details>

- ***

	<details>
	<summary>FindCandidate</summary>

	- >Cherche le candidat ayant potentiellement le meilleur résultat  
	- _public HyperParameters FindCandidate()_

	</details>

- ***

	<details>
	<summary>GaussianProcess</summary>

	- >Effectue le processus Gaussien de recherche de meilleur candidat  
	Effectué _iter_ fois  
	On limite le temps de recherche par candidat à _time_ secondes  
	- _public double GaussianProcess(int iter, int time)_

	</details>

- ***

	<details>
	<summary>Import</summary>

	- >Importe le Bayes à partir venant de _name_  
	- _public Bayes Import(String name)_

	</details>

- ***

	<details>
	<summary>Kernel</summary>

	- >Kernel  
	Calcule la "covariance" entre _hp1_ et _hp2_  
	- _public double Kernel(HyperParameters hp1, HyperParameters hp2)_

	</details>

- ***

	<details>
	<summary>MinLoss</summary>

	- >Trouve le meilleur candidat dans la liste proposée  
	- _public HyperParameters MinLoss()_

	</details>

- ***

	<details>
	<summary>NDF</summary>

	- >Calcul de la *Fonction de densité de probabilité de la distribution normale standard*  
	- _double NDF(double x)_

	</details>

</details><details>
<summary>

**HyperParameters**

</summary>



- ***

	<details>
	<summary>BetaRandom</summary>

	- >Fonction de Random Beta de paramètre _alpha_ et _beta_  
	- _double BetaRandom(double alpha, double beta)_

	</details>

- ***

	<details>
	<summary>GammaRandom</summary>

	- >Fonction de Random Gamma de paramètre _shape_ et _scale_  
	C'est majoritairement de la magie noire cette fonction  
	https://chrispiech.github.io/probabilityForComputerScientists/en/part4/beta/  
	- _double GammaRandom(double shape, double scale)_

	</details>

- ***

	<details>
	<summary>LogRandom</summary>

	- >Fonction de Random log-normale entre _min_ et _max_  
	- _double LogRandom(double min, double max)_

	</details>

- ***

	<details>
	<summary>PoissonRandom</summary>

	- >Fonction de Random de poisson de paramètre _lambda_  
	- _int PoissonRandom(double lambda)_

	</details>

- ***

	<details>
	<summary>Random</summary>

	- >Tire des hyperparamètres aléatoirement  
	- _HyperParameters Random()_
	- _Matrix Random()_
		- Retourne une matrice aléatoire à valeurs dans [0;1]

	</details>

- ***

	<details>
	<summary>UniRandom</summary>

	- >Fonction de random uniforme entre _min_ et _max_  
	- _double UniRandom(double min, double max)_

	</details>

</details><details>
<summary>

**LetterDataset**

</summary>

- Créateur de dataset
>- Zone de travail définie par _wData_ * _hData_

- _LetterDataset(int wData, int hData)_


- ***

	<details>
	<summary>CreateSample</summary>

	- >Renvoie un couple entrée / sortie d'images pour le réseau  
	_characters_ correspond à la liste des caractères dont on créera un dataset  
	_hwSources_ et _fSources_ correspondent aux noms respectivement des écritures à la main et des polices utilisées  
	_repList_ correspond au nombre de répétition de chaque caractère respectivement, par échantillon initial  
	_deformationRate_ correspond au taux de déformation utilisé  
	- _public Matrix[] CreateSample(String[] characters, String[] hwSources, String[] fSources, int[] repList, float deformationRate)_
	- _public Matrix[] CreateSample(String[] characters, String[] hwSources, String[] fSources, int rep)_
		- On fixe le nombre de répétitions des caractères identiquement à _rep_. On fixe la _deformationRate_ à 1
	- _public Matrix[] CreateSample(String[] characters, String[] hwSources, String[] fSources, int rep, float deformationRate)_
		- On fixe le nombre de répétitions des caractères identiquement à _rep_
	- _public Matrix[] CreateSample(String[] characters, String[] hwSources, String[] fSources, int[] repList)_
		- _deformationrate_ à 1

	</details>

- ***

	<details>
	<summary>Export</summary>

	- >Exporte le dataset _data_ dans le fichier _name_  
	- _public void Export(Matrix[] data, String name)_

	</details>

- ***

	<details>
	<summary>GetImageFromInputs</summary>

	- >Renvoie une image affichable de l'image stockée en colonne _j_ de l'entrée _inputs_  
	- _public PImage GetImageFromInputs(Matrix inputs, int j)_

	</details>

- ***

	<details>
	<summary>Import</summary>

	- >Importe un dataset à partir du fichier _name_  
	- _public Matrix[] Import(String name)_

	</details>

</details><details>
<summary>

**WordCorrector**

</summary>

- 
>
- _WordCorrector() _


- ***

	<details>
	<summary>ImportWords</summary>

	- >Importe l'ensemble des mots du fichier _scrabble.txt_ dans la variable _this.words_  
	- _public void ImportWords()_

	</details>

- ***

	<details>
	<summary>WordAutoCorrection</summary>

	- >Donne le mot le plus probable pour une entrée _letterProb_  
	_letterProb_ contient pour chaque emplacement les probabilités de chaque caractère  
	Simule toutes les manipulations possibles de manière probabiliste  
	Algorithme assez (très) naïf, donc à voir dans la pratique  
	- _public String WordAutoCorrection(double[][] letterProb)_

	</details>

</details><details>
<summary>

**CharactersStorage**

</summary>

- 
>
- _CharactersStorage(int numOfChar)_


- ***

	<details>
	<summary>AddChar</summary>

	- >Ajoute le caractère donc le fichier est _name_, associé au caractère _d_, qui sera associé pour l'alphabet par _correspondance_  
	Dans _correpondance_, on a la liste des couple de lettre ressemblantes, avec la part de ressemble  
	_exemple : correspondance = {{8, 0.3}, {11, 0.3}}) pour le 1, qui ressemble au i et au l_  
	- _void AddChar(String name, char d, double[][] correspondance)_

	</details>

- ***

	<details>
	<summary>GetProb</summary>

	- >Permet d'obtenir les probabilités pour chacune des 26 lettres à partir de la sortie du réseau _allProb_  
	- _double[] GetProb(double[] allProb)_

	</details>

</details><details>
<summary>

**ConsoleLog**

</summary>

- Créer une instance de ConsoleLog ayant pour nom _name_
>- Les logs sont enregistrés dans le fichier renseigné dans _name_

- _ConsoleLog(String name)_


- ***

	<details>
	<summary>End</summary>

	- >Termine l'enregistrement du fichier  
	- _void End()_

	</details>

- ***

	<details>
	<summary>Update</summary>

	- >S'assure que le fichier correspondant est mis à jour  
	- _void Update()_

	</details>

- ***

	<details>
	<summary>p</summary>

	- >Energistre une nouvelle donnée (sans saut de ligne)  
	Equivalent au *print()*  
	- _void p(Object... o)_
	- _void p(String... o)_

	</details>

- ***

	<details>
	<summary>pFloatList</summary>

	- >Energistre une nouvelle ligne, correspondant à la liste de flottants _list_  
	Est labelisé à l'aide de _label_  
	- _void pFloatList(float[] list, String label)_

	</details>

- ***

	<details>
	<summary>pln</summary>

	- >Energistre une nouvelle ligne (saut de ligne)  
	Equivalent au *println()*  
	- _void pln(Object... o)_
	- _void pln(String... o)_

	</details>

</details><details>
<summary>

**Database**

</summary>

- _link_ correspond au lien de la realtime database
>
- _Database(String link)_


- ***

	<details>
	<summary>GetData</summary>

	- >Réccupère le contenu des _data_ dans la base de donnée, dans la section _fileName_  
	- _public String[] GetData(String fileName)_

	</details>

- ***

	<details>
	<summary>PostData</summary>

	- >Ajoute à la base de donnée, dans la section _fileName_, le String _data_  
	- _public void PostData(String fileName, String data)_

	</details>

</details>