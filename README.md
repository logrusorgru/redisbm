redisbm
=======

Compare Redis HSET/HGET and SET/GET

### Require

* [Ruby Interpriter](http://ruby-lang.org)
* [Redis server](http://redis.io)
* `redis` ruby gem
* `hiredis` ruby gem ( if you want )


### Installation ( Linux ) and usage

```bash
$ git clone https://github.com/logrusorgru/redisbm.git
$ cd redisbm
```
Launch test ( see options! )

```bash
$ ruby redisbm.rb
```

### Options

##### For help

```bash
$ ruby redisbm.rb --help
```

##### DB options:

	--driver=default|hiredis
		choose redis driver
	--db-number=10
		choose number of db, 0 by default
	--db-socket-path ( or -s )
		use unix domain socket instead of TCP connection ( default path is /tmp/redis.sock )
	--prefix
		set hashes-names and key's names prefix to protect from overwriting existing values
	--flush
		flush db after test ( REMOVE ALL FROM DB )

##### Test options

	--count
		number of hashes ( default: 10000 )
	--fields
		number of each hash fields ( default: 10 )
	--length
		length of value ( default: 7 )

##### Exampes

```bash
ruby redisbm.rb -s -n10 --count=1000,10000,20000,40000,80000,160000 -f100
```

```bash
ruby redisbm.rb -s -n10 -c1000,50000,100000 -f100,20,1
```

### Legal

MIT License

&copy; 2014 Konstantin Ivanov
