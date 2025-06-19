let ( let* ) = Lwt.bind

let pod_socket_addr (i : string) (p : int) =
  let addr_info : Unix.addr_info list =
    Unix.getaddrinfo i (string_of_int p) [ Unix.(AI_FAMILY PF_INET) ]
  in
  let addr =
    match addr_info with
    | [] -> raise Exit
    | addr :: _ -> addr.ai_addr
  in
  addr
;;

let get_pod_ip_based_on_client (t : (string, string) Hashtbl.t) (c_ip : string)
  : string * int
  =
  let v : string = Hashtbl.find t c_ip in
  let s : string list = String.split_on_char ':' v in
  match s with
  | [] -> raise Not_found
  | i :: [] -> i, 22
  | [ i; p ] -> i, int_of_string p
  | _ -> raise Not_found
;;

let handle_proxy
      (t : (string, string) Hashtbl.t)
      (c_fd : Lwt_unix.file_descr)
      (ip : string)
  : unit -> unit Lwt.t
  =
  let conn : bool ref = ref true in
  let c_ic = Lwt_io.of_fd ~mode:Lwt_io.input c_fd in
  let c_oc = Lwt_io.of_fd ~mode:Lwt_io.output c_fd in
  fun _ ->
    try
      let p_ip, p_p = get_pod_ip_based_on_client t ip in
      let p_fd = Lwt_unix.socket ~cloexec:false Lwt_unix.PF_INET Lwt_unix.SOCK_STREAM 0 in
      let* () = Lwt_unix.connect p_fd @@ pod_socket_addr p_ip p_p in
      let p_ic = Lwt_io.of_fd ~mode:Lwt_io.input p_fd in
      let p_oc = Lwt_io.of_fd ~mode:Lwt_io.output p_fd in
      let _ =
        Lwt_preemptive.run_in_main_dont_wait
          (fun () ->
             let rec h_pod () =
               let* d = Lwt_io.read ~count:65535 p_ic in
               if Bytes.length @@ Bytes.of_string @@ d == 0
               then
                 let* () = Lwt_io.close p_ic in
                 let* () = Lwt_io.close p_oc in
                 let* () = Lwt_unix.close c_fd in
                 if !conn then Lwt.return () else Lwt.return (conn := false)
               else
                 let* () = Lwt_io.write c_oc d in
                 h_pod ()
             in
             h_pod ())
          (fun _ -> ())
      in
      let rec h_cl () : unit Lwt.t =
        let* d : string = Lwt_io.read ~count:65535 c_ic in
        if Bytes.length @@ Bytes.of_string @@ d == 0
        then
          let* () = Lwt_io.close c_ic in
          let* () = Lwt_io.close c_oc in
          let* () = Lwt_unix.close p_fd in
          if !conn then Lwt.return () else Lwt.return (conn := false)
        else
          let* () = Lwt_io.write p_oc d in
          h_cl ()
      in
      h_cl ()
    with
    | _ -> Lwt.return ()
;;
