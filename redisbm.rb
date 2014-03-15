# redisbm.rb

####
##    Redis HSET/HGET vs SET/GET benchmark
###
#

# std-lib
require 'benchmark'
require 'optparse'
# db
require 'redis'
# drivers
#require 'hiredis'
##require 'em-synchrony'

# we need the CAPTION and FORMAT constants
include Benchmark

### Parse options

options = {}

OptionParser.new do |opts|
  opts.banner = %Q{Usage: ruby redisbm.rb [options]}

  opts.on("-d", "--driver=DRIVER", "choose redis driver, --driver=default|hiredis") do |driver|
    options[:driver] = driver
  end

  opts.on("-n", "--db-number=NUMBER", Integer, "choose redis db number (0 by default), --db-number=15") do |number|
    options[:db_number] = number
  end

  opts.on("-s", "--db-socket-path=[PATH]", "choose redis socket path if need (\"/tmp/redis.sock\" by default)") do |path|
  	options[:socket] = true
    options[:path] = path
  end

  opts.on("-c", "--count=COUNT", Array, "number of hashes, 10 000 by default (it may be an Array)") do |count|
    options[:count] = count
  end

  opts.on("-f", "--fields=FIELDS", Array, "number of hash fields, 10 by default (it may be an Array)") do |fields|
    options[:fields] = fields
  end

  opts.on("-l", "--length=LENGTH", Integer, "length of value, 7 by default") do |length|
    options[:length] = length
  end

  opts.on("--prefix=PREFIX", "prefix to protect from overwriting existing values") do |prefix|
    options[:prefix] = prefix
  end

   opts.on("--flush", "flush db after test !!!REMOVE ALL DATA FROM DB!!!") do |flush|
    options[:flush] = flush
  end

  opts.on_tail("-h", "--help", "Show this message") do
  	puts opts
  	puts "  Source: <http://github.com/logrusorgru/redisbm>"
  	puts "  License: MIT"
  	puts "  (c) 2014 Konstantin Ivanov <ivanov.konstantin@logrus.org.ru>"
  	exit 0
  end

end.parse!

###
### Apply options 
###

redis_args = {} # db options

# redis driver
if options[:driver] == 'hiredis'
	require 'hiredis'
	redis_args[:driver] = options[:driver]
end

# db num
redis_args[:db] = options[:db_number] unless options[:db_number].nil?

# use socket?
if options[:socket]
	redis_args[:path] = options[:path].nil? ? "/tmp/redis.sock" : options[:path]
end

# more options

count = options[:count].nil? ? [10_000] : options[:count]
fields = options[:fields].nil? ? [10] : options[:fields]

# set value length

$length = options[:length] || 7

# generate random string

def rnd_data
	('a'..'z').to_a.shuffle[0..$length].join
end

# hash name with prefix

$prefix = options[:prefix]

def hname h
	"#{$prefix}#{h}"
end

# hash name with prefix + field name

def str_key h, f
	"#{hname(h)}:#{f}"
end

### Init DB

begin

	$r = Redis.new redis_args

	puts "Ok, let's go!"

	count.each_index do |i|

		puts "Step #{i+1} of #{count.size}"
		puts "\tHashes: #{count[i]}"
		fld = fields[i].nil? ? 10 : fields[i].to_i
		puts "\tFields: #{fld}"
		puts "\tLength: #{$length}"
	
		# generate k-v hash
	
		kv = {}
	
		puts "generate values hash..."
	
		count[i].to_i.times do |i|
			hash_name = hname "#{rnd_data}-#{i}"
			fld.times do |j|
				field_name = "#{rnd_data}-j"
				kv[hash_name] = { field_name => rnd_data }
			end
		end

		puts "perfomance test..."

		Benchmark.benchmark( CAPTION,
												 16,
												 FORMAT,
		 										 "hset/hget total:".rjust(16),
		 	 									 "set/get total:".rjust(16),
		 	 		 							 "difference".rjust(16) ) do |b|

			### hset/hget

			# write
			hw = b.report( 'hset write'.rjust(16) ) do
				kv.each do |h, f|
					# h - count, redis hash name
					# f - redis hash field
					$r.hset h, f, kv[h][f]
				end
			end

			# read
			hr = b.report( 'hget read'.rjust(16) ) do
				kv.each do |h, f|
					$r.hget h, f
				end
			end
		
			### set/get

			# write
			sw = b.report( 'set write'.rjust(16) ) do
				kv.each do |h, f|
					# h - count, redis hash name
					# f - redis hash field
					$r.set str_key( h, f ), kv[h][f]
				end
			end

			# read
			sr = b.report( 'get read'.rjust(16) ) do
				kv.each do |h, f|
					$r.get str_key( h, f )
				end
			end

			# totlas and difference
			[ hw + hr, sw + sr, hw + hr - sw - sr ]
		end

		puts "cleaning..."

		kv.each do |h, f|
			$r.del hname(h)
			$r.del str_key( h, f )
		end

	# end of count.each
	end

 # db connection failed
 rescue Redis::CannotConnectError
 	puts "db connection failed, please check connection option ( see README for details )"
 	exit 0

end

# flush db if need
begin
	puts "Flush db"
	$r.flushdb
end if options[:flush]

puts "done"

exit 0
