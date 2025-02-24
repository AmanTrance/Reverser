let (let*) = Lwt.bind

let get_socket_addr (h : string) (p : int) = 
  let addr_info : Unix.addr_info list = Unix.getaddrinfo h (string_of_int p) [Unix.AI_FAMILY Unix.PF_INET]
  in
  let addr =
    match addr_info with
    | []        -> raise Exit
    | addr :: _ -> addr.ai_addr
  in
  addr;;

let bind_and_listen (h : string) (p : int) : Lwt_unix.file_descr Lwt.t =
  let socket = Lwt_unix.socket ~cloexec:true Unix.PF_INET Unix.SOCK_STREAM 0 in
    let* _ = Lwt_unix.bind socket @@ get_socket_addr h p in
      let _ = Lwt_unix.listen socket 1 in
        Lwt.return socket;;
    
let accept_and_serve (h : string) (p : int) =
  let* s = bind_and_listen h p in
    let* (c, _) = Lwt_unix.accept ~cloexec:true s in
      let i = Lwt_io.of_fd ~mode:Lwt_io.input c in
        let _ = Lwt_io.of_fd ~mode:Lwt_io.output c in
          let r (ic) : unit Lwt.t = 
            let* m = Lwt_io.read_line ic in
              let () = Printf.printf "%s" m in
                Lwt.return () in
                  r i;;



                  


