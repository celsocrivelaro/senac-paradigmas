// Aula 08, Bloco 2 -- Condicao de corrida
//
// Duas threads incrementam o mesmo contador 100 000 vezes cada. O total
// esperado e 200 000; o obtido e menor, e muda a cada execucao.
//
// contador++ nao e uma operacao, sao tres:
//   1. ler o valor de contador
//   2. somar 1
//   3. escrever o resultado em contador
// Se as duas threads leem o mesmo valor antes de qualquer uma escrever, as duas
// escrevem o mesmo resultado, e um dos incrementos se perde.

public class CondicaoDeCorrida {
    static int contador = 0;

    public static void main(String[] args) throws InterruptedException {
        Runnable incrementar = () -> {
            for (int i = 0; i < 100_000; i++) {
                contador++;
            }
        };

        Thread a = new Thread(incrementar);
        Thread b = new Thread(incrementar);
        a.start();
        b.start();
        a.join();
        b.join();

        System.out.println("esperado: 200000");
        System.out.println("obtido:   " + contador);
    }
}
