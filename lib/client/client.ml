let (let*) = Lwt.bind

let pod_socket_addr (h : string) (p : int) = 
  let addr_info : Unix.addr_info list = Unix.getaddrinfo h (string_of_int p) [Unix.(AI_FAMILY PF_INET)]
  in
    let addr =
      match addr_info with
      | []        -> raise Exit
      | addr :: _ -> addr.ai_addr
  in
    addr;;

let get_pod_ip_based_on_client (c_ip : string) : string * int =
  (c_ip, 22);;

let handle_proxy (fd : Lwt_unix.file_descr) (ip : string) : (_ -> unit Lwt.t) =
  let c_ic = Lwt_io.of_fd ~mode:Lwt_io.input fd 
  in
    let o_ic = Lwt_io.of_fd ~mode:Lwt_io.output fd
  in
    fun _ -> begin 
      let (p_ip, p_p) = get_pod_ip_based_on_client ip 
      in
        let p_s = Lwt_unix.socket ~cloexec:true Unix.PF_INET Unix.SOCK_STREAM 0 
      in
        let* () = Lwt_unix.connect p_s @@ pod_socket_addr p_ip p_p
      in
        let _ = Domain.spawn @@ fun _ -> begin
          let p_ic = Lwt_io.of_fd ~mode:Lwt_io.input p_s 
        in
          let rec h_pod () = begin
            let* d = Lwt_io.read_line p_ic in
              let* () = Lwt_io.write o_ic d 
            in
              h_pod ()  
          end
        in
          h_pod ()
        end
      in
        let p_oc = Lwt_io.of_fd ~mode:Lwt_io.output p_s
      in  
        let rec h_cl () = begin
          let* d = Lwt_io.read_line c_ic 
        in
          let* () = Lwt_io.write p_oc d 
        in
          h_cl ()
        end
      in
        h_cl ()
    end;; 
  