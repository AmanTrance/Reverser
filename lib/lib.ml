let (let*) = Lwt.bind

let server_socket_addr (h : string) (p : int) = 
  let addr_info : Unix.addr_info list = Unix.getaddrinfo h (string_of_int p) [Unix.(AI_FAMILY PF_INET)]
  in
    let addr =
      match addr_info with
      | []        -> raise Exit
      | addr :: _ -> addr.ai_addr
  in
    addr;;

let bind_and_listen (h : string) (p : int) : Lwt_unix.file_descr Lwt.t =
  let socket = Lwt_unix.socket ~cloexec:true Unix.PF_INET Unix.SOCK_STREAM 0 
  in
    let* _ = Lwt_unix.bind socket @@ server_socket_addr h p 
  in
    let _ = Lwt_unix.listen socket 1 in
      Lwt.return socket;;
    
let accept_and_serve (h : string) (p : int) =
  let* s = bind_and_listen h p 
  in
    let* (_, a) = Lwt_unix.accept ~cloexec:true s 
  in
    let* () = match a with
      | Unix.ADDR_INET (ip, port) -> Lwt.return @@ Printf.printf "IP -> %s:%d" (Unix.string_of_inet_addr ip) @@ port 
      | _ -> raise Exit
  in
    let _ = Domain.spawn @@ fun _ -> Lwt.return ()
  in
    Lwt.return ();;

                  


