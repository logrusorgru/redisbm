redisbm
=======

Compare Redis HSET/HGET and SET/GET

### Require

* Ruby Interpriter
* redis ruby gem
* hiredis ruby gem

### Edit

By default db connection options is

```ruby
$r = Redis.new "/tmp/redis.sock", db: 10, driver: :hiredis
```

You may to use default connection options (no need for 'hiredis' driver)

```ruby
$r = Redis.new
```


### Usage

```bash
$ ruby redisbm.rb 50000
```

50000 - an example (10000 by default)

### Legal

MIT License

&copy; 2014 Konstantin Ivanov
