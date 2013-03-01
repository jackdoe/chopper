package CONFIG;
use DBI;

sub s {
        return "sub\n";
}
use constant DBH => DBI->connect("dbi:SQLite:dbname=".main::path('app','db','demo.db'),"","");
use constant ROUTE => {
                                GET =>  { 
                                           qr#^/person/index/$# => ['Person','index'],
                                           qr#^/sub$# => \&s
                                        },
                                POST => {
                                           qr#^/person/add$#      => ['Person','add'],
                                        }
                      };
#use constant SESSION => undef;
use constant SESSION => { key => 'chop.s', secret => 'ASD8aSD****ASdyasd6tA^%12' };
1;
