public class Nominal {
  public static void main(String[] args) {
      class Teste{}
      class TesteHerdada extends Teste {}
      class TesteNaoHerdado{}

      //System.out.println("Hello world !!!");
      Teste teste1 = new Teste(); // valido norminalmente
      Teste teste2 = new TesteHerdada(); // valido norminalmente pela Heranca 
      Teste teste3 = new TesteNaoHerdado(); // invalido por nao ter mesmo nome
  }
}