open Reverse_tcp.Lib

let () =
  let (Reverser.ServerConfig.Config (ip, port)) : Reverser.ServerConfig.server_config = Reverser.ServerConfig.get_server_config () in
    Lwt_main.run @@ accept_and_serve ip port
