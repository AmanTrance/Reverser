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

let get_pod_ip_based_on_client (_c_ip : string) : string * int = "192.168.1.8", 22

let handle_proxy (fd : Lwt_unix.file_descr) (ip : string) : unit -> unit Lwt.t =
  let conn : bool ref = ref true in
  let c_ic = Lwt_io.of_fd ~mode:Lwt_io.input fd in
  let c_oc = Lwt_io.of_fd ~mode:Lwt_io.output fd in
  fun _ ->
    let p_ip, p_p = get_pod_ip_based_on_client ip in
    let p_s = Lwt_unix.socket ~cloexec:true Unix.PF_INET Unix.SOCK_STREAM 0 in
    let* () = Lwt_unix.connect p_s @@ pod_socket_addr p_ip p_p in
    let _ =
      Lwt_preemptive.run_in_main_dont_wait
        (fun () ->
           let p_ic = Lwt_io.of_fd ~mode:Lwt_io.input p_s in
           let rec h_pod () =
             let* d = Lwt_io.read ~count:64 p_ic in
             if Bytes.length @@ Bytes.of_string @@ d == 0
             then
               if !conn
               then Lwt.return ()
               else
                 let* () = Lwt_io.close p_ic in
                 Lwt.return (conn := false)
             else
               let* () = Lwt_io.write c_oc d in
               h_pod ()
           in
           h_pod ())
        (fun _ -> ())
    in
    let p_oc = Lwt_io.of_fd ~mode:Lwt_io.output p_s in
    let rec h_cl () =
      let* d = Lwt_io.read ~count:64 c_ic in
      if Bytes.length @@ Bytes.of_string @@ d == 0
      then
        let* () = Lwt_io.close c_ic in
        let* () = Lwt_io.close c_oc in
        let* () = Lwt_unix.close fd in
        let* () = Lwt_io.close p_oc in
        let* () = Lwt_unix.close p_s in
        if !conn then Lwt.return () else Lwt.return (conn := false)
      else
        let* () = Lwt_io.write p_oc d in
        h_cl ()
    in
    h_cl ()
;;
