import math
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm
import numpy as np
import random
import time


def CNDF(x):
    neg = 1 if x < 0 else 0
    if (neg == 1):
        x *= -1

    k = 1 / ( 1 + 0.2316419 * x)
    y = (((( 1.330274429 * k - 1.821255978) * k + 1.781477937) * k - 0.356563782) * k + 0.319381530) * k
    y = 1.0 - 0.398942280401 * math.exp(-0.5 * x * x) * y

    return (1 - neg) * y + neg * (1 - y)


def NDF(x):
    return math.exp(- x * x / 2) / math.sqrt(2 * math.pi)


def kernel(hp1, hp2, h):
    hp1 = np.array(hp1)
    hp2 = np.array(hp2)
    return np.exp(-np.sum((hp1 - hp2)**2) / (2 * h**2))


def random_candidate(dim, canvas):
    return [random.random() * 2 * canvas - canvas for i in range(dim)]


def find_candidate(xs, ys, h, fBest, numOfCandidate):
    n = len(xs)

    # Matrice de covariance K
    K = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            K[i, j] = kernel(xs[i], xs[j], h)

    K += jitter * np.eye(n)

    K_inv = np.linalg.solve(K, np.eye(n))

    # Vecteur Y
    Y = np.array(ys).reshape(-1, 1)

    params = []
    EIs = np.zeros(numOfCandidate)

    for cIdx in range(numOfCandidate):
        # Paramètres candidats aléatoires
        # p = random_candidate(candidate_dim, canvas_size)
        p = [random.random() * (xmax - xmin) + xmin, random.random() * (ymax - ymin) + ymin]
        params.append(p)

        # K*
        Kstar = np.zeros((n, 1))
        for i in range(n):
            Kstar[i, 0] = kernel(p, xs[i], h)

        # K**
        Kstarstar = kernel(p, p, h)

        # Formule 2.12 p12 de
        # https://gaussianprocess.org/gpml/
        # Moyenne et variance prédictives
        mu = (Kstar.T @ K_inv @ Y)[0, 0]
        sigma2 = Kstarstar - (Kstar.T @ K_inv @ Kstar)[0, 0]
        sigma = math.sqrt(max(sigma2, 0.0))

        # Expected Improvement
        Zn = (fBest - mu) / sigma if sigma > 0 else 0.0
        EIs[cIdx] = (fBest - mu) * CNDF(Zn) + beta * sigma * NDF(Zn)
        # NB : le commentaire "peut-être qu'il y a un moins" reste valable

    # Recherche du maximum
    maxIdx = int(np.argmax(EIs))
    maxEI = EIs[maxIdx]

    #print("Maximum EI", f"{maxEI:9.3E}")

    return params[maxIdx]


def draw_EI(xs, ys, h, fBest, step, out_dir, doLog = False):
    import os
    os.makedirs(out_dir, exist_ok=True)

    grid = 150
    x = np.linspace(xmin, xmax, grid)
    y = np.linspace(ymin, ymax, grid)
    
    X, Y = np.meshgrid(x, y)
    Z = f(X, Y)

    EI = np.zeros_like(X)


    n = len(xs)

    # Matrice de covariance K
    K = np.zeros((n, n))
    for i in range(n):
        for j in range(n):
            K[i, j] = kernel(xs[i], xs[j], h)

    K += jitter * np.eye(n)

    K_inv = np.linalg.solve(K, np.eye(n))
    Yei = np.array(ys).reshape(-1, 1)

    for i in range(grid):
        for j in range(grid):
            # Paramètres candidats aléatoires
            p = [X[i, j], Y[i, j]]

            # K*
            Kstar = np.zeros((n, 1))
            for k in range(n):
                Kstar[k, 0] = kernel(p, xs[k], h)

            # K**
            Kstarstar = kernel(p, p, h)

            # Moyenne et variance prédictives
            mu = (Kstar.T @ K_inv @ Yei)[0, 0]
            sigma2 = Kstarstar - (Kstar.T @ K_inv @ Kstar)[0, 0]
            sigma = math.sqrt(max(sigma2, 0.0))

            # Expected Improvement
            Zn = (fBest - mu) / sigma if sigma > 0 else 0.0
            EI[i, j] = (fBest - mu) * CNDF(Zn) + beta * sigma * NDF(Zn)
            # NB : le commentaire "peut-être qu'il y a un moins" reste valable

    EI = np.nan_to_num(EI, nan=0.0, posinf=0.0, neginf=0.0)
    EI_pos = EI - EI.min() + 1e-12

    cmap = plt.cm.inferno.copy()
    cmap.set_bad(color="black")

    plt.figure(figsize=(8, 6))

    if doLog and Z.min() > 0:
        plt.contourf(X, Y, Z, levels=50, norm = LogNorm(vmin = Z.min(), vmax = Z.max()), cmap="viridis", alpha = 0.9)
    else:
        plt.contourf(X, Y, Z, levels=50, cmap="viridis", alpha = 0.9)


    plt.contour(
        X, Y, EI_pos,
        levels=10,
        cmap=cmap,
        linewidths=1.5,
        norm = LogNorm()
    )


    """
    cbar = plt.colorbar(label="Expected Improvement")
    cbar.formatter.set_useOffset(False)
    cbar.update_ticks()
    """

    xs_vals = np.array(xs)
    plt.scatter(
        xs_vals[:, 0], xs_vals[:, 1],
        c="cyan",
        edgecolors="black",
        s=40,
        label="Essais"
    )

    best_idx = np.argmin(ys)
    plt.scatter(
        xs_vals[best_idx, 0],
        xs_vals[best_idx, 1],
        c="lime",
        s=100,
        marker="*",
        label="Meilleur point"
    )

    plt.scatter(
        xs_vals[-1, 0],
        xs_vals[-1, 1],
        c="red",
        s=10,
        marker=".",
        label="Dernier point"
    )

    info = (
    f"f_best = {fBest:.3e}\n"
    f"f_last = {ys[-1]:.3e}\n"
    )

    plt.text(
        0.02, 0.98,
        info,
        transform=plt.gca().transAxes,
        fontsize=10,
        va="top",
        ha="left",
        bbox=dict(facecolor="black", alpha=0.4, edgecolor="none"),
        color="white"
    )

    plt.xlabel("x")
    plt.ylabel("y")
    plt.title(f"Fonction et Ligne d'EI - itération {step}")
    plt.legend()

    plt.savefig(f"{out_dir}/ei_{step:03d}.png", dpi = 150, bbox_inches="tight")
    plt.close()




def process(f, numOfCandidate, random_iter, calc_iter, do_draw_EI):
    xs = []
    ys = []
    bs = []

    folder = time.time()

    fBest = None

    # Initialise avec un certain nombre de candidats aléatoires
    for _ in range(random_iter):
        #p = random_candidate(candidate_dim, canvas_size)
        p = [random.random() * (xmax - xmin) + xmin, random.random() * (ymax - ymin) + ymin]
        xs.append(p)

        res = f(p)
        if fBest:
            fBest = min(fBest, res)
        else:
            fBest = res
        bs.append(fBest)

        ys.append(res)

    for step in range(calc_iter):
        p = find_candidate(xs, ys, h, fBest, numOfCandidate)
        xs.append(p)

        res = f(p)
        if fBest:
            fBest = min(fBest, res)
        else:
            fBest = res
        bs.append(fBest)

        ys.append(res)

        if do_draw_EI: draw_EI(xs, ys, h, fBest, step, f"./EIDraws/{folder}")


    xs_vals = np.array(xs)
    ys_vals = np.array(ys)

    plt.figure(figsize=(8, 6))
    if Z.min() > 0:
        plt.contourf(X, Y, Z, levels=50, norm = LogNorm(vmin = Z.min(), vmax = Z.max()), cmap="viridis")
    else:
        plt.contourf(X, Y, Z, levels=50, cmap="viridis")
    plt.scatter(xs_vals[:, 0], xs_vals[:, 1],
                c=ys_vals, cmap="Reds", edgecolors="white", s=60)
    plt.colorbar(label="Score")
    plt.xlabel("x")
    plt.ylabel("y")
    plt.title("Points explorés par l'optimisation bayésienne")

    """
    plt.figure(figsize=(8, 6))
    plt.plot(ys)
    plt.plot(bs)
    plt.title("Evolution des scores obtenus")
    """

    return fBest


def expected_min_quantile(Z, n, eps = 1e-2):
    flat = Z.flatten()
    mean = np.quantile(flat, 1.0 / (n+1))

    m = max(20, int((2.0 / n) * len(flat)))
    small = np.sort(flat)[:m]

    std_est = np.std(small) / np.sqrt(n)
    return mean, std_est


#https://benchmarkfcns.info/doc/himmelblaufcn.html
def himmelblau(x, y):
    return (x*x + y - 11)**2 + (x + y*y - 7)**2

def sphere(x, y):
    return x*x + y*y

#https://www.sfu.ca/~ssurjano/rastr.html
def rastrigin(x, y):
    return 20 + x*x + y*y - 10*(np.cos(2*np.pi*x) + np.cos(2*np.pi*y))

#https://www.sfu.ca/~ssurjano/schwef.html
def schwefel(t):
    return 418.9829 * len(t) - sum([x * np.sin(np.sqrt(abs(x))) for x in t])

def schwefel2D(x,y):
    return schwefel([x,y])

#https://www.sfu.ca/~ssurjano/branin.html
def branin(x, y): #-5 -> 10, 0 -> 15
    a = 1
    b = 5.1 / (4 * np.pi**2)
    c = 5 / np.pi
    r = 6
    s = 10
    t = 1 / (8 * np.pi)

    return a * (y - b*x**2 + c*x - r)**2 + s*(1 - t)*np.cos(x) + s


#https://www.sfu.ca/~ssurjano/goldpr.html
def goldstein_price(x, y):
    return (1 + (x + y + 1)**2 *
        (19 - 14*x + 3*x**2 - 14*y + 6*x*y + 3*y**2)) * \
        (30 + (2*x - 3*y)**2 *
        (18 - 32*x + 12*x**2 + 48*y - 36*x*y + 27*y**2))


def needle(x, y):
    return 1 - np.exp(-500*((x-0.73)**2 + (y-0.41)**2))

#https://www.sfu.ca/~ssurjano/camel6.html
def six_hump_camel(x, y): #3, 2
    return (4 - 2.1*x**2 + x**4/3)*x**2 + x*y + (-4 + 4*y**2)*y**2



def evaluate2D(t, f):
    return f(t[0], t[1])



candidate_dim = 2
canvas_size = 7.5
h = 0.2 * canvas_size
beta = 1 #Paramètre réglant la dose d'exploration (< 1 -> exploitation, > 1 -> exploration)
jitter = 1e-6 #Correpond à du bruit de lecture, permet de ne pas avoir de déterminant nul

f = branin

xmin, xmax = -5, 10
ymin, ymax = 0, 15

x = np.linspace(xmin, xmax, 1000)
y = np.linspace(ymin, ymax, 1000)
X, Y = np.meshgrid(x, y)
Z = f(X, Y)



N = 20
sum = 0
for i in range(N):
    val = process(lambda t: evaluate2D(t, f), 2500, 5, 75, i < 10)
    print(i, val)
    sum += val

print("Average Best with Bayes :", sum / N)


#process(lambda t: evaluate2D(t, f), 2500, 5, 75, True)

#process(lambda t: evaluate2D(t, f), 10000, 80, 0)
print("Average Best with Monte-Carlo", expected_min_quantile(Z, 80))



plt.show()
