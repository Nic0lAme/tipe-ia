import functools

class CLASS:

    def __init__(self, _name):
        self.name = _name
        self.functions = []


class FUNCTIONS:

    def __init__(self, _name, _desc, _full):
        self.name = _name
        self.desc = _desc
        self.full = _full



files_name = [("../Matrix.pde", "Matrix"), ("../ImageManager.pde", "ImageManager"), ("../NeuralNetwork.pde", "NeuralNetwork"), ("../LetterDataset.pde", "LetterDataset"), ("../ConsoleLog.pde", "ConsoleLog")]
classes = []

surcharges = []

is_fun = False
is_surch = False
desc = ""
for fname in files_name:
    f = open(fname[0])
    c = CLASS(fname[1])

    for l in f:
        enlarge = l.strip().split()
        if is_fun:
            is_fun = False
            name = l[:l.index("(")]
            name = name[name.rfind(" ")+1:]
            fun = FUNCTIONS(name, desc, [(l.strip()[:-2], "")])
            c.functions.append(fun)
        if is_surch:
            is_surch = False
            name = l[:l.index("(")]
            name = name[name.rfind(" ")+1:]
            surcharges.append((name, l.strip()[:-2], desc))
        if len(enlarge) > 0 and enlarge[0] == "//f":
            is_fun = True
            desc = l.strip()[4:]
        if len(enlarge) > 0 and enlarge[0] == "//s":
            is_surch = True
            desc = l.strip()[4:]

    for s in surcharges:
        for fun in c.functions:
            if s[0] == fun.name:
                fun.full.append((s[1], s[2]))

    classes.append(c)
    f.close()


def alphabeticalName(a, b):
    return 1 if a.name > b.name else -1

mark = "# DOCUMENTATION\n\n"

for c in classes:
    mark += f'<details>\n<summary>\n\n**{c.name}**\n\n</summary>\n\n'

    c.functions = sorted(c.functions, key=functools.cmp_to_key(alphabeticalName))
    for f in c.functions:
        mark += f'- ***\n\n\t<details>\n\t<summary>{f.name}</summary>\n\n\t- >{f.desc}\n'
        for s in f.full:
            mark += f'\t- _{s[0]}_\n'
            if s[1] != "": mark += f'\t\t- {s[1]}\n'
        mark += f'\n\t</details>\n\n'
    mark+=f'</details>'

print(c)
with open("documentation.md", "w") as file:
    file.write(mark)