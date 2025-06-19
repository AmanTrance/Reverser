open Reverse_tcp.Lib

let () =
  let t : Toml.Types.table =
    Toml.Parser.from_filename "/home/amanfreecs/.config/reverser/reverser.toml"
    |> Toml.Parser.unsafe
  in
  let (Conf.ServerConfig.Config (ip, port)) : Conf.ServerConfig.server_config =
    Conf.ServerConfig.get_server_config t
  in
  let clients_map : (string, string) Hashtbl.t = Hashtbl.create 64 in
  let () = Conf.ClientMapConfig.get_clients_map t clients_map in
  Lwt_main.run @@ accept_and_serve ip port clients_map
;;
