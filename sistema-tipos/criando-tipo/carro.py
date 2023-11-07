class Carro:
  def __init__(self, peso, potencia):
    self.peso = peso
    self.potencia = potencia

  def __gt__(self, value):
    return self.peso > value.peso

if __name__ == "__main__":
  hilux = Carro(1880, 163)
  gol = Carro(901, 75)

  if hilux > gol:
    print("Gol e mais leve")