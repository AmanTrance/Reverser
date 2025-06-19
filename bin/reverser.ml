module ServerConfig = struct
  type server_config = Config of (string * int)

  let get_server_config () : server_config =
    let t : Toml.Types.table =
      Toml.Parser.from_filename "~/.config/reverser.toml" |> Toml.Parser.unsafe
    in
    let i : string option = Toml.Lenses.(get t (key "server.ip" |-- string)) in
    let p : int option = Toml.Lenses.(get t (key "server.port" |-- int)) in
    match i, p with
    | None, None -> Config ("0.0.0.0", 10000)
    | Some x, None -> Config (x, 10000)
    | None, Some y -> Config ("0.0.0.0", y)
    | Some x, Some y -> Config (x, y)
  ;;
end

module ClientMapConfig = struct end
