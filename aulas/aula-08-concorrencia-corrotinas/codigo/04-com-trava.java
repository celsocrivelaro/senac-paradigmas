// Aula 08, Bloco 2 -- Exclusao mutua com synchronized
//
// O mesmo contador de 03-condicao-de-corrida.java. A unica mudanca e que o
// incremento passa a ser feito por um metodo synchronized: so uma thread por
// vez executa o corpo dele. A leitura, a soma e a escrita deixam de poder ser
// intercaladas, e o resultado e sempre 200 000.

public class ComTrava {
    static int contador = 0;

    // Secao critica: o trecho que acessa o dado compartilhado.
    static synchronized void incrementar() {
        contador++;
    }

    public static void main(String[] args) throws InterruptedException {
        Runnable tarefa = () -> {
            for (int i = 0; i < 100_000; i++) {
                incrementar();
            }
        };

        Thread a = new Thread(tarefa);
        Thread b = new Thread(tarefa);
        a.start();
        b.start();
        a.join();
        b.join();

        System.out.println("esperado: 200000");
        System.out.println("obtido:   " + contador);
    }
}
