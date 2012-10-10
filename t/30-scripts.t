#!perl

use warnings;
use strict;
use Test::More;
use Test::Exception;
use Redis;
use lib 't/tlib';
use Test::SpawnRedisServer;
use Digest::SHA1 qw(sha1_hex);

my ($c, $srv) = redis();
END { $c->() if $c }


ok(my $o = Redis->new(server => $srv), 'connected to our test redis-server');
ok($o->ping, 'ping');

## Commands related to Lua scripting

# Specifically, these commands test multi-word commands

ok($o->set(foo => 'bar'), 'set foo => bar');

$o->script_flush;

my $script = "return 1";
my $script_sha = sha1_hex($script);
my @ret = $o->script_exists($script_sha);
ok(@ret && $ret[0] == 0, "script exists returns false");
@ret = $o->script_load($script);
ok(@ret && $ret[0] eq $script_sha, "script load returns the sha1 of the script");
ok($o->script_exists($script_sha), "script exists returns true after loading");
ok($o->evalsha($script_sha, 0), "evalsha returns true with the sha1 of the script");
ok($o->eval($script, 0), "eval returns true");

## All done
done_testing();
