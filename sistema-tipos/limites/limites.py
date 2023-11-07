import sys

teto = sys.maxsize
print(type(teto))
print(sys.getsizeof(teto))
print(teto)

teto = teto * teto
print(type(teto))
print(sys.getsizeof(teto))
print(teto)
