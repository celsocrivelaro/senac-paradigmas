class cat = object
  method speak = print_endline "mia"
end
class dog = object
  method speak = print_endline "late"
end

let hear_what_it_has_to_say obj 
  = obj#speak;;

let () = hear_what_it_has_to_say (new cat) (* imprime "meow" *)
let () = hear_what_it_has_to_say (new dog) (* imprime "woof" *)