(* Copyright (C) 2009 Rory Geoghegan - r.geoghegan@gmail.com
   Released under the BSD license. See the LICENSE.txt file for more info.

   Tests for "Commands operating on hashes" *)

let test_hset () =
    let test_func connection =
        assert(Redis.hset "rory" "cool" "yeah" connection);
        assert( not (Redis.hset "rory" "cool" "no" connection))
    in
    Script.use_test_script
        [
            Script.ReadThisLine("HSET rory cool 4");
            Script.ReadThisLine("yeah");
            Script.WriteThisLine(":1");
            Script.ReadThisLine("HSET rory cool 2");
            Script.ReadThisLine("no");
            Script.WriteThisLine(":0");
        ]
        test_func;;

let test_hdel () =
    let test_func connection =
        assert(Redis.hset "rory" "cool" "true" connection);
        assert(Redis.hdel "rory" "cool" connection);
        assert(not (Redis.hdel "rory" "cool" connection))
    in
    Script.use_test_script
        [
            Script.ReadThisLine("HSET rory cool 4");
            Script.ReadThisLine("true");
            Script.WriteThisLine(":1");
            Script.ReadThisLine("HDEL rory 4");
            Script.ReadThisLine("cool");
            Script.WriteThisLine(":1");
            Script.ReadThisLine("HDEL rory 4");
            Script.ReadThisLine("cool");
            Script.WriteThisLine(":0")
        ]
        test_func;;

let test_hget () =
    let test_func connection =
        assert(Redis.hset "rory" "cool" "true" connection);
        assert(
            (Redis.hget "rory" "cool" connection) = Redis.String("true")
        )
    in
    Script.use_test_script
        [
            Script.ReadThisLine("HSET rory cool 4");
            Script.ReadThisLine("true");
            Script.WriteThisLine(":1");
            Script.ReadThisLine("HGET rory 4");
            Script.ReadThisLine("cool");
            Script.WriteThisLine("$4");
            Script.WriteThisLine("true")
        ]
        test_func;;

let test_hmget () =
    let test_func connection =
        assert(Redis.hset "rory" "cool" "true" connection);
        assert(Redis.hset "rory" "handsome" "true" connection);
        assert([Redis.String("true")] = Redis.hmget "rory" ["cool"] connection);
        assert([Redis.String("true"); Redis.String("true")] =
            Redis.hmget "rory" ["cool"; "handsome"] connection)
    in
    Script.use_test_script [
            Script.ReadThisLine("HSET rory cool 4");
            Script.ReadThisLine("true");
            Script.WriteThisLine(":1");
            Script.ReadThisLine("HSET rory handsome 4");
            Script.ReadThisLine("true");
            Script.WriteThisLine(":1");
            Script.ReadThisLine("HMGET rory 4");
            Script.ReadThisLine("cool");
            Script.WriteThisLine("*1");
            Script.WriteThisLine("$4");
            Script.WriteThisLine("true");
            Script.ReadThisLine("HMGET rory cool 8");
            Script.ReadThisLine("handsome");
            Script.WriteThisLine("*2");
            Script.WriteThisLine("$4");
            Script.WriteThisLine("true");
            Script.WriteThisLine("$4");
            Script.WriteThisLine("true")
        ] test_func;;

let test_hmset () =
    let test_func connection =
        Redis.hmset "rory" [("cool", "true"); ("handsome", "true")] connection
    in
    Script.use_test_script [
            Script.ReadThisLine("*6");
            Script.ReadThisLine("$5");
            Script.ReadThisLine("HMSET");
            Script.ReadThisLine("$4");
            Script.ReadThisLine("rory");
            Script.ReadThisLine("$4");
            Script.ReadThisLine("cool");
            Script.ReadThisLine("$4");
            Script.ReadThisLine("true");
            Script.ReadThisLine("$8");
            Script.ReadThisLine("handsome");
            Script.ReadThisLine("$4");
            Script.ReadThisLine("true");
            Script.WriteThisLine("+OK")
        ] test_func;;
    