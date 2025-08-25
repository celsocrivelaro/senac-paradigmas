fn main() {
    println!("Parte 1: Dentro do scopo");
    // escopo
    {
        let _s = String::from("hello"); 
    }
    // fora deste escopo, s não é mais válida. 
    // Rust chama a função drop para liberar a memória
    // detalhes: https://doc.rust-lang.org/book/ch04-01-what-is-ownership.html
    // detalhes drop: https://doc.rust-lang.org/std/ops/trait.Drop.html       
    
    // PARTE 2: Move
    println!("Parte 2: Faz uma cópia");
    let x = 5;
    let y = x; // Rust faz uma cópia do valor de x e atribui a y
    println!("x = {}, y = {}", x, y);

    // PARTE 3: Move com String
    println!("Parte 3: Move com String");
    // Este código quebra porque dividimos a referência de s1 para s2
    // Assim, s2 pega emprestado a memória de s1 e Rust apaga a memória duas vezes
    // let s1 = String::from("hello");
    // let s2 = s1;
    // println!("{s1}, world!");

    // PARTE 4: Dá e devolve
    println!("Parte 4: Ownership Dar e devolver");
    dar_e_devolver_ownership();

    // PARTE 5: Passagem por referência
    println!("Parte 5: Referências e empréstimo");
    parte5();


}

fn dar_e_devolver_ownership() {
    let s = String::from("hello");  // s comes into scope

    takes_ownership(s);             // s's value moves into the function...
                                    // ... and so is no longer valid here

    let x = 5;                      // x comes into scope

    makes_copy(x);                  // Because i32 implements the Copy trait,
                                    // x does NOT move into the function,
                                    // so it's okay to use x afterward.

} // Here, x goes out of scope, then s. However, because s's value was moved,
  // nothing special happens.

fn takes_ownership(some_string: String) { // some_string comes into scope
    println!("{some_string}");
} // Here, some_string goes out of scope and `drop` is called. The backing
  // memory is freed.

fn makes_copy(some_integer: i32) { // some_integer comes into scope
    println!("{some_integer}");
} // Here, some_integer goes out of scope. Nothing special happens.


// PARTE 5
fn parte5() {
    let s1 = String::from("hello");
    let len = calculate_length(&s1);
    println!("The length of '{s1}' is {len}.");

    let mut s = String::from("Olá mutavel");
    mudar_mutavel(&mut s);
    println!("s = {s}");
}

fn calculate_length(s: &String) -> usize {
    s.len()
}

fn mudar_mutavel(some_string: &mut String) {
    some_string.push_str(", world");
}
