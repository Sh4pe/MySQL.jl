using Test

"""
See [the issue](https://github.com/JuliaDatabases/MySQL.jl/issues/130).

This test creates a new and empty table inside a new database. This table
has 65 rows and the query "SELECT * FROM <the_table>" is run against it.

Then, `iterate(query)` is run against the received MySQL.Query struct. This
call is expected to be fast since we iterate over an empty table. However, it is
slow. On the author's machine, the call did not even finish after 40 minutes!
"""
function tests_for_issue130(conn)

    # Create critical database and insert some values in it.
    MySQL.execute!(conn, """
        DROP DATABASE if exists mysqltest_issue130;
        CREATE DATABASE mysqltest_issue130;
        USE mysqltest_issue130;
    """)

    # Make sure that the table does not exist before
    tables_before = MySQL.Query(conn, "show tables") |> columntable
    @test length(tables_before[1]) == 0

    MySQL.execute!(conn, """
        CREATE TABLE `test_table` ( 
            `f1` bigint(20) unsigned NOT NULL AUTO_INCREMENT, 
            `f2` smallint(6) unsigned NOT NULL, 
            `f3` int(11) unsigned NOT NULL, 
            `f4` datetime DEFAULT NULL, 
            `f5` datetime NOT NULL, 
            `f6` bigint(20) NOT NULL DEFAULT '0', 
            `f7` varchar(100) COLLATE utf8_bin NOT NULL, 
            `f8` smallint(6) NOT NULL DEFAULT '0', 
            `f9` int(11) DEFAULT NULL, 
            `f10` int(11) DEFAULT NULL, 
            `f11` bigint(20) DEFAULT NULL, 
            `f12` smallint(6) unsigned NOT NULL DEFAULT '0', 
            `f13` varchar(50) COLLATE utf8_bin DEFAULT NULL, 
            `f14` int(11) DEFAULT NULL, 
            `f15` int(11) DEFAULT NULL, 
            `f16` smallint(6) unsigned DEFAULT NULL, 
            `f17` smallint(6) unsigned DEFAULT NULL, 
            `f18` char(4) COLLATE utf8_bin DEFAULT NULL, 
            `f19` char(4) COLLATE utf8_bin DEFAULT NULL, 
            `f20` char(8) COLLATE utf8_bin DEFAULT NULL, 
            `f21` char(8) COLLATE utf8_bin DEFAULT NULL, 
            `f22` varchar(6) COLLATE utf8_bin DEFAULT NULL, 
            `f23` tinyint(4) unsigned NOT NULL DEFAULT '0', 
            `f24` tinyint(4) unsigned NOT NULL DEFAULT '0', 
            `f25` varchar(10) COLLATE utf8_bin DEFAULT NULL, 
            `f26` float(10,2) DEFAULT NULL, 
            `f27` varchar(10) COLLATE utf8_bin DEFAULT NULL, 
            `f28` int(11) DEFAULT NULL, 
            `f29` bit(1) DEFAULT NULL, 
            `f30` bit(1) DEFAULT NULL, 
            `f31` bit(1) DEFAULT NULL, 
            `f32` bit(1) DEFAULT NULL, 
            `f33` varchar(10) COLLATE utf8_bin DEFAULT NULL, 
            `f34` float(10,2) DEFAULT NULL, 
            `f35` float(10,2) DEFAULT NULL, 
            `f36` float(10,2) DEFAULT NULL, 
            `f37` varchar(10) COLLATE utf8_bin DEFAULT NULL, 
            `f38` float(10,2) DEFAULT NULL, 
            `f39` mediumint(11) DEFAULT NULL, 
            `f40` varchar(10) COLLATE utf8_bin DEFAULT NULL, 
            `f41` float(10,2) DEFAULT NULL, 
            `f42` varchar(10) COLLATE utf8_bin DEFAULT NULL, 
            `f43` int(11) DEFAULT NULL, 
            `f44` varchar(10) COLLATE utf8_bin DEFAULT NULL, 
            `f45` int(11) DEFAULT NULL, 
            `f46` varchar(10) COLLATE utf8_bin DEFAULT NULL, 
            `f47` varchar(10) COLLATE utf8_bin DEFAULT NULL, 
            `f48` float(10,2) DEFAULT NULL, 
            `f49` float(10,2) DEFAULT NULL, 
            `f50` float(10,2) DEFAULT NULL, 
            `f51` float(10,2) DEFAULT NULL, 
            `f52` float(10,2) DEFAULT NULL, 
            `f53` float(10,2) DEFAULT NULL, 
            `f54` float(10,2) DEFAULT NULL, 
            `f55` float(10,2) DEFAULT NULL, 
            `f56` float(10,2) DEFAULT NULL, 
            `f57` float(10,2) DEFAULT NULL, 
            `f58` float(10,2) DEFAULT NULL, 
            `f59` float(10,2) DEFAULT NULL, 
            `f60` float(10,2) DEFAULT NULL, 
            `f61` varchar(10) COLLATE utf8_bin DEFAULT NULL, 
            `f62` float(10,2) DEFAULT NULL, 
            `f63` tinyint(4) unsigned DEFAULT '99', 
            `f64` varchar(1000) COLLATE utf8_bin DEFAULT NULL, 
            `f65` tinyint(1) NOT NULL DEFAULT '0', 
            PRIMARY KEY (`f1`)
        );
    """)

    # Make sure the new table exists and is empty
    tables_after = MySQL.Query(conn, "show tables") |> columntable
    @test length(tables_after[1]) == 1
    @test tables_after[1][1] == "test_table"
    count_query_table = MySQL.Query(conn, "select count(*) from test_table") |> columntable
    @test count_query_table[1][1] == 0 


    # This is the main issue. Iterating over an empty query should be quick.
    q = MySQL.Query(conn, "select * from test_table") 
    _, elapsed, _, _, _ = @timed iterate(q)
    @test elapsed < 20.0

end