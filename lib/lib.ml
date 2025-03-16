let ( let* ) = Lwt.bind

let server_socket_addr (h : string) (p : int) =
  let addr_info : Unix.addr_info list =
    Unix.getaddrinfo h (string_of_int p) [ Unix.(AI_FAMILY PF_INET) ]
  in
  let addr =
    match addr_info with
    | [] -> raise Exit
    | addr :: _ -> addr.ai_addr
  in
  addr
;;

let bind_and_listen (h : string) (p : int) : Lwt_unix.file_descr Lwt.t =
  let socket = Lwt_unix.socket ~cloexec:true Unix.PF_INET Unix.SOCK_STREAM 0 in
  let* _ = Lwt_unix.bind socket @@ server_socket_addr h p in
  let _ = Lwt_unix.listen socket 1 in
  Lwt.return socket
;;

let accept_and_serve (h : string) (p : int) =
  let* s = bind_and_listen h p in
  let rec accepter () =
    let* fd, a = Lwt_unix.accept ~cloexec:true s in
    let _, _ =
      match a with
      | Unix.ADDR_INET (ip, port) -> ip, port
      | _ -> raise Exit
    in
    let _ = Thread.create Lwt_main.run ((Client.handle_proxy fd "192.168.1.6") ()) in
    accepter ()
  in
  accepter ()
;;
