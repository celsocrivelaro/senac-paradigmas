interface Named {
  name: string;
}

class Person {
  name: string;
  constructor(name: string) {
    this.name = name;
  }
}

let p: Named;
// OK, because of structural typing
p = new Person("Jose");