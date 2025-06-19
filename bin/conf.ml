module ServerConfig = struct
  type server_config = Config of (string * int)

  let get_server_config (t : Toml.Types.table) : server_config =
    let i : string option =
      Toml.Lenses.(get t (key "server" |-- table |-- key "ip" |-- string))
    in
    let p : int option =
      Toml.Lenses.(get t (key "server" |-- table |-- key "port" |-- int))
    in
    match i, p with
    | None, None -> Config ("0.0.0.0", 10000)
    | Some x, None -> Config (x, 10000)
    | None, Some y -> Config ("0.0.0.0", y)
    | Some x, Some y -> Config (x, y)
  ;;
end

module ClientMapConfig = struct
  exception BadConfig of string

  let rec setup_map (l : Toml.Types.table list) (map : (string, string) Hashtbl.t) : unit =
    match l with
    | [] -> ()
    | x :: xs ->
      let s : string option = Toml.Lenses.(get x (key "source" |-- string)) in
      let d : string option = Toml.Lenses.(get x (key "destination" |-- string)) in
      (match s, d with
       | Some src, Some dst ->
         let () = Hashtbl.add map src dst in
         setup_map xs map
       | _ -> raise @@ BadConfig "Wrong Config")
  ;;

  let get_clients_map (t : Toml.Types.table) (map : (string, string) Hashtbl.t) : unit =
    let m = Toml.Lenses.(get t (key "mappings" |-- array |-- tables)) in
    match m with
    | None -> ()
    | Some x -> setup_map x map
  ;;
end
