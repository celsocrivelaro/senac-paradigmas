fn main() {
    println!("Hello, world!");

    // escopo
    {
        let _s = String::from("hello"); 
    }
    // fora deste escopo, s não é mais válida. 
    // Rust chama a função drop para liberar a memória
    // detalhes: https://doc.rust-lang.org/book/ch04-01-what-is-ownership.html
    // detalhes drop: https://doc.rust-lang.org/std/ops/trait.Drop.html       
    
    // PARTE 2: Move
    let x = 5;
    let y = x; // Rust faz uma cópia do valor de x e atribui a y
    println!("x = {}, y = {}", x, y);

    // PARTE 3: Move com String
    // Este código quebra porque dividimos a referência de s1 para s2
    // Assim, s2 pega emprestado a memória de s1 e Rust apaga a memória duas vezes
    // let s1 = String::from("hello");
    // let s2 = s1;

    // println!("{s1}, world!");

}
