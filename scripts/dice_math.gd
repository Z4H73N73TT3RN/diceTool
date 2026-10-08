class_name DiceCalculator
extends RefCounted

func _ready() -> void:
	pass
	
# Binomialkoeffizient n choose k
static func n_choose_k(n: int, k: int) -> float:
	if k < 0 or k > n:
		return 0.0
	if k == 0 or k == n:
		return 1.0
	var res: float = 1.0
	for i in range(1, k + 1):
		res = res * (n - (k - i)) / i
	return res

# Binomiale Wahrscheinlichkeitsfunktion (PMF)
static func binom_pmf(n: int, k: int, p: float) -> float:
	return n_choose_k(n, k) * pow(p, k) * pow(1.0 - p, n - k)

# P(X >= k)
static func prob_at_least_k(n: int, k: int, p: float) -> float:
	var total_p: float = 0.0
	for i in range(k, n + 1):
		total_p += binom_pmf(n, i, p)
	return total_p

# Faltung von Wahrscheinlichkeitsverteilungen (Analog zu Python defaultdict)
static func falte_wahrscheinlichkeiten(liste_von_wuerfeln: Array) -> Dictionary:
	var aktuelle_verteilung: Dictionary = {0: 1.0}

	for wuerfel in liste_von_wuerfeln:
		var neue_verteilung: Dictionary = {}
		for bisherige_summe in aktuelle_verteilung.keys():
			var wahrscheinlichkeit_bisher: float = aktuelle_verteilung[bisherige_summe]
			for augenwert in wuerfel.keys():
				var wahrscheinlichkeit_wuerfel: float = wuerfel[augenwert]
				var neue_summe: int = bisherige_summe + augenwert
				var neue_prob: float = wahrscheinlichkeit_bisher * wahrscheinlichkeit_wuerfel
				
				neue_verteilung[neue_summe] = neue_verteilung.get(neue_summe, 0.0) + neue_prob
		aktuelle_verteilung = neue_verteilung.duplicate()

	return aktuelle_verteilung

# Schadensreduktion anwenden
static func apply_reduction(sum_dist: Dictionary, reduction_dist: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	for s_val in sum_dist.keys():
		var s_prob: float = sum_dist[s_val]
		for r_val in reduction_dist.keys():
			var r_prob: float = reduction_dist[r_val]
			var final_val: int = max(0, s_val - r_val)
			result[final_val] = result.get(final_val, 0.0) + (s_prob * r_prob)
	return result
