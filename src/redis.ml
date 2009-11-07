let create_connection addr port =
    (* From a string of the address, and a port as an int, gets an input and output file discriptor *)
    let server = Unix.inet_addr_of_string addr
    in
    Unix.open_connection(
        Unix.ADDR_INET(server, port)
    )

let read_string in_chan =
    (* Read arbitratry length string (hopefully quite short) from current pos in in_chan until \r\n *)
    let rec iter out_buffer =
        match input_char in_chan with
            '\r' -> (
                match input_char in_chan with
                    '\n' -> Buffer.contents out_buffer |
                    x -> begin
                        Buffer.add_char out_buffer '\r';
                        Buffer.add_char out_buffer x;
                        iter out_buffer
                    end 
            ) |
            x -> begin
                Buffer.add_char out_buffer x;
                iter out_buffer
            end
    in
    iter (Buffer.create 100);;

type response = Status of string | Error;;
let send_and_receive_command command connection =
    (* Send command, and recieve the results *)
    let in_chan, out_chan = connection
    in
    begin
        output_string out_chan command;
        output_string out_chan "\r\n";
        flush out_chan;
        match (input_char in_chan) with
            '+' -> Status(read_string in_chan) |
            _ -> Error
    end