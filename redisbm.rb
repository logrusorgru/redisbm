# redisbm.rb

####
##    Redis HSET/HGET vs SET/GET benchmark
###
#

require 'benchmark'
require 'redis'
require 'hiredis'

$r = Redis.new path: "/tmp/redis.sock", db: 10, driver: :hiredis

count = ( ARGV[0].is_a? String ) ? ARGV[0].to_i : 10000

puts "Count #{count}"

# denerate rnd data

def rnd_data
	('a'..'z').to_a.shuffle[0..7].join
end

# generate k-v hash

kv = {}

count.times do |i|
	hash_field = "#{rnd_data}-#{i}"
	field_value = rnd_data
	kv[i] = { hash_field => field_value }
end

def key k, v
	"#{k}:#{v}"
end

Benchmark.bm do |b|
	# hset/hget
	b.report('hset/hget') do
		# write
		kv.each do |k, v|
			# k - count, redis hash name
			# v - redis hash field
			$r.hset k, v, kv[k][v]
		end
		# read
		kv.each do |k, v|
			$r.hget k, v
		end
	end

	# set/get
	b.report('set/get') do
		# write
		kv.each do |k, v|
			# k - count, redis hash name
			# v - redis hash field
			$r.set key( k, v ), kv[k][v]
		end
		# read
		kv.each do |k, v|
			$r.get key( k, v )
		end
	end
end
