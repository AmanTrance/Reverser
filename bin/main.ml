open Reverse_tcp.Lib

let () = 
    Lwt_main.run @@ accept_and_serve "0.0.0.0" 10000