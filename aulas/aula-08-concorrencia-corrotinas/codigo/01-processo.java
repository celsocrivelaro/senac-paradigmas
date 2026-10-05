// Aula 08, Bloco 2 -- Processo
//
// O mesmo arquivo roda duas vezes: como processo pai e como processo filho.
// Cada processo tem a sua propria copia de 'contador'. O filho altera a copia
// dele; a do pai continua intacta, porque os dois nao compartilham memoria.
// A unica comunicacao entre eles e a saida padrao do filho, lida pelo pai.

import java.io.BufferedReader;
import java.io.InputStreamReader;

public class Processo {
    static int contador = 10;

    public static void main(String[] args) throws Exception {
        long pid = ProcessHandle.current().pid();

        if (args.length > 0 && args[0].equals("filho")) {
            contador = contador + 1;
            System.out.println("filho (pid " + pid + "): contador = " + contador);
            return;
        }

        System.out.println("pai   (pid " + pid + "): contador = " + contador);

        // Dispara um segundo processo: a mesma JVM, o mesmo arquivo, com o argumento "filho".
        ProcessBuilder pb = new ProcessBuilder("java", "01-processo.java", "filho");
        Process filho = pb.start();

        // Le o que o filho escreveu na saida padrao dele.
        try (BufferedReader saida = new BufferedReader(new InputStreamReader(filho.getInputStream()))) {
            String linha;
            while ((linha = saida.readLine()) != null) {
                System.out.println("pai leu do filho -> " + linha);
            }
        }
        filho.waitFor();

        System.out.println("pai   (pid " + pid + "): contador = " + contador + "  (inalterado)");
    }
}
