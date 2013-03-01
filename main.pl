#!/usr/bin/perl
use FCGI;
use Socket;
use IO::Handle;
use File::Spec;
use Getopt::Long;
use File::Basename;
use File::Spec;
use strict;
use warnings;
use constant ROOT => File::Basename::dirname(__FILE__);
sub path { return File::Spec->join(ROOT,@_); }

for my $f(glob(path('app','conf','*.pm') . ' ' . path('core','*.pm') . ' ' . path('app','{controllers,models}','*.{pl,pm}'))) {
        require $f;
}

my ($host,$port,$conc,$debug) = ('127.0.0.1',8999,50,0);
GetOptions ("concurrent=i" => \$conc,"port=i"   => \$port,"host=s"  => \$host,"debug=i" => \$debug);
warn "listening on $host:$port for $conc concurrent connections ($0 -host=$host -port=$port -concurrent=$conc -debug=$debug)\n";
my %env;
my ($out, $err) = (new IO::Handle, new IO::Handle);
my $socket = FCGI::OpenSocket( "$host:$port", $conc );
my $req = FCGI::Request( \*STDIN, $out, $err, \%ENV, $socket ,1);

if ($req) {
        while ($req->Accept() >= 0) {
                print $out Application->new({debug => $debug})->process();
        }
}
eval { CONFIG::DBH->disconnect(); };
FCGI::CloseSocket($socket);

