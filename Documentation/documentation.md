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