# DOCUMENTATION

<details>
<summary>

**Matrix**

</summary>

- ***

	<details>
	<summary>Add</summary>

	- >Add some matrix m to this ; does this + scal * m  
	- _Matrix Add(Matrix m, double scal, boolean broadcast)_
	- _Matrix Add(Matrix m)_
		- broadcast to false et scal = 1
	- _Matrix Add(Matrix m, double scal)_
		- broadcast to false

	</details>

- ***

	<details>
	<summary>AvgLine</summary>

	- >Compute the column matrix of the average of each row from this  
	- _Matrix AvgLine()_

	</details>

- ***

	<details>
	<summary>C</summary>

	- >Crée une copie de la matrice - utile pour faire les opérations Add en gardant le résultat sur une autre matrice  
	- _Matrix C()_

	</details>

- ***

	<details>
	<summary>ColToArray</summary>

	- >Create an array from a _j-th_ column  
	- _double[] ColToArray(int j)_

	</details>

- ***

	<details>
	<summary>ColumnFromArray</summary>

	- >Set _j-th_ column from a double array  
	- _Matrix ColumnFromArray(int j, double[] col)_

	</details>

- ***

	<details>
	<summary>Comatrix</summary>

	- >Return the comatrix  
	- _Matrix Comatrix()_

	</details>

- ***

	<details>
	<summary>ComutCol</summary>

	- >Comut col j1 and j2  
	- _Matrix ComutCol(int j1, int j2)_

	</details>

- ***

	<details>
	<summary>Contains</summary>

	- >Check if this matrix contain _val_  
	- _boolean Contains(double val)_

	</details>

- ***

	<details>
	<summary>Debug</summary>

	- >Print the matrix in the console  
	- _void Debug()_

	</details>

- ***

	<details>
	<summary>DebugCol</summary>

	- >Debug column j of this matrix  
	- _void DebugCol(int j)_

	</details>

- ***

	<details>
	<summary>DebugShape</summary>

	- >Debug the shape of this matrix  
	- _void DebugShape()_

	</details>

- ***

	<details>
	<summary>Delete</summary>

	- >  
	- _void Delete()_

	</details>

- ***

	<details>
	<summary>Det</summary>

	- >Return matrix determinant  
	- _double Det()_

	</details>

- ***

	<details>
	<summary>Dilat</summary>

	- >Dilat j-th column by -scal-  
	- _Matrix Dilat(int j, double scal)_

	</details>

- ***

	<details>
	<summary>Fill</summary>

	- >Fill the matrix with some value val  
	- _void Fill(double val)_

	</details>

- ***

	<details>
	<summary>FromArray</summary>

	- >Copy the value of an array in the matrix  
	- _Matrix FromArray(double[][] val)_

	</details>

- ***

	<details>
	<summary>Get</summary>

	- >Get value of i, j  
	- _double Get(int i, int j)_

	</details>

- ***

	<details>
	<summary>GetCol</summary>

	- >Create a new matrix with the column with indices in jList, restreint entre _startCol_ et _endCol_  
	- _Matrix GetCol(int[] jList, int startCol, int endCol)_
	- _Matrix GetCol(int j)_
		- Ne prend que la colonne j
	- _Matrix GetCol(int a, int b)_
		- Range is inclusive
	- _Matrix GetCol(int[] jList)_
		- Pas de limite de colonnes
	- _Matrix GetCol(int[] jList, int numCol)_
		- startCol = 0

	</details>

- ***

	<details>
	<summary>HProduct</summary>

	- >Hadamard Product : Multiply the coefficient of this matrix by the ones of another one  
	- _Matrix HProduct(Matrix m)_

	</details>

- ***

	<details>
	<summary>HasNAN</summary>

	- >Check if this matrix contain a _NaN_  
	- _boolean HasNAN()_

	</details>

- ***

	<details>
	<summary>Identity</summary>

	- >Create identity matrix if the matrix is a square one  
	- _Matrix Identity()_

	</details>

- ***

	<details>
	<summary>Init</summary>

	- >  
	- _void Init()_

	</details>

- ***

	<details>
	<summary>Inversed</summary>

	- >Return the inversed matrix  
	- _Matrix Inversed()_

	</details>

- ***

	<details>
	<summary>LoadString</summary>

	- >Load this matrix from a string array  
	- _void LoadString(String[] lignes)_

	</details>

- ***

	<details>
	<summary>Map</summary>

	- >Map funciton func (using (x) -> notation) to this  
	- _Matrix Map(FunctionMap func)_

	</details>

- ***

	<details>
	<summary>Matrix</summary>

	- >Made to create fast square matrixes  
	- _Matrix(int _n)_

	</details>

- ***

	<details>
	<summary>MinMatrix</summary>

	- >Return the associated matrix from minor i, j  
	- _Matrix MinMatrix(int i, int j)_

	</details>

- ***

	<details>
	<summary>Mult</summary>

	- >Create a new matrix, which is this * m  
	- _Matrix Mult(Matrix m)_

	</details>

- ***

	<details>
	<summary>NormColumn</summary>

	- >Sum of each column is scaled to be 1  
	- _Matrix NormColumn()_

	</details>

- ***

	<details>
	<summary>Random</summary>

	- >Every value of the matrix random from min to max  
	- _Matrix Random(double min, double max)_
	- _Matrix Random()_
		- Retourne une matrice aléatoire à valeurs dans [0;1]

	</details>

- ***

	<details>
	<summary>SaveToString</summary>

	- >Save this matrix into a string array  
	- _String[] SaveToString(boolean doLog)_
	- _String[] SaveToString()_
		- Ne retourne pas de log

	</details>

- ***

	<details>
	<summary>Scale</summary>

	- >Scale matrix by some factor  
	- _Matrix Scale(double scal)_

	</details>

- ***

	<details>
	<summary>Set</summary>

	- >Change the i, j value to value val  
	- _void Set(int i, int j, double val)_

	</details>

- ***

	<details>
	<summary>SumCol</summary>

	- >Sum coeff from j-th column  
	- _double SumCol(int j)_

	</details>

- ***

	<details>
	<summary>T</summary>

	- >Create a new matrix, equal to the transposed matrix of this  
	- _Matrix T()_

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

</details><details>
<summary>

**LetterDataset**

</summary>

</details><details>
<summary>

**ConsoleLog**

</summary>

</details>