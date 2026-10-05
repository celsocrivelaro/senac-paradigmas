// Aula 08, Bloco 2 -- Threads
//
// Duas threads do mesmo processo imprimem cinco mensagens cada. A ordem das
// linhas e decidida pelo escalonador, e nao pelo programa: executar o arquivo
// mais de uma vez produz ordens diferentes.

public class Threads {

    static void tarefa(String nome) {
        for (int i = 1; i <= 5; i++) {
            System.out.println(nome + " " + i);
            try {
                // Pausa curta e variavel, para que a intercalacao apareca na saida.
                Thread.sleep((long) (Math.random() * 10));
            } catch (InterruptedException e) {
                return;
            }
        }
    }

    public static void main(String[] args) throws InterruptedException {
        Thread a = new Thread(() -> tarefa("A"));
        Thread b = new Thread(() -> tarefa("B"));

        a.start();
        b.start();

        // join: o main espera as duas threads terminarem antes de seguir.
        a.join();
        b.join();

        System.out.println("fim");
    }
}
